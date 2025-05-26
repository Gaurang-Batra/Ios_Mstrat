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
        
        if let balanceCellView = balancecellview {
            balanceCellView.layer.cornerRadius = 10
            balanceCellView.layer.masksToBounds = false
            balanceCellView.layer.shadowColor = UIColor.black.cgColor
            balanceCellView.layer.shadowOffset = CGSize(width: 0, height: 10)
            balanceCellView.layer.shadowOpacity = 0.5
            balanceCellView.layer.shadowRadius = 5
            balanceCellView.layer.shouldRasterize = true
            balanceCellView.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with balance: ExpenseSplitForm) async {
        self.balance = balance
        senderprofilename.text = balance.paidBy
        
        // Fetch payee names from the payee array
        var payeeNames: [String] = []
        for payeeId in balance.payee {
            if let payeeUser = await UserDataModel.shared.getUser(fromSupabaseBy: payeeId) {
                payeeNames.append(payeeUser.fullname)
            } else {
                print("❌ Failed to fetch user for payee ID \(payeeId) in expense \(balance.name ?? "Unknown")")
                payeeNames.append("Unknown (ID: \(payeeId))")
            }
        }
        
        // Display payee names or fallback
        receiverprofilename.text = payeeNames.isEmpty ? "No payee" : payeeNames.joined(separator: ", ")
        
        Sendingamount.text = "Rs.\(Int(balance.totalAmount))"
    }
    
    @IBAction func settlementButtonTapped(_ sender: UIButton) {
        if let balanceAmount = balance?.totalAmount {
            if let viewController = self.viewController() as? GroupDetailViewController {
                viewController.navigateToSettlement(with: balanceAmount, expense: balance)
            }
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
