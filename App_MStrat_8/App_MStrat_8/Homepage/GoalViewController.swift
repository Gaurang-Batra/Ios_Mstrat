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
        let newGoal = Goal(title: title, amount: amount, deadline: deadline, savings: 0)
        
        // Add to local model
        GoalDataModel.shared.addGoal(newGoal)
        
        // Notify for UI updates elsewhere
        NotificationCenter.default.post(name: NSNotification.Name("GoalAdded"), object: nil, userInfo: ["goalAmount": amount])

        // Save all current goals to Supabase
        Task {
            await GoalDataModel.shared.saveToSupabase(userId: userId)
        }

        self.dismiss(animated: true, completion: nil)
    }
}
