import UIKit
import Supabase

struct SupabaseGoal: Codable {
    var title: String
    var amount: Int
    var deadline: Date
    var savings: Int?
}

class GoalViewController: UIViewController {
    @IBOutlet weak var savebutton: UIBarButtonItem!
    @IBOutlet weak var Goaltitletextfield: UITextField!
    @IBOutlet weak var GoalAmount: UITextField!
    @IBOutlet weak var Goaldeadline: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        GoalDataModel.shared.addGoal(newGoal)
        NotificationCenter.default.post(name: NSNotification.Name("GoalAdded"), object: nil, userInfo: ["goalAmount": amount])

        Task {
            await saveGoalToSupabase(goal: newGoal)
        }

        self.dismiss(animated: true, completion: nil)
    }
    func saveGoalToSupabase(goal: Goal) async {
        let supabaseGoal = SupabaseGoal(
            title: goal.title,
            amount: goal.amount,
            deadline: goal.deadline,
            savings: goal.savings ?? 0
        )

        do {
            let client = SupabaseAPIClient.shared.supabaseClient
            let response = try await client
                .from("goals")
                .insert([supabaseGoal])
                .execute()
            print("✅ Goal saved to Supabase: \(response)")
        } catch {
            print("❌ Error saving goal: \(error.localizedDescription)")
        }
    }
}
    
