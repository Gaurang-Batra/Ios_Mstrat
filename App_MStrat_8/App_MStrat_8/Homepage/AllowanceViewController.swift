import UIKit

class AllowanceViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var Amounttextfield: UITextField!
    
//    @IBOutlet weak var reoccurringSwitch: UISwitch!
//    @IBOutlet weak var durationStackView: UIStackView!
//    @IBOutlet weak var customButton: UIButton!
//    @IBOutlet weak var durationLabel: UILabel!
//    @IBOutlet weak var allowanceDatePicker: UIDatePicker!

    // Date Picker (for custom date selection)
    override func viewDidLoad() {
            super.viewDidLoad()

            // Initially hide the duration section and date picker
        
//        reoccurringSwitch.isOn = false
//            durationStackView.isHidden = true
//            durationLabel.isHidden = true
//            allowanceDatePicker.isHidden = true
//            reoccurringSwitch.isOn = false
        }
    
    @IBAction func cancelbutton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

        // MARK: - Actions
//        @IBAction func reoccurringSwitchToggled(_ sender: UISwitch) {
//            // Show or hide the duration section based on the switch state
//            let isOn = sender.isOn
//            durationStackView.isHidden = !isOn
//            durationLabel.isHidden = !isOn
//        }

//        @IBAction func customButtonTapped(_ sender: UIButton) {
//            // Toggle the visibility of the date picker when Custom button is tapped
//            allowanceDatePicker.isHidden.toggle()
//
//            // Change the appearance of the Custom button to indicate selection
//            if !allowanceDatePicker.isHidden {
//                customButton.backgroundColor = UIColor.systemGray2
//                customButton.setTitle("Custom", for: .normal)
//            } else {
//                customButton.backgroundColor = UIColor.systemGray5
//                customButton.setTitle("Custom", for: .normal)
//            }
//        }
//    
    @IBAction func savebuttontapped(_ sender: Any) {
        
        guard let text = Amounttextfield.text, let enteredAmount = Double(text) else {
               print("Invalid amount entered")
               return
           }
           
           // Add the entered amount to the shared allowance model
           let allowance = Allowance(amount: enteredAmount)
           AllowanceDataModel.shared.addAllowance(allowance)
           
           // Send notification to update the total
           NotificationCenter.default.post(name: NSNotification.Name("remaininfAllowancelabel"), object: nil)
           
           // Clear the text field
           Amounttextfield.text = ""
           
           // Dismiss or provide feedback
           print("Allowance saved!")
           self.dismiss(animated: true, completion: nil)
    }
    
    }
