import UIKit

class SignInSecurityViewController: UIViewController {

    // Outlets for password text fields
    @IBOutlet weak var passwordTextField1: UITextField!  // Current password
    @IBOutlet weak var passwordTextField2: UITextField!  // New password
    @IBOutlet weak var passwordTextField3: UITextField!  // Confirm new password

    // Variables to track password visibility
    @IBOutlet weak var eyeButton1: UIButton!
    @IBOutlet weak var eyeButton2: UIButton!
    @IBOutlet weak var eyeButton3: UIButton!


    var userId: Int?

    // Fetch the stored password (previously set during login)
    var storedPassword: String {
        return UserDefaults.standard.string(forKey: "userPassword") ?? ""
    }
    
<<<<<<< HEAD
    var userId :Int?
=======

>>>>>>> 80b8729 (new)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print ("this id ins int he sign in & securty : \(userId)")

        print("User ID in Sign-In & Security: \(userId )")

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

    // Toggle password visibility
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
        guard let userId = userId,
              var user = UserDataModel.shared.getUser(by: userId) else {
            showAlert(title: "Error", message: "User not found.")
            return
        }

        guard let currentPassword = passwordTextField1.text, !currentPassword.isEmpty,
              let newPassword = passwordTextField2.text, !newPassword.isEmpty,
              let confirmPassword = passwordTextField3.text, !confirmPassword.isEmpty else {
            showAlert(title: "Error", message: "All fields are required.")
            return
        }

        // Check if current password is correct
        if currentPassword != user.password {
            showAlert(title: "Error", message: "Old password does not match the current password.")
            return
        }

        // Check if new password and confirmation match
        if newPassword != confirmPassword {
            showAlert(title: "Error", message: "New passwords do not match.")
            return
        }

        // Update the user's password
        user.password = newPassword
        UserDataModel.shared.updateUser(user)

        showAlert(title: "Success", message: "Your password has been changed successfully.")
    }

    // Helper function to show alerts
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
