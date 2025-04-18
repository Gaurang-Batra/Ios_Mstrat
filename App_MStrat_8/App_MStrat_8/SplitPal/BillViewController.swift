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
    
    
    let transparentview = UIView()
    let tableview = UITableView()
    var selectedbutton = UIButton()
    
    
    var membersdataSource = [String]()
    var dataSource: [(name: String, image: UIImage?)] = []

    
    var groupMembers : [Int] = []
   
    var selectedimage : UIImage?
    
    private var expenses: [ExpenseSplitForm] = []
    
    @IBOutlet weak var mytableview: UITableView!
    var groupid : Int?

    var users: [User] = []



//    
//    private var users: [User] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        pricetextfield.delegate = self
        print ( "this is the group members: \(groupMembers)")
        
//        groupMembers.insert(0, at: 1)
        
//        Task {
//                await loadUsers()
//            }
        
        Task {
              for userId in groupMembers {
                  if let user = await UserDataModel.shared.getUser(fromSupabaseBy: userId) {
                      self.users.append(user)
                  }
              }

              DispatchQueue.main.async {
                  self.payerbutton.setTitle("Select Payer", for: .normal)
                  // Reload table or update UI if needed
              }
          }
        
        mytableview.reloadData()
       
        // Customizing the text fields
        customizeTextField(titletextfield)
        customizeTextField(pricetextfield)
     

        // Setting up the tableview
        tableview.dataSource = self
        tableview.delegate = self
        tableview.register(Cellclass.self, forCellReuseIdentifier: "Cell")

        // Customizing the category button with underline
        addUnderlineToButton(categorybutton)
        addUnderlineToButton(payerbutton)
        NotificationCenter.default.addObserver(self, selector: #selector(onNewExpenseAdded), name: .newExpenseAddedInGroup, object: nil)

                loadExpenses()
        pricetextfield.addTarget(self, action: #selector(priceTextChanged(_:)), for: .editingChanged)
        segmentedcontroller.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        
        
        


    }
    
//    func loadUsers() async {
//        for userId in groupMembers {
//            if let user = await UserDataModel.shared.getUser(fromSupabaseBy: userId) {
//                users.append(user)
//            }
//        }
//        
//        // Optionally reload your table view here
//        DispatchQueue.main.async {
//            self.mytableview.reloadData()
//        }
//    }

    @objc func segmentedControlChanged() {
        // Check the selected segment and enable/disable the Splitamount field accordingly
        let isEnabled = segmentedcontroller.selectedSegmentIndex == 1

        // Iterate over each cell and enable or disable the Splitamount field
        for (index, member) in groupMembers.enumerated() {
            if let cell = mytableview.cellForRow(at: IndexPath(row: index, section: 0)) as? SplitAmountTableViewCell {
                cell.Splitamount.isUserInteractionEnabled = isEnabled
            }
        }
    }

    @objc func priceTextChanged(_ textField: UITextField) {
        if let priceText = textField.text, let price = Double(priceText) {
            updateSplitAmounts(with: price)
        }
    }

    
    private func loadExpenses() {
           expenses = SplitExpenseDataModel.shared.getAllExpenseSplits()
           mytableview.reloadData()
       }

       @objc private func onNewExpenseAdded() {
           loadExpenses()
       }

    private var underlineLayers: [UIButton: CALayer] = [:]

    private func addUnderlineToButton(_ button: UIButton) {
        // Remove any existing underline for the specific button
        underlineLayers[button]?.removeFromSuperlayer()
        
        // Add a new underline using CALayer
        let underline = CALayer()
        underline.frame = CGRect(x: 0, y: button.frame.height - 2, width: button.frame.width, height: 2)
        underline.backgroundColor = UIColor.lightGray.cgColor
        button.layer.addSublayer(underline)
        
        // Store the reference to the underline layer for the button
        underlineLayers[button] = underline
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // This method is called whenever the user types something into the text field
        
        // Make sure the change is happening in the pricetextfield
        if textField == pricetextfield {
            // Get the updated price as a Double
            if let priceText = textField.text, let price = Double(priceText) {
                // Update the split amounts in the table (assuming your tableview is already populated)
                updateSplitAmounts(with: price)
            }
        }
        return true
    }
    func updateSplitAmounts(with price: Double) {
        // Assuming each expense split has a split amount field
        let splitAmount = price / Double(groupMembers.count)
        
        // Iterate over the rows in the table and update the split amounts in the cells
        for (index, member) in groupMembers.enumerated() {
            // Reload the row that corresponds to this member to update the Splitamount text field
            if let cell = mytableview.cellForRow(at: IndexPath(row: index, section: 0)) as? SplitAmountTableViewCell {
                cell.Splitamount.text = String(format: "%.2f", splitAmount)
            }
        }
    }





    private func customizeTextField(_ textField: UITextField) {
        // Remove border
        textField.borderStyle = .none
        
        // Add underline to the textfield
        let underline = CALayer()
        underline.frame = CGRect(x: 0, y: textField.frame.height - 1, width: textField.frame.width, height: 1)
        underline.backgroundColor = UIColor.lightGray.cgColor
        textField.layer.addSublayer(underline)
    }

    // Method to show the transparent view and table when category button is clicked
    func addtransparentView(frames: CGRect) {
        // Get the active window in the current scene.
        guard let windowScene = view.window?.windowScene else {
            return
        }
        
        // Get the key window of the current scene
        if let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            transparentview.frame = window.frame
            self.view.addSubview(transparentview)
            
            // Set the table view position and size
            tableview.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
            self.view.addSubview(tableview)
            tableview.layer.cornerRadius = 8

            tableview.reloadData()

            // Set the background color of the transparent view
            transparentview.backgroundColor = UIColor.black.withAlphaComponent(0.9)
            
            // Add a tap gesture to remove the transparent view
            let tapgesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
            transparentview.addGestureRecognizer(tapgesture)
            
            // Initially hide the table
            transparentview.alpha = 0
            
            // Animate the appearance of the transparent view and table
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
                self.transparentview.alpha = 0.5
                self.tableview.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: CGFloat(self.dataSource.count * 50))
            }, completion: nil)
        }
    }

    @objc func removeTransparentView(){
        let frames = selectedbutton.frame
        
        // Animate the disappearance of the transparent view and table
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentview.alpha = 0
            self.tableview.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        }, completion: nil)
    }
    
    
    @IBAction func Payerbuttontapped(_ sender: Any) {
        membersdataSource.removeAll()
        dataSource.removeAll()

        Task {
            for memberId in groupMembers {
                if let user = await UserDataModel.shared.getUser(fromSupabaseBy: memberId) {
                    membersdataSource.append(user.fullname)
                    dataSource.append((name: user.fullname, image: UIImage(named: "defaultImage")))
                } else {
                    print("⚠️ Could not fetch user with ID \(memberId)")
                }
            }

            print("✅ Members Data Source: \(membersdataSource)")
            print("🔢 Group Members: \(groupMembers)")

            selectedbutton = payerbutton
            addtransparentView(frames: payerbutton.frame)
        }
    }


    // Action when category button is clicked
    @IBAction func Categorybutton(_ sender: Any) {
           // Populate dataSource using the enum values
           dataSource = ExpenseCategory.allCases.map { category in
               (category.rawValue, category.associatedImage)
           }
           
           print(dataSource)
           selectedbutton = categorybutton
           addtransparentView(frames: categorybutton.frame)
       }
    
    var selectedPayer: String?

    // MARK: - TableView DataSource and Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Check if the tableview's identifier corresponds to "Cell"
        if tableView.dequeueReusableCell(withIdentifier: "Cell") != nil {
            return dataSource.count
        }
        
        // Check if the tableview's identifier corresponds to "members"
         if tableView.dequeueReusableCell(withIdentifier: "members") != nil{
             
            return groupMembers.count // Assuming groupMembers is an array
        }

        // Default case
        return 0
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           if tableView.dequeueReusableCell(withIdentifier: "Cell") != nil{
            // Dequeue cell for "Cell" identifier
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cellclass
            let item = dataSource[indexPath.row]
            cell.textLabel?.text = item.name
            cell.imageView?.image = item.image
            return cell
        }
           if tableView.dequeueReusableCell(withIdentifier: "members") != nil {
            // Dequeue cell for "members" identifier
            let cell = tableView.dequeueReusableCell(withIdentifier: "members", for: indexPath)
               
        let memberId = groupMembers[indexPath.row]
               
               // Use UserDataModel to find the user by ID
               Task {
                          if let user = await UserDataModel.shared.getUser(fromSupabaseBy: memberId) {
                              // Update the UI on the main thread after fetching the user
                              DispatchQueue.main.async {
                                  cell.textLabel?.text = user.fullname // Display user's fullname
                              }
                          } else {
                              // Fallback if user not found
                              DispatchQueue.main.async {
                                  cell.textLabel?.text = "Unknown member"
                              }
                          }
                      }
               return cell
        }
        else {
            // Fallback for unknown identifier
            let cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
            cell.textLabel?.text = "Unknown Identifier"
            return cell
        }
    }


    // Action when a table row is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.accessibilityIdentifier != "members" {
            let selectedItem = dataSource[indexPath.row]
            
            // Update the title of the selected button to reflect the chosen payer
            selectedbutton.setTitle(selectedItem.name, for: .normal)
            
            if selectedbutton == payerbutton {
                payerbutton.setTitle("\(selectedItem.name)", for: .normal)
                selectedPayer = selectedItem.name
                print("Selected payer: \(selectedItem.name)")
            }
            
            // Store the selected payer for later use when creating the expense
            selectedPayer = selectedItem.name
            print("Selected payer: \(selectedItem.name)")
            
            // Remove the transparent view to hide the selection UI
            removeTransparentView()
        }
    }


    // Set the height of each row in the tableview
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    @IBAction func cancelbuttontapped(_ sender: Any) {
        self.dismiss(animated: true , completion: nil)
    }
    
    @IBAction func addExpenseButtonTapped(_ sender: Any) {
        // Extract the data from the input fields
        guard let title = titletextfield.text, !title.isEmpty,
              let priceString = pricetextfield.text, let price = Double(priceString),
              let categoryString = categorybutton.titleLabel?.text,
              let category = ExpenseCate(rawValue: categoryString),
              let paidByName = selectedPayer else {
            print("Error: Missing data (title, price, category, or payer)")
            return
        }

        // Get payer's ID using name
        guard let paidByUser = users.first(where: { $0.fullname == paidByName }) else {
            print("Error: Payer not found in users list")
            return
        }

        let paidById = paidByUser.id

        // Determine payees by excluding payer
        let payees = groupMembers.filter { $0 != paidById }

        // Prepare split amounts
        var splitAmounts: [String: Double]? = nil

        if segmentedcontroller.selectedSegmentIndex == 0 {  // Equally split
            let splitAmount = price / Double(groupMembers.count)
            splitAmounts = Dictionary(uniqueKeysWithValues: groupMembers.map { memberId in
                return ("\(memberId)", splitAmount)  // Use user ID as String to avoid duplicate fullname issue
            })
        } else if segmentedcontroller.selectedSegmentIndex == 1 {
            // Implement custom unequal split logic here
        }

        let currentDate = Date()

        let newExpense = ExpenseSplitForm(
            name: title,
            category: categoryString,
            totalAmount: price,
            paidBy: paidByName,
            groupId: groupid,
            image: category.associatedImage,
            splitOption: .equally,
            splitAmounts: splitAmounts ?? [:],
            payee: payees,
            date: currentDate,
            ismine: true
        )
        SplitExpenseDataModel.shared.uploadExpenseSplitToSupabase(newExpense) { result in
              switch result {
              case .success():
                  print("Expense uploaded successfully")
                  DispatchQueue.main.async {
                      self.titletextfield.text = ""
                      self.pricetextfield.text = ""
                      self.categorybutton.setTitle("Select Category", for: .normal)
                      self.payerbutton.setTitle("Select Payer", for: .normal)
                      self.dismiss(animated: true, completion: nil)
                  }
              case .failure(let error):
                  print("Failed to upload expense: \(error.localizedDescription)")
                  // Optional: Show alert to user
              }
          }
        SplitExpenseDataModel.shared.addExpenseSplit(expense: newExpense)

        print(newExpense)
        titletextfield.text = ""
        pricetextfield.text = ""
        categorybutton.setTitle("Select Category", for: .normal)
        payerbutton.setTitle("Select Payer", for: .normal)

        self.dismiss(animated: true, completion: nil)
    }







}
