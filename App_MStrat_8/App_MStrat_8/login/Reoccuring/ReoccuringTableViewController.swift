//
//  ReoccuringTableViewController.swift
//  App_MStrat_8
//
//  Created by student-2 on 25/03/25.
//

import UIKit

class ReoccuringTableViewController: UITableViewController {

    var recurringExpenses: [Expense] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadRecurringExpenses()
    }

    func loadRecurringExpenses() {
        recurringExpenses = ExpenseDataModel.shared.getAllExpenses().filter { $0.isRecurring }
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recurringExpenses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reoccuring", for: indexPath) as? ReoccuringTableViewCell else {
            return UITableViewCell()
        }

        let expense = recurringExpenses[indexPath.row]
        cell.Reoccuringname.text = expense.itemName
        cell.ReoccuingSwitch.isOn = expense.isRecurring
        cell.expense = expense
        cell.updateExpense = { [weak self] updatedExpense in
            self?.updateExpense(updatedExpense)
        }

        return cell
    }

    func updateExpense(_ updatedExpense: Expense) {
        if let index = recurringExpenses.firstIndex(where: { $0.id == updatedExpense.id }) {
            recurringExpenses[index] = updatedExpense
        }
        ExpenseDataModel.shared.updateExpense(updatedExpense)
        loadRecurringExpenses() // Reload the table to reflect changes
    }
}



    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


