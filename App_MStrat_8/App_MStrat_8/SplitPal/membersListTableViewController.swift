//
//  membersListTableViewController.swift
//  App_MStrat_8
//
//  Created by Gaurang  on 06/12/24.
//
import UIKit




class MembersListTableViewController: UITableViewController {

    // Filtered members based on ismember flag
//    var members: [Member] {
//        return globalMembers.filter { $0.ismember }
//    }
//
//    var invited: [Member] {
//        return globalMembers.filter { !$0.ismember }
//    }
//
    var members: [Int] = []
   
    @IBOutlet var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        members.append(0)
        
    // Register the table view cell
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // Add the green plus button in the navigation bar
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        addButton.tintColor = .green // Set the button color to green
        self.navigationItem.rightBarButtonItem = addButton
        tableview.reloadData()
    }

    // MARK: - Add Button Action
    @objc func addButtonTapped() {
        // For now, we'll just show an alert when the button is tapped.
        let alert = UIAlertController(title: "Add New Member", message: "Choose member type", preferredStyle: .alert)
        
        let addMemberAction = UIAlertAction(title: "Add Member", style: .default) { _ in
            // Handle adding a new member here
            print("Add Member tapped")
            // Show your member addition screen or handle member creation here
        }
        
        let addInvitedAction = UIAlertAction(title: "Add Invited", style: .default) { _ in
            // Handle adding a new invited person here
            print("Add Invited tapped")
            // Show your invited person addition screen or handle invited creation here
        }

        alert.addAction(addMemberAction)
        alert.addAction(addInvitedAction)
        
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections: 2 (members and invited)
        print ("\(members.count)")
        print ("\(members)")
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the count for each section
       
        
            return members.count
        
        
        
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Section titles
      
            return "Members"
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

               // Retrieve the member ID
        let memberId = members[indexPath.row]
        
        Task {
            if let user = await UserDataModel.shared.getUser(fromSupabaseBy: memberId) {
                var content = cell.defaultContentConfiguration()
                content.text = user.fullname
                content.secondaryText = user.email

                // You need to access UI on main thread
                await MainActor.run {
                    cell.contentConfiguration = content
                }
            } else {
                print("Error: No user found for memberId \(memberId)")
            }
        }

               
               // Fetch the user's details using the ID
//        if let user = UserDataModel.shared.getUser(by: memberId) {
//            var content = cell.defaultContentConfiguration()
//            content.text = user.fullname
//            content.secondaryText = user.email
//            cell.contentConfiguration = content
//        } else {
//            print("Error: No user found for memberId \(memberId)")
//        }


             
               let removeButton = UIButton(type: .custom)
               removeButton.setTitle("x", for: .normal)
               removeButton.setTitleColor(.red, for: .normal)
               removeButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
               removeButton.tag = indexPath.row // Set the tag to the row number
//               removeButton.addTarget(self, action: #selector(removeButtonTapped(_:)), for: .touchUpInside)
               cell.accessoryView = removeButton

               return cell
    }

    // MARK: - Remove member (via cross button)

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

    // MARK: - Show confirmation alert

    func showConfirmationAlert(for member: Member?, at indexPath: IndexPath, isInvited: Bool) {
        let alert = UIAlertController(title: "Confirm Removal", message: "Are you sure you want to remove \(member?.name ?? "")?", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: .destructive) { _ in
            // Remove the member from the appropriate list
            if isInvited {
                globalMembers.removeAll { $0.name == member?.name && !$0.ismember }
            } else {
                globalMembers.removeAll { $0.name == member?.name && $0.ismember }
            }
            // Reload the table view to reflect the change
            self.tableView.reloadData()
        }

        alert.addAction(cancelAction)
        alert.addAction(confirmAction)

        self.present(alert, animated: true, completion: nil)
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
