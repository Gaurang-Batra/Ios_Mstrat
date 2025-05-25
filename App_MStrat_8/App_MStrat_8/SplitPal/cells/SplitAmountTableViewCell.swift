//
//  SplitAmountTableViewCell.swift
//  App_MStrat_8
//
//  Created by student-2 on 17/03/25.
//

import UIKit

class SplitAmountTableViewCell: UITableViewCell {
    @IBOutlet weak var Splitamount: UITextField!
    
    // Closure to notify text changes
    var onAmountChanged: ((Double?) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Splitamount.isUserInteractionEnabled = false
        Splitamount.delegate = self
        Splitamount.keyboardType = .decimalPad // Ensure numeric input
        Splitamount.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func textFieldDidChange() {
        let amount = Double(Splitamount.text ?? "")
        onAmountChanged?(amount)
    }
}

extension SplitAmountTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // Allow empty string or valid decimal number
        if updatedText.isEmpty {
            return true
        }
        // Regular expression to allow numbers with up to 2 decimal places
        let regex = "^\\d*\\.?\\d{0,2}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: updatedText)
    }
}
