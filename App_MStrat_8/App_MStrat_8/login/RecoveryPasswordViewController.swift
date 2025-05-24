import UIKit

class RecoveryPasswordViewController: UIViewController {
    
    @IBOutlet weak var resetCodeTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet var circleview: [UIView]! // Keeping property name as circleview

    var email: String?
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActivityIndicator()
    }

    private func setupUI() {
        addUnderline(to: resetCodeTextField)
        addUnderline(to: newPasswordTextField)
        addUnderline(to: confirmPasswordTextField)
        
        // Safely handle circleview outlet
        guard let circleViews = circleview, !circleViews.isEmpty else {
            print("Warning: circleview outlet is not connected or empty in storyboard")
            return
        }
        
        for view in circleViews {
            let size = min(view.frame.width, view.frame.height)
            view.frame.size = CGSize(width: size, height: size)
            view.layer.cornerRadius = size / 2
            view.layer.masksToBounds = true
            view.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        }
        
        // Configure password fields for security
        newPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
    }

    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        activityIndicator.hidesWhenStopped = true
    }

    private func addUnderline(to textField: UITextField) {
        let underline = CALayer()
        underline.frame = CGRect(x: 0, y: textField.frame.height - 2, width: textField.frame.width, height: 2)
        underline.backgroundColor = UIColor.black.cgColor
        textField.borderStyle = .none
        textField.layer.addSublayer(underline)
    }

    @IBAction func sendEmailButtonTapped(_ sender: UIButton) {
        guard let email = email else {
            print("Error: Email not provided")
            showAlert(message: "Email not provided.", isError: true)
            return
        }
        
        guard let resetCode = resetCodeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !resetCode.isEmpty else {
            print("Error: Empty reset code")
            showAlert(message: "Please enter the reset code.", isError: true)
            return
        }
        
        guard resetCode.count == 4, resetCode.allSatisfy({ $0.isNumber }) else {
            print("Error: Invalid OTP format - \(resetCode)")
            showAlert(message: "Please enter a valid 4-digit OTP.", isError: true)
            return
        }
        
        guard let newPassword = newPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !newPassword.isEmpty else {
            print("Error: Empty new password")
            showAlert(message: "Please enter a new password.", isError: true)
            return
        }
        
        guard let confirmPassword = confirmPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), confirmPassword == newPassword else {
            print("Error: Passwords do not match")
            showAlert(message: "Passwords do not match.", isError: true)
            return
        }
        
        // Show loading indicator
        activityIndicator.startAnimating()
        sender.isEnabled = false
        
        // Validate OTP and update password
        Task {
            do {
                if UserDataModel.shared.validateResetOTP(email: email, otp: resetCode) {
                    if let user = try await UserDataModel.shared.getUserByEmail(email) {
                        UserDataModel.shared.updatePassword(userId: user.id ?? -1, newPassword: newPassword) { result in
                            DispatchQueue.main.async {
                                self.activityIndicator.stopAnimating()
                                sender.isEnabled = true
                                switch result {
                                case .success:
                                    UserDataModel.shared.clearResetOTP(email: email)
                                    // Clear text fields for better UX
                                    self.resetCodeTextField.text = ""
                                    self.newPasswordTextField.text = ""
                                    self.confirmPasswordTextField.text = ""
                                    // Show success alert and navigate to LoginViewController
                                    self.showAlert(message: "Password reset successful! You can now log in with your new password.", isError: false) { _ in
                                        print("Success: Password reset for \(email). Navigating to LoginViewController")
                                        if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                                            self.navigationController?.pushViewController(loginVC, animated: true)
                                        } else {
                                            print("Error: Failed to instantiate LoginViewController with storyboard ID")
                                            self.showAlert(message: "Failed to navigate to login screen.", isError: true)
                                        }
                                    }
                                case .failure(let error):
                                    print("Error: Failed to reset password for \(email) - \(error.localizedDescription)")
                                    self.showAlert(message: "Failed to reset password: \(error.localizedDescription)", isError: true)
                                }
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            sender.isEnabled = true
                            print("Error: No user found for email \(email)")
                            self.showAlert(message: "User not found.", isError: true)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        sender.isEnabled = true
                        print("Error: Invalid OTP for email \(email)")
                        self.showAlert(message: "Invalid OTP.", isError: true)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    sender.isEnabled = true
                    print("Error: Failed to process request for email \(email) - \(error.localizedDescription)")
                    self.showAlert(message: "Failed to process request. Please try again later.", isError: true)
                }
            }
        }
    }

    private func showAlert(message: String, isError: Bool, completion: ((UIAlertAction) -> Void)? = nil) {
        let title = isError ? "Error" : "Success"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alert, animated: true, completion: nil)
    }
}
