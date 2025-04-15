import UIKit

class AllowanceViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var Amounttextfield: UITextField!
    
    var userId: Int? // this will be set from outside (e.g. during login or navigation)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelbutton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func savebuttontapped(_ sender: Any) {
        guard let text = Amounttextfield.text, let enteredAmount = Double(text) else {
            print("Invalid amount entered")
            return
        }
        
        guard let userId = userId else {
            print("User ID not set. Cannot save allowance.")
            return
        }

        let allowance = Allowance(
            amount: enteredAmount,
            isRecurring: nil,
            duration: nil,
            customDate: nil,
            user_id: userId
        )

        AllowanceDataModel.shared.addAllowance(allowance)
        Task {
            do {
                try await AllowanceDataModel.shared.saveAllowanceToBackend(allowance)
                print("Allowance saved to Supabase.")
            } catch {
                print("Failed to insert allowance: \(error)")
            }

            NotificationCenter.default.post(name: NSNotification.Name("remaininfAllowancelabel"), object: nil)
            Amounttextfield.text = ""
            self.dismiss(animated: true, completion: nil)
        }

    }
}
