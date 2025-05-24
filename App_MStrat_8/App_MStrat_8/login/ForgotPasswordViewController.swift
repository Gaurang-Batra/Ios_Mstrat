import UIKit

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet var circleview: [UIView]!
    @IBOutlet weak var sendButton: UIButton!

    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActivityIndicator()
        setupTextField()
    }

    private func setupUI() {
        addUnderline(to: emailTextField)

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

        sendButton.isEnabled = false
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

    private func setupTextField() {
        emailTextField.delegate = self
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        emailTextField.autocapitalizationType = .none
        emailTextField.keyboardType = .emailAddress
    }

    private func addUnderline(to textField: UITextField) {
        let underline = CALayer()
        underline.frame = CGRect(x: 0, y: textField.frame.height - 2, width: textField.frame.width, height: 2)
        underline.backgroundColor = UIColor.black.cgColor
        textField.borderStyle = .none
        textField.layer.addSublayer(underline)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let email = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty {
            let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            sendButton.isEnabled = emailPredicate.evaluate(with: email)
        } else {
            sendButton.isEnabled = false
        }
    }

    @IBAction func sendEmailButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty else {
            print("Error: Empty email field")
            showAlert(message: "Please enter your email.", isError: true)
            return
        }

        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: email) else {
            print("Error: Invalid email format - \(email)")
            showAlert(message: "Please enter a valid email address.", isError: true)
            return
        }

        activityIndicator.startAnimating()
        sendButton.isEnabled = false

        Task {
            do {
                if let _ = try await UserDataModel.shared.getUserByEmail(email) {
                    UserDataModel.shared.sendPasswordResetOTP(to: email) { result in
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            self.sendButton.isEnabled = true

                            switch result {
                            case .success:
                                // Clear email text field for better UX
                                self.emailTextField.text = ""
                                // Show success alert and navigate to RecoveryPasswordViewController
                                self.showAlert(message: "OTP sent successfully to \(email). Please check your email to proceed.", isError: false) { _ in
                                    print("Success: OTP sent to \(email). Navigating to RecoveryPasswordViewController")
                                    if let recoveryVC = self.storyboard?.instantiateViewController(withIdentifier: "RecoveryPasswordViewController") as? RecoveryPasswordViewController {
                                        recoveryVC.email = email
                                        self.navigationController?.pushViewController(recoveryVC, animated: true)
                                    } else {
                                        print("Error: Failed to instantiate RecoveryPasswordViewController with storyboard ID")
                                        self.showAlert(message: "Failed to navigate to password recovery screen.", isError: true)
                                    }
                                }
                            case .failure(let error):
                                print("Error: Failed to send OTP to \(email) - \(error.localizedDescription)")
                                self.showAlert(message: "Failed to send OTP. Please try again.", isError: true)
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.sendButton.isEnabled = true
                        print("Error: No account found for email \(email)")
                        self.showAlert(message: "No account found with this email.", isError: true)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.sendButton.isEnabled = true
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
        present(alert, animated: false, completion: nil)
    }
}
