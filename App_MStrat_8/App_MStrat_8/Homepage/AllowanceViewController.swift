import UIKit

class AllowanceViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var Amounttextfield: UITextField!
    

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

        let currentUserID = 1

        let allowance = Allowance(
            amount: enteredAmount,
            isRecurring: nil,
            duration: nil,
            customDate: nil,
            user_id: currentUserID
        )

        AllowanceDataModel.shared.addAllowance(allowance)

        Task {
            do {
                let client = SupabaseAPIClient.shared.supabaseClient

                try await client
                    .from("allowances")
                    .insert([allowance])
                    .execute()

                print(" Allowance saved to Supabase.")
            } catch {
                print(" Failed to insert allowance: \(error)")
            }
        }

        NotificationCenter.default.post(name: NSNotification.Name("remaininfAllowancelabel"), object: nil)
        Amounttextfield.text = ""
        self.dismiss(animated: true, completion: nil)
    }

}
