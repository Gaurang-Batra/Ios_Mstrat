//
//  SplitpalViewController.swift
//  App_MStrat_8
//
//  Created by student-2 on 26/12/24.
//

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

    var selectedGroupIndex: Int?
    var selectedImage: UIImage?
    var userId: Int? {
        didSet {
            print("SplitpalViewController userId set to: \(userId ?? -1)")
        }
    }
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
        super.viewWillAppear(animated)
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
                    partialResult + entry.value
                }
                totalWillPay += amountToPay
            }
        }

        Willgetlabel.text = "₹\(totalWillGet)"
        WillPaylabel.text = "₹\(totalWillPay)"
    }

    func loadUserGroups() {
        guard let userId = self.userId else {
            print("User ID is nil, cannot fetch groups")
            return
        }

        Task {
            let groups = await GroupDataModel.shared.fetchGroupsForUser(userId: userId)
            // Sort groups by id (corresponding to group_id, newest first)
            self.filteredGroups = groups.sorted { ($0.id ?? 0) > ($1.id ?? 0) }
            print("Loaded \(self.filteredGroups.count) groups for user \(userId): \(self.filteredGroups.map { $0.group_name })")
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

    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredGroups.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SplitCell", for: indexPath)
        let group = filteredGroups[indexPath.section]
        print("Displaying group at section \(indexPath.section): \(group.group_name) (group_id: \(group.id ?? -1))")
        cell.textLabel?.text = group.group_name
        cell.imageView?.image = group.category ?? UIImage(systemName: "photo")
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return cell
    }

    // MARK: - UITableViewDelegate Methods

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedGroupIndex = indexPath.section
        let selectedGroup = filteredGroups[indexPath.section]
        print("Selected group: \(selectedGroup.group_name)")
        performSegue(withIdentifier: "Groupsdetails", sender: self)
    }

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
        print("Add group button tapped, userId: \(userId ?? -1)")
        performSegue(withIdentifier: "createsplitgroup", sender: self)
    }

    @IBAction func notificationButtonTapped(_ sender: Any) {
        print("Notification button tapped, userId: \(userId ?? -1)")
        performSegue(withIdentifier: "notifications", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Preparing segue with identifier: \(segue.identifier ?? "none")")
        if segue.identifier == "Groupsdetails",
           let destinationVC = segue.destination as? GroupDetailViewController,
           let selectedIndex = selectedGroupIndex {
            destinationVC.userId = self.userId
            destinationVC.groupItem = filteredGroups[selectedIndex]
            print("Passing userId \(self.userId ?? -1) to GroupDetailViewController")
        } else if segue.identifier == "createsplitgroup" {
            if let navigationController = segue.destination as? UINavigationController,
               let createGroupVC = navigationController.topViewController as? CreateGroupViewController {
                createGroupVC.userId = self.userId
                print("Passing userId \(self.userId ?? -1) to CreateGroupViewController")
            } else {
                print("Failed to cast destination to UINavigationController or CreateGroupViewController")
            }
        } else if segue.identifier == "notifications" {
            if let notificationVC = segue.destination as? NotificationViewController {
                print("Passing userId to NotificationViewController: \(self.userId ?? -1)")
                notificationVC.userId = self.userId
                print("userId passed to NotificationViewController: \(notificationVC.userId ?? -1)")
            } else if let navigationController = segue.destination as? UINavigationController,
                      let notificationVC = navigationController.topViewController as? NotificationViewController {
                print("Passing userId to NotificationViewController (via UINavigationController): \(self.userId ?? -1)")
                notificationVC.userId = self.userId
                print("userId passed to NotificationViewController: \(notificationVC.userId ?? -1)")
            } else {
                print("Failed to cast destination to NotificationViewController or UINavigationController")
                print("Segue destination: \(segue.destination)")
            }
        }
    }
}
