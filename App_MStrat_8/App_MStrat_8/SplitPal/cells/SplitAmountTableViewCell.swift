//
//  SplitAmountTableViewCell.swift
//  App_MStrat_8
//
//  Created by student-2 on 17/03/25.
//

import UIKit

class SplitAmountTableViewCell: UITableViewCell {

    @IBOutlet weak var Splitamount: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        Splitamount.isUserInteractionEnabled = false  
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

     
    }
    
    

}
