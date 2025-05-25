//
//  BillViewController.swift
//  App_MStrat_8
//
//  Created by student-2 on 20/12/24.
//
import UIKit

enum ExpenseCate: String, CaseIterable {
    case food = "Food"
    case grocery = "Grocery"
    case fuel = "Fuel"
    case bills = "Bills"
    case travel = "Travel"
    case other = "Other"
    
    var associatedImage: UIImage {
        switch self {
        case .food:
            return UIImage(named: "icons8-kawaii-pizza-50") ?? UIImage()
        case .grocery:
            return UIImage(named: "icons8-vegetarian-food-50") ?? UIImage()
        case .fuel:
            return UIImage(named: "icons8-fuel-50") ?? UIImage()
        case .bills:
            return UIImage(named: "icons8-cheque-50") ?? UIImage()
        case .travel:
            return UIImage(named: "icons8-holiday-50") ?? UIImage()
        case .other:
            return UIImage(named: "icons8-more-50-2") ?? UIImage()
        }
    }
}

class Cellclass: UITableViewCell {
    // You can customize this cell further if needed.
}

class BillViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var categorybutton: UIButton!
    @IBOutlet weak var titletextfield: UITextField!
    @IBOutlet weak var pricetextfield: UITextField!
    @IBOutlet weak var payerbutton: UIButton!
    @IBOutlet weak var segmentedcontroller: UISegmentedControl!
    @IBOutlet weak var mytableview: UITableView!
    
    let transparentview = UIView()
    let tableview = UITableView()
    var selectedbutton = UIButton()
    
    var membersdataSource = [String]()
    var dataSource: [(name: String, image: UIImage?)] = []
    
    var groupMembers: [Int] = []
    var groupid: Int?
    var users: [User] = []
    
    var selectedimage: UIImage?
    private var expenses: [ExpenseSplitForm] = []
    private var customSplitAmounts: [Int: Double] = [:]
    var selectedPayer: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pricetextfield.delegate = self
        
        // Fetch group members
        if let groupId = groupid {
            GroupDataModel.shared.fetchGroupMembers(groupId: groupId, includeUserDetails: true) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let fetchedUsers):
                        self.users = (fetchedUsers as? [User]) ?? []
                        self.groupMembers = self.users.map { $0.id ?? -1 }
                        print("✅ Fetched \(self.users.count) members for group \(groupId): \(self.groupMembers)")
                        self.payerbutton.setTitle("Select Payer", for: .normal)
                        self.mytableview.reloadData()
                    case .failure(let error):
                        print("❌ Error fetching group members: \(error)")
                        self.users = []
                        self.groupMembers = []
                        self.payerbutton.setTitle("No Members", for: .normal)
                        self.mytableview.reloadData()
                    }
                }
            }
        } else {
            print("❌ No group ID provided")
            payerbutton.setTitle("No Members", for: .normal)
        }
        
        // Customize text fields
        customizeTextField(titletextfield)
        customizeTextField(pricetextfield)
        
        // Set up the dropdown table view
        tableview.dataSource = self
        tableview.delegate = self
        tableview.register(Cellclass.self, forCellReuseIdentifier: "Cell")
        
        // Customize buttons with underlines
        addUnderlineToButton(categorybutton)
        addUnderlineToButton(payerbutton)
        
        // Set up notifications and UI events
        NotificationCenter.default.addObserver(self, selector: #selector(onNewExpenseAdded), name: .newExpenseAddedInGroup, object: nil)
        pricetextfield.addTarget(self, action: #selector(priceTextChanged(_:)), for: .editingChanged)
        segmentedcontroller.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        
        loadExpenses()
    }
    
    private var underlineLayers: [UIButton: CALayer] = [:]
    
    private func addUnderlineToButton(_ button: UIButton) {
        underlineLayers[button]?.removeFromSuperlayer()
        let underline = CALayer()
        underline.frame = CGRect(x: 0, y: button.frame.height - 2, width: button.frame.width, height: 2)
        underline.backgroundColor = UIColor.lightGray.cgColor
        button.layer.addSublayer(underline)
        underlineLayers[button] = underline
    }
    
    private func customizeTextField(_ textField: UITextField) {
        textField.borderStyle = .none
        let underline = CALayer()
        underline.frame = CGRect(x: 0, y: textField.frame.height - 1, width: textField.frame.width, height: 1)
        underline.backgroundColor = UIColor.lightGray.cgColor
        textField.layer.addSublayer(underline)
    }
    
    @objc func priceTextChanged(_ textField: UITextField) {
        if segmentedcontroller.selectedSegmentIndex == 0 {
            if let priceText = textField.text, let price = Double(priceText) {
                updateSplitAmounts(with: price)
            } else {
                updateSplitAmounts(with: 0.0)
            }
        }
    }
    
    func updateSplitAmounts(with price: Double) {
        let splitAmount = groupMembers.isEmpty ? 0.0 : price / Double(groupMembers.count)
        for (index, _) in groupMembers.enumerated() {
            if let cell = mytableview.cellForRow(at: IndexPath(row: index, section: 0)) as? SplitAmountTableViewCell {
                cell.Splitamount.text = String(format: "%.2f", splitAmount)
            }
        }
    }
    
    @objc func segmentedControlChanged() {
        let isCustomSplit = segmentedcontroller.selectedSegmentIndex == 1
        if isCustomSplit {
            // Initialize customSplitAmounts with equal splits if not already set
            if let priceText = pricetextfield.text, let price = Double(priceText) {
                let splitAmount = groupMembers.isEmpty ? 0.0 : price / Double(groupMembers.count)
                customSplitAmounts = Dictionary(uniqueKeysWithValues: groupMembers.map { ($0, splitAmount) })
            }
        } else {
            // Clear custom amounts when switching back to equal split
            customSplitAmounts.removeAll()
        }
        
        for (index, _) in groupMembers.enumerated() {
            if let cell = mytableview.cellForRow(at: IndexPath(row: index, section: 0)) as? SplitAmountTableViewCell {
                cell.Splitamount.isUserInteractionEnabled = isCustomSplit
                if isCustomSplit {
                    let memberId = groupMembers[index]
                    let amount = customSplitAmounts[memberId] ?? 0.0
                    cell.Splitamount.text = String(format: "%.2f", amount)
                } else {
                    if let priceText = pricetextfield.text, let price = Double(priceText) {
                        let splitAmount = groupMembers.isEmpty ? 0.0 : price / Double(groupMembers.count)
                        cell.Splitamount.text = String(format: "%.2f", splitAmount)
                    } else {
                        cell.Splitamount.text = "0.00"
                    }
                }
            }
        }
        mytableview.reloadData()
    }
    
    private func loadExpenses() {
        expenses = SplitExpenseDataModel.shared.getAllExpenseSplits()
        mytableview.reloadData()
    }
    
    @objc private func onNewExpenseAdded() {
        loadExpenses()
    }
    
    func addtransparentView(frames: CGRect) {
        guard let windowScene = view.window?.windowScene, let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        transparentview.frame = window.frame
        self.view.addSubview(transparentview)
        tableview.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        self.view.addSubview(tableview)
        tableview.layer.cornerRadius = 8
        tableview.reloadData()
        transparentview.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        transparentview.addGestureRecognizer(tapgesture)
        transparentview.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentview.alpha = 0.5
            self.tableview.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: CGFloat(self.dataSource.count * 50))
        }, completion: nil)
    }
    
    @objc func removeTransparentView() {
        let frames = selectedbutton.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentview.alpha = 0
            self.tableview.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        }, completion: nil)
    }
    
    @IBAction func Payerbuttontapped(_ sender: Any) {
        membersdataSource.removeAll()
        dataSource.removeAll()
        
        // Use pre-fetched users
        membersdataSource = users.map { $0.fullname }
        dataSource = users.map { (name: $0.fullname, image: UIImage(named: "defaultImage")) }
        
        print("✅ Members Data Source: \(membersdataSource)")
        print("🔢 Group Members: \(groupMembers)")
        
        selectedbutton = payerbutton
        addtransparentView(frames: payerbutton.frame)
    }
    
    @IBAction func Categorybutton(_ sender: Any) {
        dataSource = ExpenseCate.allCases.map { category in
            (category.rawValue, category.associatedImage)
        }
        selectedbutton = categorybutton
        addtransparentView(frames: categorybutton.frame)
    }
    
    // MARK: - TableView DataSource and Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableview {
            return dataSource.count
        } else {
            return groupMembers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableview { // Dropdown table view for category/payer selection
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cellclass
            let item = dataSource[indexPath.row]
            cell.textLabel?.text = item.name
            cell.imageView?.image = item.image
            return cell
        } else { // Main table view for members and split amounts
            let cell = tableView.dequeueReusableCell(withIdentifier: "members", for: indexPath) as? SplitAmountTableViewCell ?? SplitAmountTableViewCell(style: .default, reuseIdentifier: "members")
            let memberId = groupMembers[indexPath.row]
            if let user = users.first(where: { $0.id == memberId }) {
                cell.textLabel?.text = user.fullname
            } else {
                cell.textLabel?.text = "Unknown Member"
            }
            
            // Set initial amount from customSplitAmounts or calculate equal split
            let isCustomSplit = segmentedcontroller.selectedSegmentIndex == 1
            cell.Splitamount.isUserInteractionEnabled = isCustomSplit
            if isCustomSplit {
                let amount = customSplitAmounts[memberId] ?? 0.0
                cell.Splitamount.text = String(format: "%.2f", amount)
            } else {
                if let priceText = pricetextfield.text, let price = Double(priceText) {
                    let splitAmount = groupMembers.isEmpty ? 0.0 : price / Double(groupMembers.count)
                    cell.Splitamount.text = String(format: "%.2f", splitAmount)
                } else {
                    cell.Splitamount.text = "0.00"
                }
            }
            
            // Handle text field changes
            cell.onAmountChanged = { [weak self] amount in
                guard let self = self else { return }
                self.customSplitAmounts[memberId] = amount ?? 0.0
                print("Updated custom amount for member \(memberId): \(amount ?? 0.0)")
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableview {
            let selectedItem = dataSource[indexPath.row]
            selectedbutton.setTitle(selectedItem.name, for: .normal)
            if selectedbutton == payerbutton {
                selectedPayer = selectedItem.name
                print("Selected payer: \(selectedItem.name)")
            }
            removeTransparentView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == pricetextfield {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            // Allow empty string or valid decimal number
            if updatedText.isEmpty {
                return true
            }
            let regex = "^\\d*\\.?\\d{0,2}$"
            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
            return predicate.evaluate(with: updatedText)
        }
        return true
    }
    
    @IBAction func cancelbuttontapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addExpenseButtonTapped(_ sender: Any) {
        guard let title = titletextfield.text, !title.isEmpty,
              let priceString = pricetextfield.text, let price = Double(priceString),
              let categoryString = categorybutton.titleLabel?.text,
              let category = ExpenseCate(rawValue: categoryString),
              let paidByName = selectedPayer,
              let groupId = groupid else {
            showAlert(message: "Please fill in all fields: title, price, category, and payer.")
            return
        }
        
        guard let paidByUser = users.first(where: { $0.fullname == paidByName }) else {
            showAlert(message: "Payer not found in group members.")
            return
        }
        
        let paidById = paidByUser.id
        let payees = groupMembers.filter { $0 != paidById }
        
        var splitAmounts: [String: Double] = [:]
        if segmentedcontroller.selectedSegmentIndex == 0 {
            let splitAmount = groupMembers.isEmpty ? 0.0 : price / Double(groupMembers.count)
            splitAmounts = Dictionary(uniqueKeysWithValues: groupMembers.map { ("\( $0)", splitAmount) })
        } else {
            // Custom split: Validate sum of custom amounts
            let totalCustomAmount = customSplitAmounts.values.reduce(0, +)
            if abs(totalCustomAmount - price) > 0.01 { // Allow small floating-point errors
                showAlert(message: "The sum of custom split amounts (\(String(format: "%.2f", totalCustomAmount))) does not equal the total price (\(String(format: "%.2f", price))).")
                return
            }
            splitAmounts = Dictionary(uniqueKeysWithValues: customSplitAmounts.map { (key, value) in ("\(key)", value) })
            
            // Ensure all members have an amount assigned
            for memberId in groupMembers {
                if splitAmounts["\(memberId)"] == nil {
                    splitAmounts["\(memberId)"] = 0.0
                }
            }
        }
        
        let currentDate = Date()
        let newExpense = ExpenseSplitForm(
            name: title,
            category: categoryString,
            totalAmount: price,
            paidBy: paidByName,
            groupId: groupId,
            image: category.associatedImage,
            splitOption: segmentedcontroller.selectedSegmentIndex == 0 ? .equally : .unequally,
            splitAmounts: splitAmounts,
            payee: payees,
            date: currentDate,
            ismine: true
        )
        
        SplitExpenseDataModel.shared.uploadExpenseSplitToSupabase(newExpense) { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    print("Expense uploaded successfully")
                    self.clearForm()
                    self.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    self.showAlert(message: "Failed to upload expense: \(error.localizedDescription)")
                }
            }
        }
        
        SplitExpenseDataModel.shared.addExpenseSplit(expense: newExpense)
        print(newExpense)
        clearForm()
        self.dismiss(animated: true, completion: nil)
    }
    
    // Helper method to show alerts
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // Helper method to clear form
    private func clearForm() {
        titletextfield.text = ""
        pricetextfield.text = ""
        categorybutton.setTitle("Select Category", for: .normal)
        payerbutton.setTitle("Select Payer", for: .normal)
        customSplitAmounts.removeAll()
        segmentedcontroller.selectedSegmentIndex = 0
        mytableview.reloadData()
    }
}
