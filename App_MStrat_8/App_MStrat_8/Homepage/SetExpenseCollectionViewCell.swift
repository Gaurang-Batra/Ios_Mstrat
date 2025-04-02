//
//  SetExpenseCollectionViewCell.swift
//  App_MStrat_8
//
//  Created by student-2 on 15/01/25.
//

import UIKit

class SetExpenseCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var categoryimage: UIImageView!
    
    @IBOutlet weak var titlelabel: UILabel!
    
    @IBOutlet weak var pricelabel: UILabel!
    
    func configure(with expense: Expense) {
            categoryimage.image = expense.image
            titlelabel.text = expense.itemName
            pricelabel.text = "Rs.\(expense.amount)"
            
            // Optional styling
            layer.cornerRadius = 10
            layer.masksToBounds = true
            backgroundColor = .systemGray6
        }
    
}
