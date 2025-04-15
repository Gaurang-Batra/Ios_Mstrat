import UIKit

class SignInSecurityViewController: UIViewController {

    @IBOutlet weak var passwordTextField1: UITextField!  // Current password
    @IBOutlet weak var passwordTextField2: UITextField!  // New password
    @IBOutlet weak var passwordTextField3: UITextField!  // Confirm new password
    @IBOutlet weak var eyeButton1: UIButton!
    @IBOutlet weak var eyeButton2: UIButton!
    @IBOutlet weak var eyeButton3: UIButton!

    var userId: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print ("this id is in the sign-in & security : \(userId)")

        // Set initial password field properties
        passwordTextField1.isSecureTextEntry = true
        passwordTextField2.isSecureTextEntry = true
        passwordTextField3.isSecureTextEntry = true

        // Set initial images for eye buttons
        eyeButton1.setImage(UIImage(named: "icons8-blind-50"), for: .normal)
        eyeButton2.setImage(UIImage(named: "icons8-blind-50"), for: .normal)
        eyeButton3.setImage(UIImage(named: "icons8-blind-50"), for: .normal)

        passwordTextField1.placeholder = "Enter your current password"
        passwordTextField2.placeholder = "Enter your new password"
        passwordTextField3.placeholder = "Re-enter your new password"
    }

    func togglePasswordVisibility(for textField: UITextField, button: UIButton) {
        textField.isSecureTextEntry.toggle()
        let imageName = textField.isSecureTextEntry ? "icons8-blind-50" : "icons8-eye-50"
        button.setImage(UIImage(named: imageName), for: .normal)
    }

    @IBAction func togglePasswordVisibility1(_ sender: UIButton) {
        togglePasswordVisibility(for: passwordTextField1, button: eyeButton1)
    }

    @IBAction func togglePasswordVisibility2(_ sender: UIButton) {
        togglePasswordVisibility(for: passwordTextField2, button: eyeButton2)
    }

    @IBAction func togglePasswordVisibility3(_ sender: UIButton) {
        togglePasswordVisibility(for: passwordTextField3, button: eyeButton3)
    }

    @IBAction func saveAndContinueTapped(_ sender: UIButton) {
        guard let userId = userId else {
            showAlert(title: "Error", message: "User not found.")
            return
        }
        
        // Validate password fields
        guard let currentPassword = passwordTextField1.text, !currentPassword.isEmpty,
              let newPassword = passwordTextField2.text, !newPassword.isEmpty,
              let confirmPassword = passwordTextField3.text, !confirmPassword.isEmpty else {
            showAlert(title: "Error", message: "All fields are required.")
            return
        }

        // Fetch user data to compare current password
        Task {
            if let user = await UserDataModel.shared.getUser(fromSupabaseBy: userId) {
                // Check if current password is correct
                if currentPassword != user.password {
                    self.showAlert(title: "Error", message: "Old password does not match the current password.")
                    return
                }

                // Check if new password and confirmation match
                if newPassword != confirmPassword {
                    self.showAlert(title: "Error", message: "New passwords do not match.")
                    return
                }

                // Update the password in the database (assuming there's a method to do so)
                UserDataModel.shared.updatePassword(userId: userId, newPassword: newPassword) { updateResult in
                    switch updateResult {
                    case .success:
                        self.showAlert(title: "Success", message: "Your password has been changed successfully.")
                    case .failure(let error):
                        self.showAlert(title: "Error", message: "Failed to update password: \(error.localizedDescription)")
                    }
                }

            } else {
                self.showAlert(title: "Error", message: "User not found.")
            }
        }
    }



    // Helper function to show alerts
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
