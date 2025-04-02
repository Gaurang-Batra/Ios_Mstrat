import UIKit

class VerifyotpViewController: UIViewController {

    // Outlets
    @IBOutlet weak var EnterOtptextfield: UITextField!
    @IBOutlet weak var ResendOtpbutton: UIButton!
    @IBOutlet weak var ContinueButton: UIButton!
    @IBOutlet var circleview: [UIView]!

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
//            addBounceAnimation(to: view, delay: Double(index) * 0.3)
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

    // Function to navigate to the home screen
    private func navigateToHomeScreen() {
        guard let homeScreenVC = storyboard?.instantiateViewController(withIdentifier: "tabbar") else {
            showAlert(message: "Unable to navigate to the home screen.")
            return
        }
        navigationController?.pushViewController(homeScreenVC, animated: true)
    }

    // Function to show an alert
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // Function to add bounce animation to a view
//    private func addBounceAnimation(to view: UIView, delay: TimeInterval) {
//        let animation = CABasicAnimation(keyPath: "transform.scale")
//        animation.fromValue = 1.0
//        animation.toValue = 1.1
//        animation.duration = 0.8
//        animation.autoreverses = true
//        animation.repeatCount = .infinity
//        animation.beginTime = CACurrentMediaTime() + delay
//        view.layer.add(animation, forKey: "bounce")
//    }
}
