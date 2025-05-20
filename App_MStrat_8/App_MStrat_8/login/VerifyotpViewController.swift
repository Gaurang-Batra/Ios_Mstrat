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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Log entry for debugging
        print("🔍 VerifyotpViewController loaded with email: \(email ?? "nil")")
        
        // Set up the OTP text field
        EnterOtptextfield.placeholder = "Enter OTP"
        addUnderline(to: EnterOtptextfield)
        EnterOtptextfield.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        // Disable the Continue button initially
        ContinueButton.isEnabled = false
        
        // Configure circle views with animations
        for (index, view) in circleview.enumerated() {
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
        guard let email = email, let fullname = fullname, let password = password else {
            print("❌ Resend OTP failed: Missing user data")
            showAlert(message: "User data missing. Please try signing up again.")
            return
        }
        
        ResendOtpbutton.setTitle("Sending...", for: .normal)
        ResendOtpbutton.isEnabled = false
        
        UserDataModel.shared.createUser(email: email, fullname: fullname, password: password) { result in
            DispatchQueue.main.async { [weak self] in
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
            // Disable button to prevent multiple taps
            ContinueButton.isEnabled = false
            // Verify the OTP
            UserDataModel.shared.verifyUser(email: email, code: enteredOtp) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    print("✅ OTP verified successfully")
                    // OTP verified, now confirm the user in Supabase
                    print("🔍 Waiting for Supabase to confirm user")
                    UserDataModel.shared.confirmUser(email: email) { confirmResult in
                        DispatchQueue.main.async {
                            // Re-enable button
                            self.ContinueButton.isEnabled = true
                            switch confirmResult {
                            case .success(let confirmedUser):
                                print("✅ User confirmed: \(confirmedUser.email), ID: \(confirmedUser.id ?? -1)")
                                guard let userId = confirmedUser.id else {
                                    print("❌ No user ID returned from Supabase")
                                    self.showAlert(message: "User confirmed, but no ID assigned. Please try again.")
                                    return
                                }
                                print("✅ Successfully retrieved userId: \(userId) from Supabase")
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
                        self.showAlert(message: "Invalid OTP: \(error.localizedDescription)")
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
    
    // Function to navigate to the home screen with userId
    private func navigateToHomeScreen(userId: Int) {
        print("🔍 Attempting navigation with userId: \(userId)")
        guard let storyboard = storyboard else {
            print("❌ Navigation failed: Storyboard is nil")
            showAlert(message: "Unable to navigate to the home screen.")
            return
        }
        
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "tabbar") as? UITabBarController else {
            print("❌ Navigation failed: Cannot instantiate tab bar controller with identifier 'tabbar'")
            showAlert(message: "Unable to navigate to the home screen.")
            return
        }
        
        guard let viewControllers = tabBarController.viewControllers else {
            print("❌ Navigation failed: Tab bar controller has no view controllers")
            showAlert(message: "Unable to navigate to the home screen.")
            return
        }
        
        for (index, viewController) in viewControllers.enumerated() {
            if let navController = viewController as? UINavigationController,
               let rootViewController = navController.viewControllers.first {
                if let homeVC = rootViewController as? homeViewController {
                    homeVC.userId = userId
                    print("✅ UserId passed to homeViewController at index \(index): \(userId)")
                }
                if let splitpalVC = rootViewController as? SplitpalViewController {
                    splitpalVC.userId = userId
                    print("✅ UserId passed to SplitpalViewController at index \(index): \(userId)")
                }
                if let censusVC = rootViewController as? CensusViewController {
                    censusVC.userId = userId
                    print("✅ UserId passed to CensusViewController at index \(index): \(userId)")
                }
                if let profileVC = rootViewController as? PersonalInformationViewController {
                    profileVC.userId = userId
                    print("✅ UserId passed to PersonalInformationViewController at index \(index): \(userId)")
                }
            } else {
                if let homeVC = viewController as? homeViewController {
                    homeVC.userId = userId
                    print("✅ UserId passed to homeViewController at index \(index): \(userId)")
                }
                if let splitpalVC = viewController as? SplitpalViewController {
                    splitpalVC.userId = userId
                    print("✅ UserId passed to SplitpalViewController at index \(index): \(userId)")
                }
                if let censusVC = viewController as? CensusViewController {
                    censusVC.userId = userId
                    print("✅ UserId passed to CensusViewController at index \(index): \(userId)")
                }
                if let profileVC = viewController as? PersonalInformationViewController {
                    profileVC.userId = userId
                    print("✅ UserId passed to PersonalInformationViewController at index \(index): \(userId)")
                }
            }
        }
        
        // Navigate to the main app
        if let navController = navigationController {
            print("✅ Navigating via push to tab bar controller with userId: \(userId)")
            navController.pushViewController(tabBarController, animated: true)
        } else {
            print("✅ Navigating via present to tab bar controller with userId: \(userId)")
            tabBarController.modalPresentationStyle = .fullScreen
            present(tabBarController, animated: true)
        }
    }
    
    // Function to show an alert
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
