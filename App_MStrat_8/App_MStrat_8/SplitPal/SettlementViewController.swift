//
//  SettlementCellViewController.swift
//  App_MStrat_8
//
//  Created by student-2 on 26/12/24.
//

import UIKit
class SettlementViewController: UIViewController {

    @IBOutlet weak var settlementamounttextfield: UITextField!
    var labelText: Double?  // The variable that will receive the label text
    var selectedExpense: ExpenseSplitForm? // Store the selected expense to delete

    @IBOutlet weak var settlementbutton: UIButton!
    var delegate: GroupDetailViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Check if the labelText is not nil and then set it to the text field
        if let labelText = labelText {
            settlementamounttextfield.text = "\(labelText)"
            print("Received label text: \(labelText)")  // Log to verify
        }
    }
    @IBAction func Cancelbuttontapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func settlementButtonTapped(_ sender: UIButton) {
        if let selectedExpense = selectedExpense {
            // Delete the expense from the data model
            SplitExpenseDataModel.shared.deleteExpenseSplit(name: selectedExpense.name)

            // Notify the delegate (GroupDetailViewController) to reload the table view
            delegate?.reloadTableView()

            // Pop back to the previous view
            navigationController?.popViewController(animated: true)
        }
    }
}
