import UIKit
import Supabase

class GoalViewController: UIViewController {
    
    @IBOutlet weak var savebutton: UIBarButtonItem!
    @IBOutlet weak var Goaltitletextfield: UITextField!
    @IBOutlet weak var GoalAmount: UITextField!
    @IBOutlet weak var Goaldeadline: UIDatePicker!
    
    var userId: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("This is in the GoalViewController, userId: \(userId ?? -1)")
        
        // ✅ Lock past dates - only allow today or future dates
        Goaldeadline.minimumDate = Date()
    }

    @IBAction func cancelbutton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func savebuttonTapped(_ sender: Any) {
        guard let title = Goaltitletextfield.text, !title.isEmpty,
              let amountText = GoalAmount.text, let amount = Int(amountText) else {
            print("Please enter valid title and amount")
            return
        }

        let deadline = Goaldeadline.date
        let newGoal = Goal(title: title, amount: amount, deadline: deadline, savings: 0, user_id: userId)
        
        // Add to local model
        GoalDataModel.shared.addGoal(newGoal)
        
        // Save to Supabase and wait for completion
        Task {
            do {
                try await GoalDataModel.shared.saveToSupabase(userId: userId)
                // Notify after successful save
                NotificationCenter.default.post(name: NSNotification.Name("GoalAdded"), object: nil, userInfo: ["goalAmount": amount])
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            } catch {
                print("❌ Failed to save goal to Supabase: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Failed to save goal: \(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
