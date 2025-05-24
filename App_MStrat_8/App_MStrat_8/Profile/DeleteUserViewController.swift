//
//  DeleteUserViewController.swift
//  App_MStrat_8
//
//  Created by Guest1 on 24/05/25.
//
import UIKit

class DeleteUserViewController: UIViewController {
    
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var deleteUserButton: UIButton!
    @IBOutlet weak var eyeButton: UIButton!
    
    var userId: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("this id is in the delete user: \(userId ?? 0)")
        
        // Set initial password field properties
        currentPassword.isSecureTextEntry = true
        currentPassword.placeholder = "Enter your current password"
        
        // Set initial image for eye button
        eyeButton.setImage(UIImage(named: "icons8-blind-50"), for: .normal)
        
        // Configure delete button
        deleteUserButton.setTitle("Delete Account", for: .normal)
    }
    
    func togglePasswordVisibility(for textField: UITextField, button: UIButton) {
        textField.isSecureTextEntry.toggle()
        let imageName = textField.isSecureTextEntry ? "icons8-blind-50" : "icons8-eye-50"
        button.setImage(UIImage(named: imageName), for: .normal)
    }
    
    @IBAction func togglePasswordVisibility(_ sender: UIButton) {
        togglePasswordVisibility(for: currentPassword, button: eyeButton)
    }
    
    @IBAction func deleteUserButtonTapped(_ sender: UIButton) {
        guard let userId = userId else {
            showAlert(title: "Error", message: "User not found.")
            return
        }
        
        // Validate password field
        guard let password = currentPassword.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Password is required.")
            return
        }
        
        // Show confirmation alert before deletion
        let confirmationAlert = UIAlertController(
            title: "Confirm Deletion",
            message: "Are you sure you want to delete your account? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "Yes, Delete", style: .destructive) { _ in
            // Proceed with deletion if confirmed
            Task {
                if let user = await UserDataModel.shared.getUser(fromSupabaseBy: userId) {
                    // Check if password is correct
                    if password != user.password {
                        self.showAlert(title: "Error", message: "Incorrect password.")
                        return
                    }
                    
                    // Attempt to delete user
                    UserDataModel.shared.deleteUser(userId: userId) { deleteResult in
                        switch deleteResult {
                        case .success:
                            self.showAlert(title: "Success", message: "Your account has been deleted successfully.") {
                                self.navigateToLoginScreen()
                            }
                        case .failure(let error):
                            self.showAlert(title: "Error", message: "Failed to delete account: \(error.localizedDescription)")
                        }
                    }
                } else {
                    self.showAlert(title: "Error", message: "User not found.")
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        confirmationAlert.addAction(confirmAction)
        confirmationAlert.addAction(cancelAction)
        
        present(confirmationAlert, animated: true, completion: nil)
    }
    
    // Helper function to show alerts with optional completion
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // Navigate to login screen after deletion
    private func navigateToLoginScreen() {
        if let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = UINavigationController(rootViewController: loginVC)
                window.makeKeyAndVisible()
            }
        }
    }
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


