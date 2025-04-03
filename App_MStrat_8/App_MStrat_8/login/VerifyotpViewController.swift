import UIKit

class VerifyotpViewController: UIViewController {

    // Outlets
    @IBOutlet weak var EnterOtptextfield: UITextField!
    @IBOutlet weak var ResendOtpbutton: UIButton!
    @IBOutlet weak var ContinueButton: UIButton!
    @IBOutlet var circleview: [UIView]!
    
    var userId: Int?  // Store user ID

    override func viewDidLoad() {
        super.viewDidLoad()

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
        ResendOtpbutton.setTitle("Sending...", for: .normal)
        ResendOtpbutton.isEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.ResendOtpbutton.setTitle("Resend OTP", for: .normal)
            self.ResendOtpbutton.isEnabled = true
            self.showAlert(message: "A new OTP has been sent.")
        }
    }

    @IBAction func continueButtonTapped(_ sender: UIButton) {
        guard let enteredOtp = EnterOtptextfield.text, !enteredOtp.isEmpty else {
            showAlert(message: "Please enter the OTP.")
            return
        }

        if isValidOtp(enteredOtp) {
            navigateToHomeScreen()
        } else {
            showAlert(message: "Invalid OTP. Please retry.")
        }
    }

    // Function to validate OTP format
    private func isValidOtp(_ otp: String) -> Bool {
        let otpPattern = "^[0-9]{4}$"
        let otpPredicate = NSPredicate(format: "SELF MATCHES %@", otpPattern)
        return otpPredicate.evaluate(with: otp)
    }

    // Function to navigate to the home screen with userId
    private func navigateToHomeScreen() {
        guard let storyboard = storyboard,
              let tabBarController = storyboard.instantiateViewController(withIdentifier: "tabbar") as? UITabBarController,
              let viewControllers = tabBarController.viewControllers else {
            showAlert(message: "Unable to navigate to the home screen.")
            return
        }

        for (index, viewController) in viewControllers.enumerated() {
            if let navController = viewController as? UINavigationController,
               let rootViewController = navController.viewControllers.first {

                if let homeVC = rootViewController as? homeViewController {
                    homeVC.userId = userId
                    print("UserId passed to homeViewController at index \(index): \(userId!)")
                }
                if let splitpalVC = rootViewController as? SplitpalViewController {
                    splitpalVC.userId = userId
                    print("UserId passed to SplitpalViewController at index \(index): \(userId!)")
                }
                if let censusVC = rootViewController as? CensusViewController {
                    censusVC.userId = userId
                    print("UserId passed to CensusViewController at index \(index): \(userId!)")
                }
                if let profileVC = rootViewController as? PersonalInformationViewController {
                    profileVC.userId = userId
                    print("UserId passed to PersonalInformationViewController at index \(index): \(userId!)")
                }
            } else {
                if let homeVC = viewController as? homeViewController {
                    homeVC.userId = userId
                    print("UserId passed to homeViewController at index \(index): \(userId!)")
                }
                if let splitpalVC = viewController as? SplitpalViewController {
                    splitpalVC.userId = userId
                    print("UserId passed to SplitpalViewController at index \(index): \(userId!)")
                }
                if let censusVC = viewController as? CensusViewController {
                    censusVC.userId = userId
                    print("UserId passed to CensusViewController at index \(index): \(userId!)")
                }
                if let profileVC = viewController as? PersonalInformationViewController {
                    profileVC.userId = userId
                    print("UserId passed to PersonalInformationViewController at index \(index): \(userId!)")
                }
            }
        }

        // Navigate to the main app
        if let navController = navigationController {
            navController.pushViewController(tabBarController, animated: true)
        } else {
            tabBarController.modalPresentationStyle = .fullScreen
            present(tabBarController, animated: true)
        }
    }

    // Function to show an alert
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
