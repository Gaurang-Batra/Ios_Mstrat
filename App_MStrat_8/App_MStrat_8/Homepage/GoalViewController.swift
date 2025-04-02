import UIKit

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
        print("Goal details: Title: \(title), Amount: \(amount), Deadline: \(deadline)")

        // Create a Goal object
        let newGoal = Goal(title: title, amount: amount, deadline: deadline, savings: 0)

        // Save the goal in the shared GoalDataModel
        GoalDataModel.shared.addGoal(newGoal)

        // Post a notification with the goal amount
        NotificationCenter.default.post(name: NSNotification.Name("GoalAdded"), object: nil, userInfo: ["goalAmount": amount])

        // Dismiss the view controller
        self.dismiss(animated: true, completion: nil)
    }
}
