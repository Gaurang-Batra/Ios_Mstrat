import UIKit

class AddMemberViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, AddMemberCellDelegate {
    
    @IBOutlet weak var Mysearchtext: UISearchBar!
    @IBOutlet weak var Mytable: UITableView!

    var users: [User] = []
    var searchUsers: [User] = []
    var selectedMembers: [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        users = UserDataModel.shared.getAllUsers()
        searchUsers = users

        Mytable.delegate = self
        Mytable.dataSource = self
        Mysearchtext.delegate = self
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

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchUsers = users
        } else {
            searchUsers = users.filter { $0.fullname.lowercased().contains(searchText.lowercased()) }
        }
        Mytable.reloadData()
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
}
