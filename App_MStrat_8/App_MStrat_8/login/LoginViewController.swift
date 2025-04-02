import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet var circleview: [UIView]!
    
    @IBOutlet weak var eyebutton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
        
        // Add underline to text fields
        addUnderline(to: emailTextField)
        addUnderline(to: passwordTextField)
        
        // Set up text field targets to monitor changes
        [emailTextField, passwordTextField].forEach {
            $0?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
        
        // Initially disable the login button
        loginButton.isEnabled = false
        loginButton.alpha = 0.5
        
        // Make circle views properly circular and set them to light grey with opacity 0.95
        for (index, view) in circleview.enumerated() {
            let size = min(view.frame.width, view.frame.height)
            view.frame.size = CGSize(width: size, height: size)
            view.layer.cornerRadius = size / 2
            view.layer.masksToBounds = true
            
            // Set the background color to light gray with opacity 0.95
            view.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
            
            // Add bounce animation with a slight delay for each circle
//            addBounceAnimation(to: view, delay: Double(index) * 0.3)
        }
    }
    
    // Add animation to each circle (bounce effect)
//    private func addBounceAnimation(to view: UIView, delay: TimeInterval) {
//        // Create the bounce animation
//        let animation = CABasicAnimation(keyPath: "transform.scale")
//        animation.fromValue = 1.0
//        animation.toValue = 1.1
//        animation.duration = 0.8
//        animation.autoreverses = true
//        animation.repeatCount = .infinity
//        animation.beginTime = CACurrentMediaTime() + delay
//
//        // Add animation to the layer
//        view.layer.add(animation, forKey: "bounce")
//    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addUnderline(to: emailTextField)
        addUnderline(to: passwordTextField)
    }
    
    // Function to add underline to a text field
    private func addUnderline(to textField: UITextField) {
        let underline = CALayer()
        underline.frame = CGRect(x: 0, y: textField.frame.height - 2, width: textField.frame.width, height: 2)
        underline.backgroundColor = UIColor.black.cgColor
        textField.borderStyle = .none
        textField.layer.addSublayer(underline)
    }
    
    // Enable the login button when all fields are filled
    @objc private func textFieldDidChange() {
        let isFormFilled = !(emailTextField.text?.isEmpty ?? true) &&
                           !(passwordTextField.text?.isEmpty ?? true)
        loginButton.isEnabled = isFormFilled
        loginButton.alpha = isFormFilled ? 1.0 : 0.5
    }
    
  
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
  
            guard let email = emailTextField.text, !email.isEmpty else {
                showAlert(message: "Please enter your email.")
                return
            }

            guard let password = passwordTextField.text, !password.isEmpty else {
                showAlert(message: "Please enter your password.")
                return
            }

             if let user = UserDataModel.shared.getAllUsers().first(where: { $0.email == email && $0.password == password }) {
                print("User found: \(user.fullname) \(user.id)")

                guard let storyboard = storyboard else { return }

                if let tabBarController = storyboard.instantiateViewController(withIdentifier: "tabbar") as? UITabBarController,
                   let viewControllers = tabBarController.viewControllers {
                    
                    for (index, viewController) in viewControllers.enumerated() {
                        // Handle navigation controllers if needed
                        if let navController = viewController as? UINavigationController,
                           let rootViewController = navController.viewControllers.first {
                            
                            if let homeVC = rootViewController as? homeViewController {
                                homeVC.userId = user.id
                                print("UserId passed to homeViewController at index \(index): \(user.id)")
                            }
                            if let homeVC = rootViewController as? SplitpalViewController {
                                homeVC.userId = user.id
                                print("UserId passed to SplitpalViewController at index \(index): \(user.id)")
                            }
                            if let homeVC = rootViewController as? CensusViewController {
                                homeVC.userId = user.id
                                print("UserId passed to CensusViewController at index \(index): \(user.id)")
                            }
                            
                            
                            if let profileVC = rootViewController as? PersonalInformationViewController {
                                profileVC.userId = user.id
                                print("UserId passed to PersonalInformationViewController at index \(index): \(user.id)")
                            }
                        } else {
                            if let homeVC = viewController as? homeViewController {
                                homeVC.userId = user.id
                                print("UserId passed to homeViewController at index \(index): \(user.id)")
                            }
                            if let homeVC = viewController as? SplitpalViewController {
                                homeVC.userId = user.id
                                print("UserId passed to SplitpalViewController at index \(index): \(user.id)")
                            }
                            if let homeVC = viewController as? CensusViewController {
                                homeVC.userId = user.id
                                print("UserId passed to CensusViewController at index \(index): \(user.id)")
                            }
                            
                            
                            
                            if let profileVC = viewController as? PersonalInformationViewController {
                                profileVC.userId = user.id
                                print("UserId passed to PersonalInformationViewController at index \(index): \(user.id)")
                            }
                        }
                    }

                    // Present the tab bar controller (or push it if within a navigation controller)
                    if let navController = navigationController {
                        navController.pushViewController(tabBarController, animated: true)
                    } else {
                        // If there's no navigation controller, present it modally
                        tabBarController.modalPresentationStyle = .fullScreen
                        present(tabBarController, animated: true)
                    }
                }
            } else {
                showAlert(message: "Invalid email or password.")
            }
        
