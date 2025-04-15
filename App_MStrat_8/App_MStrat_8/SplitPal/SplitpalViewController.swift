import UIKit

class SplitpalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var Balanceviewcontainer: UIView!
    @IBOutlet weak var Groupsviewcontainer: UIView!
    @IBOutlet weak var addgroupbutton: UIButton!
    @IBOutlet weak var welcomeimage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var Willgetlabel: UILabel!
    
    @IBOutlet weak var WillPaylabel: UILabel!
    
    @IBOutlet weak var TotalExpenselabel: UILabel!
    
 

    var selectedGroupIndex: Int? = nil
    var selectedImage: UIImage? = nil
    var userId: Int?
    
    var filteredGroups: [Group] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        print("this id is on the split page: \(userId ?? -1)")

        tableView.delegate = self
        tableView.dataSource = self

        if let image = UIImage(named: "Group") {
            welcomeimage.image = image
        }

        Balanceviewcontainer.layer.cornerRadius = 20
        Balanceviewcontainer.layer.masksToBounds = true

        setTopCornerRadius(for: Groupsviewcontainer, radius: 20)
        createVerticalDottedLineInBalanceContainer(atX: Balanceviewcontainer.bounds.size.width / (5/2))

        addgroupbutton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        addgroupbutton.titleLabel?.textAlignment = .center

        makeButtonCircular()
        tableView.separatorStyle = .singleLine
        updateBalanceLabels()

        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: .newGroupAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: .newExpenseAddedInGroup, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadUserGroups()
    }

    @objc func reloadTableView() {
        loadUserGroups()
        updateBalanceLabels()
    }
    
    func updateBalanceLabels() {
        guard let userId = self.userId else {
            print("User ID is nil, cannot calculate balances")
            return
        }

        var totalWillGet: Double = 0.0
        var totalWillPay: Double = 0.0

        let allExpenses = SplitExpenseDataModel.shared.getAllExpenseSplits()

        for expense in allExpenses {
            if expense.paidBy.contains("(You)") {
                totalWillGet += expense.totalAmount
            }

            if expense.payee.contains(userId) {
                let amountToPay = expense.splitAmounts.reduce(0) { partialResult, entry in
                    return partialResult + entry.value
                }
                totalWillPay += amountToPay
            }
        }

        Willgetlabel.text = "₹\(totalWillGet)"
        WillPaylabel.text = "₹\(totalWillPay)"
    }

    
    func loadUserGroups() {
        guard let userId = self.userId else {
            print("User ID is nil, cannot filter groups")
            return
        }

        // Call the async fetchGroupsForUser method
        Task {
            let allGroups = await GroupDataModel.shared.fetchGroupsForUser(userId: userId)
            
            // Filter the groups for the current user
            filteredGroups = allGroups.filter { $0.members.contains(userId) }

            print("Filtered groups for user \(userId): \(filteredGroups.map { $0.group_name })")
            
            // Reload the table view on the main thread
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    func setTopCornerRadius(for view: UIView, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: view.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        view.layer.mask = maskLayer
    }

    func createVerticalDottedLineInBalanceContainer(atX xPosition: CGFloat) {
        let dottedLine = CAShapeLayer()
        let path = UIBezierPath()
        let centerY = Balanceviewcontainer.bounds.size.height / 2
        let lineLength: CGFloat = 98
        let startY = centerY - (lineLength / 2)
        let endY = startY + lineLength

        path.move(to: CGPoint(x: xPosition, y: startY))
        path.addLine(to: CGPoint(x: xPosition, y: endY))

        dottedLine.path = path.cgPath
        dottedLine.strokeColor = UIColor.black.withAlphaComponent(0.4).cgColor
        dottedLine.lineWidth = 1.5
        dottedLine.lineDashPattern = [6, 2]

        Balanceviewcontainer.layer.addSublayer(dottedLine)
    }

    func makeButtonCircular() {
        let sideLength = min(addgroupbutton.frame.size.width, addgroupbutton.frame.size.height)
        addgroupbutton.layer.cornerRadius = sideLength / 2
        addgroupbutton.layer.masksToBounds = true
    }

    // MARK: - UITableViewDataSource Methods

    // MARK: - UITableViewDataSource Methods

    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredGroups.count // Each group gets its own section
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // Only one row per section
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SplitCell", for: indexPath)
        let group = filteredGroups[indexPath.section] // Use section instead of row
        
        cell.textLabel?.text = group.group_name
        cell.imageView?.image = group.category

        return cell
    }

    // MARK: - UITableViewDelegate Methods

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedGroup = filteredGroups[indexPath.section] 
        print("Selected group: \(selectedGroup.group_name)")
        performSegue(withIdentifier: "Groupsdetails", sender: self)
    }


//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 10 // Space between sections
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView()
//        headerView.backgroundColor = .clear
//        return headerView
//    }

    
    // MARK: - UITableViewDelegate Methods

//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedGroup = filteredGroups[indexPath.row]
//        print("Selected group: \(selectedGroup.groupName)")
//        performSegue(withIdentifier: "Groupsdetails", sender: self)
//    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }

    // MARK: - Segue Preparation
    
    @IBAction func addGroupButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "createsplitgroup", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Groupsdetails",
           let destinationVC = segue.destination as? GroupDetailViewController,
           let selectedIndex = tableView.indexPathForSelectedRow?.section {
            destinationVC.userId = self.userId
            destinationVC.groupItem = filteredGroups[selectedIndex]
        }
        else if segue.identifier == "createsplitgroup" {
            if let navigationController = segue.destination as? UINavigationController,
               let createGroupVC = navigationController.topViewController as? CreateGroupViewController {
                
                createGroupVC.userId = self.userId
                print("id passed to create splitgroup form page")
            }
        }
    }
}
