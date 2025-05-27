//
//  createdgroupTableViewCell.swift
//  App_MStrat_8
//
//  Created by student-2 on 09/01/25.
//
import UIKit

class ExpenseAddedTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var Expenseaddedimage: UIImageView!
    @IBOutlet weak var ExpenseAddedlabel: UILabel!
    @IBOutlet weak var Paidbylabel: UILabel!
    @IBOutlet weak var ExoenseAmountlabel: UILabel!
    
    // MARK: - Properties
    private let cornerRadius: CGFloat = 12
    private let shadowOpacity: Float = 0.1
    private let shadowRadius: CGFloat = 4
    private let shadowOffset = CGSize(width: 0, height: 2)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Animate selection with a subtle scale effect
        UIView.animate(withDuration: 0.2) {
            self.contentView.transform = selected ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Content View
        contentView.layer.cornerRadius = cornerRadius
        contentView.layer.masksToBounds = false
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = shadowOpacity
        contentView.layer.shadowRadius = shadowRadius
        contentView.layer.shadowOffset = shadowOffset
        contentView.backgroundColor = .systemBackground // Adapts to light/dark mode
        
        // Image View
        Expenseaddedimage.layer.cornerRadius = 20 // For a 40x40 image
        Expenseaddedimage.layer.masksToBounds = true
        Expenseaddedimage.contentMode = .scaleAspectFill
        Expenseaddedimage.layer.borderWidth = 1
        Expenseaddedimage.layer.borderColor = UIColor.systemGray4.cgColor
        
        // Labels
        ExpenseAddedlabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        ExpenseAddedlabel.textColor = .label // Adapts to light/dark mode
        Paidbylabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        Paidbylabel.textColor = .secondaryLabel // Slightly dimmer for hierarchy
        ExoenseAmountlabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        ExoenseAmountlabel.textColor = .systemGreen // Green for amounts
    }
    
    // MARK: - Configuration
    func configure(with expense: ExpenseSplitForm) {
        ExpenseAddedlabel.text = expense.name
        Paidbylabel.text = "Paid by \(expense.paidBy)"
        ExoenseAmountlabel.text = "Rs.\(Int(expense.totalAmount))"
        
        if let image = expense.image {
            Expenseaddedimage.image = image
        } else {
            Expenseaddedimage.image = UIImage(systemName: "photo") // SF Symbol placeholder
            Expenseaddedimage.tintColor = .systemGray3
        }
        
        // Accessibility
        accessibilityLabel = "\(expense.name), paid by \(expense.paidBy), amount Rs.\(Int(expense.totalAmount))"
    }
    
    // MARK: - Animation
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.contentView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.contentView.transform = .identity
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.contentView.transform = .identity
        }
    }
}
