//
//  ReoccuringTableViewCell.swift
//  App_MStrat_8
//
//  Created by student-2 on 25/03/25.
//

import UIKit


class ReoccuringTableViewCell: UITableViewCell {

    @IBOutlet weak var Reoccuringname: UILabel!
    @IBOutlet weak var ReoccuingSwitch: UISwitch!
    
    var expense: Expense?
    var updateExpense: ((Expense) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        ReoccuingSwitch.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
    }

    @objc func switchToggled(_ sender: UISwitch) {
        guard var expense = expense else { return }

        if !sender.isOn {
            expense.isRecurring = false
            expense.duration = nil // Remove the duration when turning off recurring
        }

        updateExpense?(expense)
    }
}
