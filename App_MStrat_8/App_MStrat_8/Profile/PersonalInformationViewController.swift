import UIKit

class PersonalInformationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileimage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    let identities = ["a", "b", "c"]
    var val = ["Personal Information", "Sign In & Security", "Privacy Policy"]
    
    var userId: Int?

    override func viewDidLoad()  {
        super.viewDidLoad()
        
        print("This is on the profile page with userId: \(userId ?? -1)")

      
        if let userId = userId {
                Task {
                    if let user = await UserDataModel.shared.getUser(fromSupabaseBy: userId) {
                        nameLabel.text = user.fullname
                    } else {
                        nameLabel.text = "User Not Found"
                    }
                }
            }
        
        configureProfileImage()
        configureSignOutButton()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNameUpdate(notification:)),
            name: Notification.Name("NameUpdated"),
            object: nil
        )
    }

    func configureProfileImage() {
        profileimage.layer.cornerRadius = profileimage.frame.size.width / 2
        profileimage.clipsToBounds = true
        profileimage.contentMode = .scaleAspectFill
    }

    func configureSignOutButton() {
        signOutButton.setTitle("Sign Out", for: .normal)
        signOutButton.setTitleColor(.white, for: .normal)
        signOutButton.backgroundColor = UIColor.systemRed
        signOutButton.layer.cornerRadius = 8
    }

    @objc func handleNameUpdate(notification: Notification) {
        if let newName = notification.userInfo?["newName"] as? String {
            nameLabel.text = newName
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("NameUpdated"), object: nil)
    }

    @IBAction func profilebuttonedit(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self

        let alertController = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
            alertController.addAction(cameraAction)
        }

        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }
            alertController.addAction(photoLibraryAction)
        }

        present(alertController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        profileimage.image = selectedImage
        dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return val.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
        cell.textLabel?.text = val[indexPath.row]
        switch indexPath.row {
        case 0:
            cell.imageView?.image = UIImage(named: "icons8-user-50")
        case 1:
            cell.imageView?.image = UIImage(named: "icons8-security-lock-50")
        case 2:
            cell.imageView?.image = UIImage(named: "icons8-privacy-policy-50")
        default:
            cell.imageView?.image = nil
        }
        return cell
    }

    @IBAction func goToLoginScreenButtonTapped(_ sender: UIButton) {
        Task {
            if let userId = userId,
               let user = await UserDataModel.shared.getUser(fromSupabaseBy: userId),
               user.is_guest == true {
                do {
                    try await SupabaseAPIClient.shared.supabaseClient
                        .from("users")
                        .delete()
                        .eq("id", value: userId)
                        .execute()
                    print("🗑️ Guest user deleted from Supabase")
                } catch {
                    print("❌ Failed to delete guest user: \(error)")
                }
            }

            if let loginVC = storyboard?.instantiateViewController(withIdentifier: "Openpage") as? SplashViewController {
                let navigationController = UINavigationController(rootViewController: loginVC)
                navigationController.setNavigationBarHidden(true, animated: false)
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController = navigationController
            }
        }
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vcname = identities[indexPath.row]
        
        if let viewController = storyboard?.instantiateViewController(withIdentifier: vcname) {
            // For "Personal Information" (a) and "Sign In & Security" (b)
            if indexPath.row == 0 {
                // Explicitly cast to the correct type for Personal Information
                if let personalInfoVC = viewController as? PersonalInfoViewController {
                    personalInfoVC.userId = self.userId
                    print("Passing userId: \(userId ?? -1) to \(val[indexPath.row]) screen")
                }
            } else if indexPath.row == 1 {
                // For other screens, try setting via property - you'll need to add explicit casting here for those view controllers too
                if let securityVC = viewController as? SignInSecurityViewController {  // Replace with your actual class
                    securityVC.userId = self.userId
                    print("Passing userId: \(userId ?? -1) to \(val[indexPath.row]) screen")
                }
            }
            
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
