//
//  ViewAllCensusTableViewCell.swift
//  App_MStrat_8
//
//  Created by student-2 on 15/01/25.
//

import UIKit



class ViewAllCensusTableViewCell: UITableViewCell {
    
    @IBOutlet weak var viewintable: UIView!
    @IBOutlet weak var expenseimage: UIImageView!
    
    @IBOutlet weak var pricelabel: UILabel!
    
    @IBOutlet weak var categorylabel: UILabel!
    
    @IBOutlet weak var titlelabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Round corners for the viewintable
        viewintable.layer.cornerRadius = 10  // Adjust the corner radius value as needed
        viewintable.clipsToBounds = true
        
        // Add shadow under the viewintable
        viewintable.layer.shadowColor = UIColor.black.cgColor
        viewintable.layer.shadowOpacity = 0.4
        viewintable.layer.shadowOffset = CGSize(width: 0, height: 5)
        viewintable.layer.shadowRadius = 7
        viewintable.layer.masksToBounds = false  // Allow the shadow to extend beyond the view bounds
        
        // Optional: Round corners for the expense image to make it circular (if needed)
//        expenseimage.layer.cornerRadius = expenseimage.frame.height / 2
//        expenseimage.clipsToBounds = true
//        
//        // Optional: Add border to the expense image
//        expenseimage.layer.borderColor = UIColor.gray.cgColor
//        expenseimage.layer.borderWidth = 1.0
        
        // Optional: Round corners for the entire cell (if desired)
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        
        // Ensure categorylabel can handle multiline text
        categorylabel.numberOfLines = 0  // Allow for multiple lines if needed
        categorylabel.textAlignment = .left // Align text to the left, adjust if necessary
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