//        guard let email = emailTextField.text, !email.isEmpty else {
//            showAlert(message: "Please enter your email.")
//            return
//        }
//
//        guard let password = passwordTextField.text, !password.isEmpty else {
//            showAlert(message: "Please enter your password.")
//            return
//        }
//
//        // Try to find the user with matching email and password
//        if let user = UserDataModel.shared.getAllUsers().first(where: { $0.email == email && $0.password == password }) {
//            print("User found: \(user.fullname) \(user.id)")
//
//            guard let storyboard = storyboard else { return }
//
//            // Instantiate the UITabBarController using its identifier "tabBar"
//            if let tabBarController = storyboard.instantiateViewController(withIdentifier: "tabbar") as? UITabBarController {
<<<<<<< HEAD
//                
//                // Access the view controllers inside the UITabBarController
//                if let viewControllers = tabBarController.viewControllers {
//                    
=======
//
//                // Access the view controllers inside the UITabBarController
//                if let viewControllers = tabBarController.viewControllers {
//
>>>>>>> 80b8729 (new)
//                    // 1. Set the userId for Home View (first view controller)
//                    if let homeScreenVC = viewControllers.first(where: { $0 is homeViewController }) as? homeViewController {
//                        homeScreenVC.userId = user.id
//                        print("UserId passed to homeScreenVC: \(homeScreenVC.userId ?? -1)")
//                    }
<<<<<<< HEAD
//                    
=======
//
>>>>>>> 80b8729 (new)
//                    // 2. Set the userId for Profile View (second view controller)
//                    if let profileVC = viewControllers.first(where: { $0 is PersonalInformationViewController }) as? PersonalInformationViewController {
//                        profileVC.userId = user.id
//                        print("UserId passed to profileVC: \(profileVC.userId ?? -1)")
//                    }
//                }
//
//                // Push the UITabBarController onto the navigation stack
//                navigationController?.pushViewController(tabBarController, animated: true)
//
//            }
//
//        } else {
//            showAlert(message: "Invalid email or password.")
//        }
    }






    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Input Required", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func togglePasswordVisibility3(_ sender: UIButton) {
        togglePasswordVisibility(for: passwordTextField, button: eyebutton)
    }

    // Method to toggle password visibility and change the button image
    func togglePasswordVisibility(for textField: UITextField, button: UIButton) {
        if textField.isSecureTextEntry {
            // If the text is currently hidden (dots), show it
            textField.isSecureTextEntry = false
            button.setImage(UIImage(named: "icons8-eye-50"), for: .normal)
        } else {
            // If the text is currently visible, hide it (dots)
            textField.isSecureTextEntry = true
            button.setImage(UIImage(named: "icons8-blind-50"), for: .normal)
        }
    }
}
