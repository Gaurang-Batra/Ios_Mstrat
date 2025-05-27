//
//  BalanceCellTableViewCell.swift
//  App_MStrat_8
//
//  Created by student-2 on 26/12/24.
import UIKit

class BalanceCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var senderprofilename: UILabel!
    @IBOutlet weak var receiverprofilename: UILabel!
    @IBOutlet weak var Sendingamount: UILabel!
    @IBOutlet weak var balancecellview: UIView!
    
    var balance: ExpenseSplitForm?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        guard senderprofilename != nil, receiverprofilename != nil, Sendingamount != nil, balancecellview != nil else {
            print("❌ Error: One or more IBOutlets are not connected in BalanceCellTableViewCell")
            return
        }
        
        balancecellview.layer.cornerRadius = 10
        balancecellview.layer.masksToBounds = false
        balancecellview.layer.shadowColor = UIColor.black.cgColor
        balancecellview.layer.shadowOffset = CGSize(width: 0, height: 10)
        balancecellview.layer.shadowOpacity = 0.5
        balancecellview.layer.shadowRadius = 5
        balancecellview.layer.shouldRasterize = true
        balancecellview.layer.rasterizationScale = UIScreen.main.scale
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with balance: ExpenseSplitForm) async {
        self.balance = balance
        print("📋 Configuring cell for expense: \(balance.name), Paid by: \(balance.paidBy), Payee IDs: \(balance.payee), Split Amounts: \(balance.splitAmounts)")
        
        senderprofilename.text = balance.paidBy
        print("📝 Set senderprofilename to: \(balance.paidBy)")
        
        var payeeNames: [String] = []
        
        // Try payee array first
        if !balance.payee.isEmpty {
            print("🔍 Fetching users for payee IDs: \(balance.payee)")
            do {
                let users = try await UserDataModel.shared.getUsers(fromSupabaseBy: balance.payee)
                print("✅ Fetched \(users.count) users from Supabase")
                
                payeeNames = balance.payee.map { payeeId in
                    if let user = users.first(where: { $0.id == payeeId }) {
                        print("✅ Payee ID \(payeeId) -> Name: \(user.fullname)")
                        return user.fullname
                    } else {
                        print("❌ Payee ID \(payeeId) -> Not found in expense \(balance.name)")
                        return "Unknown (ID: \(payeeId))"
                    }
                }
            } catch {
                print("❌ Failed to fetch payee names for expense \(balance.name): \(error.localizedDescription)")
                payeeNames = balance.payee.map { id in
                    print("❌ Payee ID \(id) -> Fallback to Unknown")
                    return "Unknown (ID: \(id))"
                }
            }
        } else {
            print("⚠️ Payee array is empty for expense: \(balance.name). Using split_amounts keys.")
            // Use splitAmounts keys to find user names
            for key in balance.splitAmounts.keys {
                // Try numeric ID first
                if let userId = Int(key) {
                    do {
                        let users = try await UserDataModel.shared.getUsers(fromSupabaseBy: [userId])
                        if let user = users.first {
                            print("✅ SplitAmounts key \(key) -> Name: \(user.fullname)")
                            payeeNames.append(user.fullname)
                        } else {
                            print("❌ SplitAmounts key \(key) -> No user found")
                            payeeNames.append("Unknown (ID: \(key))")
                        }
                    } catch {
                        print("❌ Error fetching user for splitAmounts key \(key): \(error.localizedDescription)")
                        payeeNames.append("Unknown (ID: \(key))")
                    }
                } else {
                    // Try resolving as username or fullname
                    if let user = await UserDataModel.shared.getUserByUsername(key) {
                        print("✅ SplitAmounts key \(key) -> Name: \(user.fullname)")
                        payeeNames.append(user.fullname)
                    } else {
                        print("❌ SplitAmounts key \(key) -> No user found")
                        payeeNames.append("Unknown (\(key))")
                    }
                }
            }
        }
        
        let finalText = payeeNames.isEmpty ? "No payee" : payeeNames.joined(separator: ", ")
        receiverprofilename.text = finalText
        print("📝 Setting receiverprofilename to: \(finalText)")
        
        DispatchQueue.main.async { [weak self] in
            self?.receiverprofilename.text = finalText
            self?.setNeedsLayout()
            self?.layoutIfNeeded()
            print("📝 Main thread update for receiverprofilename: \(finalText)")
        }
        
        let amountText = String(format: "Rs.%.2f", balance.totalAmount)
        Sendingamount.text = amountText
        print("💰 Setting Sendingamount to: \(amountText)")
    }
    
    @IBAction func settlementButtonTapped(_ sender: UIButton) {
        if let balanceAmount = balance?.totalAmount, let balance = balance {
            print("🛠️ Settlement button tapped for expense: \(balance.name), amount: \(balanceAmount)")
            if let viewController = self.viewController() as? GroupDetailViewController {
                viewController.navigateToSettlement(with: balanceAmount, expense: balance)
            } else {
                print("❌ Failed to find GroupDetailViewController for settlement")
            }
        } else {
            print("❌ No balance or amount available for settlement")
        }
    }
}

extension UIView {
    func viewController() -> UIViewController? {
        var nextResponder = self.next
        while nextResponder != nil {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            nextResponder = nextResponder?.next
        }
        return nil
    }
}
