import UIKit

class SignUpViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet var circleview: [UIView]!
    @IBOutlet weak var eyebutton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
        
        // Add underline to text fields
        [nameTextField, emailTextField, passwordTextField].forEach {
            addUnderline(to: $0)
            $0?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
        
        // Disable the sign-up button initially
        signUpButton.isEnabled = false
        
        // Make views circular and set light gray color with opacity 0.95
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
        [nameTextField, emailTextField, passwordTextField].forEach {
            addUnderline(to: $0)
        }
    }
    
    // Action for the Sign Up button
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(message: "Please enter your name.")
            return
        }

        guard let email = emailTextField.text, isValidEmail(email) else {
            showAlert(message: "Please enter a valid email address.")
            return
        }

        guard let password = passwordTextField.text, password.count >= 8 else {
            showAlert(message: "Password must be at least 8 characters long.")
            return
        }

        // Check if user with this email or username already exists
        Task {
            let (emailExists, fullnameExists) = await UserDataModel.shared.checkUserExists(email: email, fullname: name)
            if emailExists || fullnameExists {
                var alertMessage = "User with this "
                if emailExists && fullnameExists {
                    alertMessage += "email and username already exists."
                } else if emailExists {
                    alertMessage += "email already exists."
                } else {
                    alertMessage += "username already exists."
                }
                DispatchQueue.main.async {
                    self.showAlert(message: alertMessage)
                }
                return
            }

            // Proceed with user creation
            UserDataModel.shared.createUser(email: email, fullname: name, password: password) { result in
                switch result {
                case .success(let newUser):
                    print("Verification email sent for user: \(newUser.email)")
                    
                    // Perform segue to the verification screen
                    DispatchQueue.main.async { [weak self] in
                        self?.performSegue(withIdentifier: "verifycode", sender: newUser)
                    }
                    
                case .failure(let error):
                    print("Error sending verification email: \(error.localizedDescription)")
                    DispatchQueue.main.async { [weak self] in
                        self?.showAlert(message: "Failed to send verification email: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // Prepare for segue to pass data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "verifycode",
           let verifyVC = segue.destination as? VerifyotpViewController,
           let newUser = sender as? User {
            // Pass user data to verification screen
            verifyVC.email = newUser.email
            verifyVC.fullname = newUser.fullname
            verifyVC.password = newUser.password
            verifyVC.verificationCode = newUser.verification_code
        }
    }
    
    // Helper function to validate email
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // Helper function to show alerts
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Input Required", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // Helper function to add underline to text fields
    private func addUnderline(to textField: UITextField?) {
        guard let textField = textField else { return }
        let underline = CALayer()
        underline.frame = CGRect(x: 0, y: textField.frame.height - 2, width: textField.frame.width, height: 2)
        underline.backgroundColor = UIColor.black.cgColor
        textField.borderStyle = .none
        textField.layer.addSublayer(underline)
    }
    
    // Enable the sign-up button only when all fields are filled
    @objc private func textFieldDidChange() {
        let isFormFilled = !(nameTextField.text?.isEmpty ?? true) &&
                           !(emailTextField.text?.isEmpty ?? true) &&
                           !(passwordTextField.text?.isEmpty ?? true)
        signUpButton.isEnabled = isFormFilled
    }
    
    @IBAction func togglePasswordVisibility3(_ sender: UIButton) {
        togglePasswordVisibility(for: passwordTextField, button: eyebutton)
    }

    // Method to toggle password visibility and change the button image
    func togglePasswordVisibility(for textField: UITextField, button: UIButton) {
        if textField.isSecureTextEntry {
            textField.isSecureTextEntry = false
            button.setImage(UIImage(named: "icons8-eye-50"), for: .normal)
        } else {
            textField.isSecureTextEntry = true
            button.setImage(UIImage(named: "icons8-blind-50"), for: .normal)
        }
    }
}
