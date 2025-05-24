//
//  Signin&securityTableViewController.swift
//  App_MStrat_8
//
//  Created by Guest1 on 24/05/25.
//
import UIKit

class Signin_securityTableViewController: UITableViewController {
    
    var userId: Int?
    
    // Data for the table view cells
    private let cellTitles = ["Reset Password", "Delete Account"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔐 Signin & Security screen loaded. userId: \(userId ?? -1)")
        
        // Register a basic table view cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SecurityCell")
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitles.count // Returns 2 for "Reset Password" and "Delete Account"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SecurityCell", for: indexPath)
        
        // Configure the cell
        cell.textLabel?.text = cellTitles[indexPath.row]
        cell.accessoryType = .disclosureIndicator // Add arrow to indicate navigation
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                // Reset Password
                if let changePasswordVC = storyboard?.instantiateViewController(withIdentifier: "changepasswordVC") as? SignInSecurityViewController {
                    changePasswordVC.userId = userId
                    navigationController?.pushViewController(changePasswordVC, animated: true)
                }
            case 1:
                // Delete Account
                if let deleteUserVC = storyboard?.instantiateViewController(withIdentifier: "deleteuserVC") as? DeleteUserViewController {
                    deleteUserVC.userId = userId
                    navigationController?.pushViewController(deleteUserVC, animated: true)
                }
            default:
                break
            }
        }
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


