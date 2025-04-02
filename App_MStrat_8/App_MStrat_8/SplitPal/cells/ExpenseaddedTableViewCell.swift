//
//  createdgroupTableViewCell.swift
//  App_MStrat_8
//
//  Created by student-2 on 09/01/25.
//

import UIKit

class ExpenseAddedTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var Expenseaddedimage: UIImageView!
    
    @IBOutlet weak var ExpenseAddedlabel: UILabel!
    @IBOutlet weak var Paidbylabel: UILabel!
    @IBOutlet weak var ExoenseAmountlabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        createdgroupimage.layer.cornerRadius = 10
//        createdgroupimage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
//    
//    func configure(with groupItem: Group) {
//        createdgroupname.text = groupItem.name
//        createdgroupimage.image = groupItem.image
//        // For example, you can add more labels and populate them here.
//    }

}
