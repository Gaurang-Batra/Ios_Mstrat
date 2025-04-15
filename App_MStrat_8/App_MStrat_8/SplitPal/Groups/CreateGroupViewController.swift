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

    var users: [User] = []
    var searchUsers: [User] = [] 
    var selectedMembers: [Int] = []
    
    var userId : Int?

    override func viewDidLoad() {
           super.viewDidLoad()
           print("🧑‍💻 Current user ID on the create group page: \(String(describing: userId))")

           for (index, button) in categoryButton.enumerated() {
               if index < imageNames.count {
                   let image = UIImage(named: imageNames[index])
                   button.setImage(image, for: .normal)
               }
           }

           
           UserDataModel.shared.getAllUsersfromsupabase { [weak self] users, error in
               guard let self = self else { return }

               if let error = error {
                   print("❌ Error fetching users: \(error.localizedDescription)")
                   return
               }

               if let fetchedUsers = users {
                   print("✅ Fetched users: \(fetchedUsers)")

                   
                   if let currentUserId = self.userId {
                       self.selectedMembers.append(currentUserId)
                       self.users = fetchedUsers.filter { $0.id != currentUserId }
                   } else {
                       self.users = fetchedUsers
                   }

                   self.searchUsers = self.users

                   DispatchQueue.main.async {
                       self.Mytable.reloadData()
                   }
               }
           }

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
        cell.delegate = self
        return cell
    }

    func didTapInviteButton(for user: User) {
        if !selectedMembers.contains(user.id ?? 0) {
            selectedMembers.append(user.id ?? 0)
            print("Selected Members: \(selectedMembers)")
        } else {
            selectedMembers.removeAll { $0 == user.id }
            print("Removed Member: \(user.id), Selected Members: \(selectedMembers)")
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchUsers = users
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
        guard let groupName = textField.text,
              !groupName.isEmpty,
              let selectedImage = selectedImage else {
            return
        }

        Task {
            do {
                // Check if group already exists
                let allGroups = GroupDataModel.shared.getAllGroups()
                let groupExists = allGroups.contains { $0.group_name.lowercased() == groupName.lowercased() }

                if groupExists {
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

                // Create a new group object without saving it locally
                if let newGroup = GroupDataModel.shared.createGroup(groupName: groupName, category: selectedImage, members: selectedMembers) {
                    // Save the group to Supabase and get the generated ID
                    if let newGroupId = await GroupDataModel.shared.saveGroupToSupabase(group: newGroup, userId: userId ?? 0) {
                        // Add users to the group in Supabase using the newly created group ID
                        await GroupDataModel.shared.addUsersToGroupInUserGroupsTable(groupId: newGroupId, userIds: selectedMembers)
                        
                        // Step 6: Dismiss the screen
                        DispatchQueue.main.async {
                            self.dismiss(animated: true)
                            self.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        print("❌ Failed to save group to Supabase")
                    }
                } else {
                    print("❌ Failed to create group object")
                }
            } catch {
                print("❌ Error creating group: \(error)")
            }
        }
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
