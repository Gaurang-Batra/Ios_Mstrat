
import UIKit

class GroupDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var balances: [ExpenseSplitForm] = []
    var myBalances: [ExpenseSplitForm] = []
    var othersBalances: [ExpenseSplitForm] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupimageoutlet: UIImageView!
    @IBOutlet weak var groupnamelabel: UILabel!
    @IBOutlet weak var amountlabel: UILabel!
    @IBOutlet weak var GroupInfoView: UIView!
    @IBOutlet weak var SegmentedControllerforgroup: UISegmentedControl!
    @IBOutlet weak var membersbutton: UIButton!
    
    var groupItem: Group?
    var userId: Int?
    
    // Helper struct for balance calculations
    private struct BalanceEntry {
        let fromUser: String // Name of the user who owes
        let toUser: String   // Name of the user to be paid
        var amount: Double   // Amount owed
    }
    
    @IBAction func addedmemberbuttontapped(_ sender: UIButton) {
        print(groupItem?.group_name ?? "No group name")
        print(groupItem?.id ?? "No group ID")
        
        SplitExpenseDataModel.shared.getExpenseSplits(forGroup: groupItem?.id ?? 0) { [weak self] expenses in
            guard let self = self else { return }
            self.balances = expenses.sorted { ($0.id ?? 0) > ($1.id ?? 0) }
            Task {
                await self.filterBalances()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.updateMembersButton()
                }
            }
        }
    }
    
    private var expenses: [ExpenseSplitForm] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("this id is present in the balance page: \(userId ?? 0)")
        
        guard let group = groupItem else {
            print("groupItem is nil")
            return
        }
        
        updateMembersButton()
        
        SplitExpenseDataModel.shared.getExpenseSplits(forGroup: group.id ?? 0) { [weak self] expenses in
            guard let self = self else { return }
            self.balances = expenses.sorted { ($0.id ?? 0) > ($1.id ?? 0) }
            Task {
                await self.filterBalances()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.updateExpenseSum()
                }
            }
        }
        
        groupnamelabel.text = group.group_name
        groupimageoutlet.image = group.category
        
        GroupInfoView.layer.cornerRadius = 20
        GroupInfoView.layer.masksToBounds = true
        
        updateSeparatorStyle()
        
        SegmentedControllerforgroup.addTarget(self, action: #selector(segmentControlChanged), for: .valueChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: .newExpenseAddedInGroup, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SplitExpenseDataModel.shared.getExpenseSplits(forGroup: groupItem?.id ?? 0) { [weak self] expenses in
            guard let self = self else { return }
            self.balances = expenses.sorted { ($0.id ?? 0) > ($1.id ?? 0) }
            Task {
                await self.filterBalances()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.updateExpenseSum()
                    self.updateSeparatorStyle()
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func updateMembersButton() {
        guard let group = groupItem, let groupId = group.id else {
            membersbutton.setTitle("No Members", for: .normal)
            return
        }
        
        GroupDataModel.shared.fetchGroupMembers(groupId: groupId, includeUserDetails: true) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    let memberNames = (users as? [User])?.prefix(2).map { $0.fullname } ?? []
                    let displayText = memberNames.isEmpty ? "No Members" : memberNames.joined(separator: ", ")
                    self.membersbutton.setTitle(displayText, for: .normal)
                case .failure(let error):
                    print("❌ Error fetching group members: \(error)")
                    self.membersbutton.setTitle("No Members", for: .normal)
                }
            }
        }
    }
    
    @objc func reloadTableView() {
        print("Reloading table view...")
        SplitExpenseDataModel.shared.getExpenseSplits(forGroup: groupItem?.id ?? 0) { [weak self] expenses in
            guard let self = self else { return }
            self.balances = expenses.sorted { ($0.id ?? 0) > ($1.id ?? 0) }
            Task {
                await self.filterBalances()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.updateExpenseSum()
                }
            }
        }
    }
    
    @objc func segmentControlChanged() {
        Task {
            await filterBalances()
            DispatchQueue.main.async {
                self.updateSeparatorStyle()
                self.tableView.reloadData()
            }
        }
    }
    
    func updateExpenseSum() {
        let totalAmount = balances.reduce(0) { $0 + $1.totalAmount }
        amountlabel.text = "Rs.\(Int(totalAmount))"
    }
    
    func filterBalances() async {
        guard let userId = userId else {
            myBalances = []
            othersBalances = []
            return
        }

        // Fetch current user's full name
        let currentUser = await UserDataModel.shared.getUser(fromSupabaseBy: userId)
        let currentUserName = currentUser?.fullname ?? "You"
        let currentUserDisplayName = "\(currentUserName) (You)"

        // Step 1: Create a list of balance entries
        var balanceEntries: [BalanceEntry] = []

        for expense in balances {
            let splitAmounts = expense.splitAmounts
            if splitAmounts.isEmpty {
                print("⚠️ Skipping expense \(expense.name) due to empty splitAmounts")
                continue
            }

            // Get the paidBy user
            let paidByName = expense.paidBy
            print("📋 Processing expense \(expense.name), paidBy: \(paidByName), payee: \(expense.payee), splitAmounts: \(splitAmounts)")

            // For each payee, create a balance entry
            for payeeId in expense.payee {
                // Fetch payee's full name from Supabase for display purposes
                let payeeUser = await UserDataModel.shared.getUser(fromSupabaseBy: payeeId)
                guard let payeeName = payeeUser?.fullname else {
                    print("❌ Failed to fetch user for payee ID \(payeeId) in expense \(expense.name)")
                    continue
                }

                // Look up amount using payeeId as a string key in splitAmounts
                let payeeIdString = String(payeeId)
                guard let amount = splitAmounts[payeeIdString], amount > 0 else {
                    print("⚠️ Skipping payee \(payeeName) (ID: \(payeeId)) for expense \(expense.name) due to zero or missing amount in splitAmounts: \(splitAmounts)")
                    continue
                }

                // Determine the direction of the balance
                if paidByName == currentUserDisplayName || paidByName == currentUserName {
                    balanceEntries.append(BalanceEntry(fromUser: payeeName, toUser: currentUserDisplayName, amount: amount))
                } else if payeeId == userId {
                    balanceEntries.append(BalanceEntry(fromUser: currentUserDisplayName, toUser: paidByName, amount: amount))
                } else {
                    balanceEntries.append(BalanceEntry(fromUser: payeeName, toUser: paidByName, amount: amount))
                }
            }
        }

        // Step 2: Net out balances
        let nettedBalances = netBalances(balanceEntries)

        // Step 3: Split into myBalances and othersBalances
        myBalances = createExpenseSplitForms(
            from: nettedBalances.filter { $0.fromUser == currentUserDisplayName || $0.toUser == currentUserDisplayName },
            currentUserId: userId,
            currentUserDisplayName: currentUserDisplayName,
            groupId: groupItem?.id
        ).sorted { ($0.id ?? 0) > ($1.id ?? 0) }

        othersBalances = createExpenseSplitForms(
            from: nettedBalances.filter { $0.fromUser != currentUserDisplayName && $0.toUser != currentUserDisplayName },
            currentUserId: userId,
            currentUserDisplayName: currentUserDisplayName,
            groupId: groupItem?.id
        ).sorted { ($0.id ?? 0) > ($1.id ?? 0) }
    }
    private func createExpenseSplitForms(from balances: [BalanceEntry], currentUserId: Int, currentUserDisplayName: String, groupId: Int?) -> [ExpenseSplitForm] {
        return balances.map { balance in
            ExpenseSplitForm(
                id: nil,
                name: "Balance",
                category: "Balance",
                totalAmount: balance.amount,
                paidBy: balance.toUser,
                groupId: groupId,
                image: nil,
                splitOption: nil,
                splitAmounts: [balance.fromUser: balance.amount],
                payee: balance.fromUser == currentUserDisplayName ? [currentUserId] : [],
                date: Date(),
                ismine: balance.toUser == currentUserDisplayName
            )
        }
    }
    
    private func netBalances(_ entries: [BalanceEntry]) -> [BalanceEntry] {
        var netted: [String: Double] = [:]
        var result: [BalanceEntry] = []

        for entry in entries {
            let sortedUsers = [entry.fromUser, entry.toUser].sorted()
            let key = "\(sortedUsers[0])->\(sortedUsers[1])"
            let isForward = entry.fromUser == sortedUsers[0]
            let amount = isForward ? entry.amount : -entry.amount
            netted[key, default: 0] += amount
        }

        for (key, amount) in netted {
            guard amount != 0 else { continue }
            let users = key.split(separator: "->").map { String($0) }
            let fromUser = amount > 0 ? users[0] : users[1]
            let toUser = amount > 0 ? users[1] : users[0]
            result.append(BalanceEntry(fromUser: fromUser, toUser: toUser, amount: abs(amount)))
        }

        return result.sorted { $0.amount > $1.amount }
    }
    
    func updateSeparatorStyle() {
        if SegmentedControllerforgroup.selectedSegmentIndex == 0 {
            tableView.separatorStyle = .singleLine
        } else {
            tableView.separatorStyle = .none
        }
    }
    
    // MARK: - Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SegmentedControllerforgroup.selectedSegmentIndex == 0 ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if SegmentedControllerforgroup.selectedSegmentIndex == 0 {
            return nil
        } else {
            return section == 0 ? "My Balances" : "Other's Balances"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if SegmentedControllerforgroup.selectedSegmentIndex == 0 {
            return balances.count
        } else {
            return section == 0 ? myBalances.count : othersBalances.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if SegmentedControllerforgroup.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath) as! ExpenseAddedTableViewCell
            
            let expense = balances[indexPath.row]
            cell.ExpenseAddedlabel.text = expense.name
            cell.Paidbylabel.text = expense.paidBy
            cell.ExoenseAmountlabel.text = "Rs.\(Int(expense.totalAmount))"
            
            if let image = expense.image {
                cell.Expenseaddedimage.image = image
            } else {
                cell.Expenseaddedimage.image = nil
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BalanceCell", for: indexPath) as! BalanceCellTableViewCell
            let balance: ExpenseSplitForm
            if indexPath.section == 0 {
                balance = myBalances[indexPath.row]
            } else {
                balance = othersBalances[indexPath.row]
            }
            
            Task {
                await cell.configure(with: balance)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if SegmentedControllerforgroup.selectedSegmentIndex == 0 {
            return 60
        }
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let spacerView = UIView()
        spacerView.backgroundColor = .clear
        return spacerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if SegmentedControllerforgroup.selectedSegmentIndex == 0 {
            let headerView = UIView()
            headerView.backgroundColor = .clear
            
            let headerLabel = UILabel()
            headerLabel.translatesAutoresizingMaskIntoConstraints = false
            headerLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            headerLabel.textColor = .black
            headerLabel.text = "Expense List"
            
            headerView.addSubview(headerLabel)
            
            NSLayoutConstraint.activate([
                headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                headerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16)
            ])
            
            return headerView
        }
        
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        headerLabel.textColor = .black
        headerLabel.text = section == 0 ? "My Balances" : "Other's Balances"
        
        headerView.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            headerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    // MARK: - Navigation
    
    func navigateToSettlement(with amount: Double, expense: ExpenseSplitForm?) {
        performSegue(withIdentifier: "Settlement", sender: expense)
    }
    
    @IBAction func ExpenseSplitbuttontapped(_ sender: Any) {
        performSegue(withIdentifier: "ExpenseSplit", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Settlement" {
            if let destinationVC = segue.destination as? SettlementViewController,
               let selectedExpense = sender as? ExpenseSplitForm {
                destinationVC.labelText = selectedExpense.totalAmount
                destinationVC.selectedExpense = selectedExpense
                destinationVC.delegate = self
            }
        } else if segue.identifier == "ExpenseSplit" {
            if let navigationController = segue.destination as? UINavigationController,
               let destinationVC = navigationController.topViewController as? BillViewController {
                if let members = groupItem?.members {
                    destinationVC.groupMembers = members
                    print("Sending groupItem IDs: \(members)")
                }
                if let id = groupItem?.id {
                    destinationVC.groupid = id
                    print("Sending groupItem IDs: \(id)")
                }
            }
        } else if segue.identifier == "invitedmemberlist" {
            if let destinationVC = segue.destination as? MembersListTableViewController {
                if let groupId = groupItem?.id {
                    destinationVC.groupId = groupId
                    print("Sending groupId: \(groupId)")
                }
                if let userId = self.userId {
                    destinationVC.currentUserId = userId
                    print("Sending userId: \(userId)")
                }
            }
        }
    }
}
