import UIKit


protocol AddMemberDelegate: AnyObject {
    func didUpdateSelectedMembers(_ members: [Int])
}

class CreateGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddMemberCellDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet var categoryButton: [UIButton]!
    @IBOutlet var creategroupbutton: UIView!
    @IBOutlet weak var Mytable: UITableView!
    @IBOutlet weak var Mysearchtext: UISearchBar!

    let imageNames = ["icons8-holiday-50", "icons8-bunglaw-50", "icons8-kawaii-pizza-50", "icons8-movie-50", "icons8-gym-50-2", "icons8-more-50-2"]
    var selectedImage: UIImage?

    var users: [User] = []       // To hold all users
    var searchUsers: [User] = [] // To hold the filtered users
    var selectedMembers: [Int] = []
    
    var userId : Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("id on the split group page : \(userId)")

          for (index, button) in categoryButton.enumerated() {
            if index < imageNames.count {
                let image = UIImage(named: imageNames[index])
                button.setImage(image, for: .normal)
            }
        }

        users = UserDataModel.shared.getAllUsers()
        
<<<<<<< HEAD
=======

        if let currentUserId = userId {
            selectedMembers.append(currentUserId)
            
            users = users.filter { $0.id != currentUserId }
        }
        
        searchUsers = users

>>>>>>> 80b8729 (new)
        // Automatically add current user to selected members
        if let currentUserId = userId {
            selectedMembers.append(currentUserId)
            
            // Filter out the current user from the displayed users
            users = users.filter { $0.id != currentUserId }
        }
        
        searchUsers = users // Initialize searchUsers with filtered users

        Mytable.delegate = self
        Mytable.dataSource = self
        Mysearchtext.delegate = self
        addSFSymbolToAddMemberButton()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = Mytable.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? AddmemberCellTableViewCell else {
            return UITableViewCell()
        }

        let user = searchUsers[indexPath.row]
        cell.configure(with: user)
        cell.delegate = self // Set the delegate to self
        return cell
    }

    func didTapInviteButton(for user: User) {
        if !selectedMembers.contains(user.id) {
            selectedMembers.append(user.id)
            print("Selected Members: \(selectedMembers)")
        } else {
            selectedMembers.removeAll { $0 == user.id }
            print("Removed Member: \(user.id), Selected Members: \(selectedMembers)")
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchUsers = users // users already has current user filtered out
        } else {
            searchUsers = users.filter { $0.fullname.lowercased().contains(searchText.lowercased()) }
        }
        Mytable.reloadData()
    }

    @IBAction func categoryButtontapped(_ sender: UIButton) {
        for button in categoryButton {
            button.tintColor = .systemGray3
            button.backgroundColor = .clear
        }
        
        sender.tintColor = .systemBlue
        sender.backgroundColor = .lightGray
        selectedImage = sender.image(for: .normal)
        sender.isEnabled = true
    }

    @IBAction func cancelbuttontapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func createGroupButtonTapped(_ sender: Any) {
<<<<<<< HEAD
        
        guard let groupName = textField.text, !groupName.isEmpty, let selectedImage = selectedImage else {
            return
        }
        
=======

        guard let groupName = textField.text, !groupName.isEmpty, let selectedImage = selectedImage else {
            return
        }

        Task {
            do {
                // Check if group exists
                let allGroups = try await GroupDataModel.shared.getAllGroups()
                let groupExists = allGroups.contains { $0.groupName.lowercased() == groupName.lowercased() }
                
                if groupExists {
                    // Show alert on main thread
                    DispatchQueue.main.async {
                        let alert = UIAlertController(
                            title: "Group Already Exists",
                            message: "A group with the name '\(groupName)' already exists. Please choose a different name.",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                    return
                }
                
                // Create group
                GroupDataModel.shared.createGroup(groupName: groupName, category: selectedImage, members: selectedMembers)
                
                // Dismiss view controller
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                print("Error checking groups: \(error)")
            }
        }

>>>>>>> 80b8729 (new)
        // Check if a group with the same name already exists
        let allGroups = GroupDataModel.shared.getAllGroups()
        let groupExists = allGroups.contains { $0.groupName.lowercased() == groupName.lowercased() }
        
        if groupExists {
            // Show an alert to inform the user
            let alert = UIAlertController(
                title: "Group Already Exists",
                message: "A group with the name '\(groupName)' already exists. Please choose a different name.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // If we get here, the group doesn't exist yet, so create it
        GroupDataModel.shared.createGroup(groupName: groupName, category: selectedImage, members: selectedMembers)
        self.dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)

    }




    // MARK: - Segue Preparation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Groupsdetails",
           let destinationVC = segue.destination as? SplitpalViewController {
            destinationVC.selectedImage = selectedImage
        }
    }

    func addSFSymbolToAddMemberButton() {
        if let symbolImage = UIImage(systemName: "person.fill.badge.plus") {
            var config = UIButton.Configuration.plain()
            config.imagePadding = 8
            config.imagePlacement = .leading
        }
    }
}
