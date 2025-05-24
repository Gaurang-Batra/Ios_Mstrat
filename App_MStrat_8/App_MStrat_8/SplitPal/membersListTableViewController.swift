//
//  membersListTableViewController.swift
//  App_MStrat_8
//
import UIKit

class MembersListTableViewController: UITableViewController {
    
    var groupId: Int? // Group ID to fetch members from user_groups
    var currentUserId: Int? // Current user's ID for sending invitations
    private var members: [Int] = [] // Store member IDs fetched from user_groups
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the table view cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // Add the green plus button in the navigation bar
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        addButton.tintColor = .green
        navigationItem.rightBarButtonItem = addButton
        
        // Fetch members from user_groups
        fetchMembers()
    }
    
    // MARK: - Helper Functions
    
    private func fetchMembers() {
        guard let groupId = groupId else {
            print("❌ No group ID provided")
            members = []
            tableView.reloadData()
            return
        }
        
        GroupDataModel.shared.fetchGroupMembers(groupId: groupId, includeUserDetails: false) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let memberIds):
                    self.members = (memberIds as? [Int]) ?? []
                    print("✅ Fetched \(self.members.count) members for group \(groupId): \(self.members)")
                    self.tableView.reloadData()
                case .failure(let error):
                    print("❌ Error fetching group members: \(error)")
                    self.members = []
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Add Button Action
    
    @objc func addButtonTapped() {
        let alert = UIAlertController(title: "Add New Member", message: "Enter user's full name", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Full Name"
            textField.keyboardType = .default // Allow text input for names
            textField.autocapitalizationType = .words // Capitalize words for names
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            guard let textField = alert.textFields?.first,
                  let fullName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !fullName.isEmpty,
                  let groupId = self.groupId else {
                print("❌ Invalid input or group ID")
                self.showAlert(message: "Please enter a valid name.", isError: true)
                return
            }
            
            // Get current user ID (must be passed explicitly)
            guard let currentUserId = self.currentUserId else {
                print("❌ Current user ID not available")
                self.showAlert(message: "You must be logged in to send invitations.", isError: true)
                return
            }
            
            Task {
                // Fetch all users to find the one with the matching name
                UserDataModel.shared.getAllUsersfromsupabase { users, error in
                    if let error = error {
                        print("❌ Error fetching users: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.showAlert(message: "Failed to fetch users. Please try again.", isError: true)
                        }
                        return
                    }
                    
                    guard let users = users else {
                        print("❌ No users returned")
                        DispatchQueue.main.async {
                            self.showAlert(message: "No users found. Please try again.", isError: true)
                        }
                        return
                    }
                    
                    // Find users with the exact full name (case-insensitive)
                    let matchingUsers = users.filter { $0.fullname.lowercased() == fullName.lowercased() }
                    
                    if matchingUsers.isEmpty {
                        print("❌ No user found with name '\(fullName)'")
                        DispatchQueue.main.async {
                            self.showAlert(message: "No user found with the name '\(fullName)'.", isError: true)
                        }
                        return
                    }
                    
                    if matchingUsers.count > 1 {
                        print("❌ Multiple users found with name '\(fullName)'")
                        DispatchQueue.main.async {
                            self.showAlert(message: "Multiple users found with the name '\(fullName)'. Please contact support.", isError: true)
                        }
                        return
                    }
                    
                    let invitedUser = matchingUsers.first!
                    guard let invitedUserId = invitedUser.id else {
                        print("❌ Invited user has no ID")
                        DispatchQueue.main.async {
                            self.showAlert(message: "Invalid user data. Please try again.", isError: true)
                        }
                        return
                    }
                    
                    // Prevent inviting the current user
                    if invitedUserId == currentUserId {
                        print("❌ Cannot invite yourself")
                        DispatchQueue.main.async {
                            self.showAlert(message: "You cannot invite yourself.", isError: true)
                        }
                        return
                    }
                    
                    // Prevent inviting an existing member
                    if self.members.contains(invitedUserId) {
                        print("❌ User \(invitedUserId) is already a member")
                        DispatchQueue.main.async {
                            self.showAlert(message: "\(fullName) is already a member of this group.", isError: true)
                        }
                        return
                    }
                    
                    // Prevent inviting a guest user
                    if invitedUser.is_guest == true {
                        print("❌ Cannot invite guest user '\(fullName)'")
                        DispatchQueue.main.async {
                            self.showAlert(message: "Cannot invite guest users.", isError: true)
                        }
                        return
                    }
                    
                    // Fetch group for the invitation
                    Task {
                        guard let group = await GroupDataModel.shared.fetchGroupById(groupId: groupId) else {
                            print("❌ Group not found for group ID \(groupId)")
                            DispatchQueue.main.async {
                                self.showAlert(message: "Failed to fetch group details. Please try again.", isError: true)
                            }
                            return
                        }
                        
                        let groupName = group.group_name
                        
                        // Send invitation
                        let success = await GroupDataModel.shared.createInvitationNotification(
                            recipientId: invitedUserId,
                            groupId: groupId,
                            groupName: groupName,
                            inviterId: currentUserId
                        )
                        
                        DispatchQueue.main.async {
                            if success {
                                print("✅ Invitation sent to user \(invitedUserId) (\(fullName)) for group \(groupId)")
                                self.showAlert(message: "Invitation sent to \(fullName) successfully.", isError: false) { _ in
                                    // Refresh members in case the user accepts the invitation later
                                    self.fetchMembers()
                                }
                            } else {
                                print("❌ Failed to send invitation to user \(invitedUserId) (\(fullName))")
                                self.showAlert(message: "Failed to send invitation to \(fullName). Please try again.", isError: true)
                            }
                        }
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    // MARK: - Remove Button Action
    
    @objc func removeButtonTapped(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let memberId = members[indexPath.row]
        
        Task {
            if let user = await UserDataModel.shared.getUser(fromSupabaseBy: memberId) {
                await MainActor.run {
                    self.showConfirmationAlert(forUserId: memberId, name: user.fullname, at: indexPath)
                }
            } else {
                print("❌ No user found for memberId \(memberId)")
                DispatchQueue.main.async {
                    self.showAlert(message: "User not found.", isError: true)
                }
            }
        }
    }
    
    private func showConfirmationAlert(forUserId userId: Int, name: String, at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Confirm Removal", message: "Are you sure you want to remove \(name)?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let confirmAction = UIAlertAction(title: "Confirm", style: .destructive) { _ in
            guard let groupId = self.groupId else { return }
            Task {
                do {
                    let client = SupabaseAPIClient.shared.supabaseClient
                    try await client
                        .database
                        .from("user_groups")
                        .delete()
                        .eq("group_id", value: groupId)
                        .eq("user_id", value: userId)
                        .execute()
                    print("✅ Removed user \(userId) from group \(groupId)")
                    self.fetchMembers() // Refresh member list
                } catch {
                    print("❌ Error removing user from group: \(error)")
                    DispatchQueue.main.async {
                        self.showAlert(message: "Failed to remove user: \(error.localizedDescription)", isError: true)
                    }
                }
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        present(alert, animated: true)
    }
    
    // MARK: - Alert Helper
    
    private func showAlert(message: String, isError: Bool, completion: ((UIAlertAction) -> Void)? = nil) {
        let title = isError ? "Error" : "Success"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alert, animated: true)
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // Only "Members" section
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Members count: \(members.count)")
        return members.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Members"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let memberId = members[indexPath.row]
        
        Task {
            if let user = await UserDataModel.shared.getUser(fromSupabaseBy: memberId) {
                await MainActor.run {
                    var content = cell.defaultContentConfiguration()
                    content.text = user.fullname
                    content.secondaryText = user.email
                    cell.contentConfiguration = content
                }
            } else {
                print("❌ No user found for memberId \(memberId)")
                await MainActor.run {
                    var content = cell.defaultContentConfiguration()
                    content.text = "Unknown User"
                    content.secondaryText = nil
                    cell.contentConfiguration = content
                }
            }
        }
        
        let removeButton = UIButton(type: .custom)
        removeButton.setTitle("x", for: .normal)
        removeButton.setTitleColor(.red, for: .normal)
        removeButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        removeButton.tag = indexPath.row
        removeButton.addTarget(self, action: #selector(removeButtonTapped(_:)), for: .touchUpInside)
        cell.accessoryView = removeButton
        
        return cell
    }
}
//
//class MembersListTableViewController: UITableViewController {
//
//    // Filtered members based on ismember flag
////    var members: [Member] {
////        return globalMembers.filter { $0.ismember }
////    }
////
////    var invited: [Member] {
////        return globalMembers.filter { !$0.ismember }
////    }
////    
//    var members : [Int] = []
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Register the table view cell
//        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
//        
//        // Add the green plus button in the navigation bar
//        let addButton = UIBarButtonItem(
//            barButtonSystemItem: .add,
//            target: self,
//            action: #selector(addButtonTapped)
//        )
//        addButton.tintColor = .green // Set the button color to green
//        self.navigationItem.rightBarButtonItem = addButton
//    }
//
//    // MARK: - Add Button Action
//    @objc func addButtonTapped() {
//        // For now, we'll just show an alert when the button is tapped.
//        let alert = UIAlertController(title: "Add New Member", message: "Choose member type", preferredStyle: .alert)
//        
//        let addMemberAction = UIAlertAction(title: "Add Member", style: .default) { _ in
//            // Handle adding a new member here
//            print("Add Member tapped")
//            // Show your member addition screen or handle member creation here
//        }
//        
//        let addInvitedAction = UIAlertAction(title: "Add Invited", style: .default) { _ in
//            // Handle adding a new invited person here
//            print("Add Invited tapped")
//            // Show your invited person addition screen or handle invited creation here
//        }
//
//        alert.addAction(addMemberAction)
//        alert.addAction(addInvitedAction)
//        
//        self.present(alert, animated: true, completion: nil)
//    }
//
//    // MARK: - Table view data source
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // Return the number of sections: 2 (members and invited)
//        return 2
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // Return the count for each section
//        if section == 0 {
//            return members.count // For members
//        }
//        else {
//            return invited.count // For invited
//        }
//    }
//
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        // Section titles
//        if section == 0 {
//            return "Members"
//        } else {
//            return "Invited"
//        }
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//
//        // Choose the data based on section
//        let member: Member
//        if indexPath.section == 0 {
//            member = members[indexPath.row]  // Members section
//        } else {
//            member = invited[indexPath.row]  // Invited section
//        }
//
//        // Configure the cell content
//        var content = cell.defaultContentConfiguration()
//        content.text = "\(member.profile) \(member.name)"
//        content.secondaryText = member.phonenumber
//        cell.contentConfiguration = content
//
//        // Add a cross button (remove) on the right side of the cell
//        let removeButton = UIButton(type: .custom)
//        removeButton.setTitle("x", for: .normal)
//        removeButton.setTitleColor(.gray, for: .normal)
//        removeButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
//        removeButton.tag = indexPath.row // Set the tag to the row number to identify the button
//        removeButton.addTarget(self, action: #selector(removeButtonTapped(_:)), for: .touchUpInside)
//        cell.accessoryView = removeButton
//
//        return cell
//    }
//
//    // MARK: - Remove member (via cross button)
//
//    @objc func removeButtonTapped(_ sender: UIButton) {
//        // Get the indexPath using the sender's tag
//        let indexPath = IndexPath(row: sender.tag, section: sender.tag < members.count ? 0 : 1)
//
//        // Identify the member in the appropriate section
//        var memberToRemove: Member?
//
//        // Determine which section the item is in
//        if indexPath.section == 0 {
//            memberToRemove = members[indexPath.row]
//            showConfirmationAlert(for: memberToRemove, at: indexPath, isInvited: false)
//        } else {
//            memberToRemove = invited[indexPath.row]
//            showConfirmationAlert(for: memberToRemove, at: indexPath, isInvited: true)
//        }
//    }
//
//    // MARK: - Show confirmation alert
//
//    func showConfirmationAlert(for member: Member?, at indexPath: IndexPath, isInvited: Bool) {
//        let alert = UIAlertController(title: "Confirm Removal", message: "Are you sure you want to remove \(member?.name ?? "")?", preferredStyle: .alert)
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        let confirmAction = UIAlertAction(title: "Confirm", style: .destructive) { _ in
//            // Remove the member from the appropriate list
//            if isInvited {
//                globalMembers.removeAll { $0.name == member?.name && !$0.ismember }
//            } else {
//                globalMembers.removeAll { $0.name == member?.name && $0.ismember }
//            }
//            // Reload the table view to reflect the change
//            self.tableView.reloadData()
//        }
//
//        alert.addAction(cancelAction)
//        alert.addAction(confirmAction)
//
//        self.present(alert, animated: true, completion: nil)
//    }
//}
