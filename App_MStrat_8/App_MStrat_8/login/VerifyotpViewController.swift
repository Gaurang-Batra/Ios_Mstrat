import UIKit

class VerifyotpViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var EnterOtptextfield: UITextField!
    @IBOutlet weak var ResendOtpbutton: UIButton!
    @IBOutlet weak var ContinueButton: UIButton!
    @IBOutlet var circleview: [UIView]!
    
    // Properties to store user data from SignUpViewController
    var email: String?
    var fullname: String?
    var password: String?
    var verificationCode: String? // Changed from Int? to String? to match User.verification_code
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Log entry for debugging
        print("🔍 VerifyotpViewController loaded with email: \(email ?? "nil"), verificationCode: \(verificationCode ?? "nil")")
        
        // Set up the OTP text field
        EnterOtptextfield.placeholder = "Enter OTP"
        addUnderline(to: EnterOtptextfield)
        EnterOtptextfield.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        // Disable the Continue button initially
        ContinueButton.isEnabled = false
        
        // Configure circle views
        for view in circleview {
            let size = min(view.frame.width, view.frame.height)
            view.frame.size = CGSize(width: size, height: size)
            view.layer.cornerRadius = size / 2
            view.layer.masksToBounds = true
            view.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addUnderline(to: EnterOtptextfield)
    }
    
    // Function to add underline to a text field
    private func addUnderline(to textField: UITextField?) {
        guard let textField = textField else { return }
        let underline = CALayer()
        underline.frame = CGRect(x: 0, y: textField.frame.height - 2, width: textField.frame.width, height: 2)
        underline.backgroundColor = UIColor.black.cgColor
        textField.borderStyle = .none
        textField.layer.addSublayer(underline)
    }
    
    // Function to enable Continue button only when OTP field is filled
    @objc private func textFieldDidChange() {
        let isOtpFilled = !(EnterOtptextfield.text?.isEmpty ?? true)
        ContinueButton.isEnabled = isOtpFilled
    }
    
    @IBAction func resendOtpButtonTapped(_ sender: UIButton) {
        guard let email = email else {
            print("❌ Resend OTP failed: Missing email")
            showAlert(message: "User data missing. Please try signing up again.")
            return
        }
        
        ResendOtpbutton.setTitle("Sending...", for: .normal)
        ResendOtpbutton.isEnabled = false
        
        // Use sendPasswordResetOTP to resend OTP (simpler than recreating user)
        UserDataModel.shared.sendPasswordResetOTP(to: email) { [weak self] result in
            DispatchQueue.main.async {
                self?.ResendOtpbutton.setTitle("Resend OTP", for: .normal)
                self?.ResendOtpbutton.isEnabled = true
                
                switch result {
                case .success:
                    print("✅ Resent OTP for email: \(email)")
                    self?.showAlert(message: "A new OTP has been sent.")
                case .failure(let error):
                    print("❌ Resend OTP failed: \(error.localizedDescription)")
                    self?.showAlert(message: "Failed to resend OTP: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        guard let enteredOtp = EnterOtptextfield.text, !enteredOtp.isEmpty else {
            print("❌ Continue tapped: OTP is empty")
            showAlert(message: "Please enter the OTP.")
            return
        }
        
        guard let email = email else {
            print("❌ Continue tapped: Email is missing")
            showAlert(message: "User email missing. Please try signing up again.")
            return
        }
        
        if isValidOtp(enteredOtp) {
            print("🔍 Verifying OTP: \(enteredOtp) for email: \(email)")
            ContinueButton.isEnabled = false
            
            // Verify the OTP
            UserDataModel.shared.verifyUser(email: email, code: enteredOtp) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    print("✅ OTP verified successfully")
                    // Confirm the user in Supabase
                    UserDataModel.shared.confirmUser(email: email) { confirmResult in
                        DispatchQueue.main.async {
                            self.ContinueButton.isEnabled = true
                            switch confirmResult {
                            case .success(let confirmedUser):
                                print("✅ User confirmed: \(confirmedUser.email), ID: \(confirmedUser.id ?? -1)")
                                guard let userId = confirmedUser.id else {
                                    print("❌ No user ID returned from Supabase")
                                    self.showAlert(message: "User confirmed, but no ID assigned. Please try again.")
                                    return
                                }
                                self.navigateToHomeScreen(userId: userId)
                            case .failure(let error):
                                print("❌ Confirm user failed: \(error.localizedDescription)")
                                self.showAlert(message: "Failed to confirm user: \(error.localizedDescription)")
                            }
                        }
                    }
                case .failure(let error):
                    print("❌ OTP verification failed: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.ContinueButton.isEnabled = true
                        self.showAlert(message: "Invalid OTP. Please try again.")
                    }
                }
            }
        } else {
            print("❌ Invalid OTP format: \(enteredOtp)")
            showAlert(message: "Invalid OTP format. Please enter a 4-digit code.")
        }
    }
    
    // Function to validate OTP format
    private func isValidOtp(_ otp: String) -> Bool {
        let otpPattern = "^[0-9]{4}$"
        let otpPredicate = NSPredicate(format: "SELF MATCHES %@", otpPattern)
        return otpPredicate.evaluate(with: otp)
    }
    
    // Function to navigate to the tab bar controller
    private func navigateToHomeScreen(userId: Int) {
        print("🔍 Attempting navigation with userId: \(userId)")
        guard let storyboard = self.storyboard else {
            print("❌ Navigation failed: Storyboard is nil")
            showAlert(message: "Unable to navigate to the home screen.")
            return
        }
        
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "tabbar") as? UITabBarController else {
            print("❌ Navigation failed: Cannot instantiate tab bar controller with identifier 'tabbar'")
            showAlert(message: "Unable to navigate to the home screen.")
            return
        }
        
        // Pass userId to relevant view controllers in the tab bar
        if let viewControllers = tabBarController.viewControllers {
            for viewController in viewControllers {
                if let navController = viewController as? UINavigationController,
                   let rootViewController = navController.viewControllers.first {
                    passUserId(to: rootViewController, userId: userId)
                } else {
                    passUserId(to: viewController, userId: userId)
                }
            }
        }
        
        // Push the tab bar controller
        if let navController = navigationController {
            print("✅ Pushing tab bar controller with userId: \(userId)")
            navController.pushViewController(tabBarController, animated: true)
        } else {
            print("✅ Presenting tab bar controller with userId: \(userId)")
            tabBarController.modalPresentationStyle = .fullScreen
            present(tabBarController, animated: true, completion: nil)
        }
    }
    
    // Helper function to pass userId to supported view controllers
    private func passUserId(to viewController: UIViewController, userId: Int) {
        if let homeVC = viewController as? homeViewController {
            homeVC.userId = userId
            print("✅ UserId passed to homeViewController: \(userId)")
        } else if let splitpalVC = viewController as? SplitpalViewController {
            splitpalVC.userId = userId
            print("✅ UserId passed to SplitpalViewController: \(userId)")
        } else if let censusVC = viewController as? CensusViewController {
            censusVC.userId = userId
            print("✅ UserId passed to CensusViewController: \(userId)")
        } else if let profileVC = viewController as? PersonalInformationViewController {
            profileVC.userId = userId
            print("✅ UserId passed to PersonalInformationViewController: \(userId)")
        }
    }
    
    // Function to show an alert
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
