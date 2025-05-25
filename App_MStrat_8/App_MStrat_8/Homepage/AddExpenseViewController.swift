import UIKit

class CategoryNameViewController: UIViewController {
    
    @IBOutlet var CategoryButton: [UIButton]!
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var recurringSwitch: UISwitch!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var durationlabel: UILabel!
    @IBOutlet weak var Enterdedline: UILabel!
    @IBOutlet weak var deadlineview: UIView!

    private let datePicker = UIDatePicker()
    private var blurEffectView: UIVisualEffectView? // Store the blur view
    private let categories: [ExpenseCategory] = [.food, .grocery, .fuel, .bills, .travel, .other]
    private var selectedCategory: ExpenseCategory?
    private var selectedImage: UIImage?
    private var selectedDuration: Date? // Store the selected duration for recurring expenses

    var userId: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("this id is in add expense \(userId)")
        
        recurringSwitch.isOn = false
        deadlineview.isHidden = true
        calendarButton.isHidden = true
        durationlabel.isHidden = true
        Enterdedline.isHidden = true
        
        // Ensure calendar button is interactable
        calendarButton.isUserInteractionEnabled = true
        calendarButton.isEnabled = true
        
        // Setup category buttons
        for (index, button) in CategoryButton.enumerated() {
            if index < categories.count {
                let category = categories[index]
                button.setImage(category.associatedImage, for: .normal)
                button.setTitle(nil, for: .normal)
                button.tag = index
                button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
                button.imageView?.contentMode = .scaleAspectFit
            }
        }
        
        // Configure date picker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline // Show full calendar grid
        datePicker.minimumDate = Date() // Block past dates
        datePicker.addTarget(self, action: #selector(datePickerChanged(_:)), for: .valueChanged)
        
        // Add target for switch toggle
        recurringSwitch.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
    }

    @objc func datePickerChanged(_ sender: UIDatePicker) {
        selectedDuration = sender.date // Store the selected duration
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy" // e.g., "May 5, 2026"
        Enterdedline.text = dateFormatter.string(from: sender.date) // Update label
        print("Selected duration: \(sender.date)")
    }

    @objc func switchToggled() {
        let isSwitchOn = recurringSwitch.isOn
        deadlineview.isHidden = !isSwitchOn
        calendarButton.isHidden = !isSwitchOn
        calendarButton.isEnabled = isSwitchOn
        calendarButton.isUserInteractionEnabled = isSwitchOn
        durationlabel.isHidden = !isSwitchOn
        Enterdedline.isHidden = !isSwitchOn
    }

    @IBAction func cancelbuttontapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func calendarButtonTapped(_ sender: UIButton) {
        print("Calendar button tapped") // Debug tap
        // Remove any existing date picker and blur view to prevent duplicates
        datePicker.removeFromSuperview()
        blurEffectView?.removeFromSuperview()
        view.viewWithTag(999)?.removeFromSuperview()
        
        showDatePicker()
    }

    func showDatePicker() {
        // Add blur effect
        let blurEffect = UIBlurEffect(style: .extraLight) // Subtle blur
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView?.frame = view.bounds
        blurEffectView?.alpha = 0 // Start transparent
        blurEffectView?.backgroundColor = UIColor.white.withAlphaComponent(0.1) // Further soften blur
        if let blurEffectView = blurEffectView {
            view.addSubview(blurEffectView)
        }
        
        // Configure date picker frame (start at bottom of screen)
        datePicker.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: datePicker.frame.height)
        datePicker.backgroundColor = .white // Ensure visibility
        view.addSubview(datePicker)
        
        // Add a Done button
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.frame = CGRect(x: view.frame.width - 80, y: view.frame.height - 40, width: 60, height: 30)
        doneButton.addTarget(self, action: #selector(dismissDatePicker), for: .touchUpInside)
        doneButton.tag = 999
        view.addSubview(doneButton)
        
        // Animate up to higher position
        UIView.animate(withDuration: 0.3) {
            self.blurEffectView?.alpha = 1 // Fade in blur
            self.datePicker.frame.origin.y = self.view.frame.height - self.datePicker.frame.height - 100 // 100 points higher
            doneButton.frame.origin.y = self.view.frame.height - self.datePicker.frame.height - 100 - 40
        }
    }

    @objc func dismissDatePicker() {
        UIView.animate(withDuration: 0.3, animations: {
            self.blurEffectView?.alpha = 0 // Fade out blur
            self.datePicker.frame.origin.y = self.view.frame.height
            self.view.viewWithTag(999)?.frame.origin.y = self.view.frame.height - 40
        }, completion: { _ in
            self.blurEffectView?.removeFromSuperview()
            self.blurEffectView = nil
            self.datePicker.removeFromSuperview()
            self.view.viewWithTag(999)?.removeFromSuperview()
        })
    }

    @objc func categoryButtonTapped(_ sender: UIButton) {
        let categoryIndex = sender.tag
        guard categoryIndex >= 0, categoryIndex < categories.count else {
            print("Invalid category index: \(categoryIndex)")
            return
        }
        
        selectedCategory = categories[categoryIndex]
        selectedImage = selectedCategory?.associatedImage
        
        if let categoryName = selectedCategory?.rawValue {
            print("Selected category: \(categoryName)")
        }
        
        updateButtonSelection(for: sender)
    }

    private func updateButtonSelection(for selectedButton: UIButton) {
        for button in CategoryButton {
            button.backgroundColor = button == selectedButton ? UIColor.systemBlue : UIColor.systemGray5
        }
    }

    @IBAction func addexpenseTapped(_ sender: Any) {
        guard let itemName = itemNameTextField.text, !itemName.isEmpty,
              let amountText = amountTextField.text, let amount = Int(amountText),
              let selectedCategory = selectedCategory else {
            print("Please provide valid input.")
            return
        }
        
        let isRecurring = recurringSwitch.isOn
        if isRecurring {
            guard let duration = selectedDuration else {
                print("Please select a duration date for recurring expense.")
                return
            }
            // Ensure duration is strictly after today
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let selectedDay = calendar.startOfDay(for: duration)
            if selectedDay <= today {
                print("Please select a future date for recurring expense.")
                return
            }
        }
        
        let newExpense = ExpenseDataModel.shared.addExpense(
            itemName: itemName,
            amount: amount,
            category: selectedCategory,
            date: Date(), // Always use current date (e.g., May 24, 2025)
            duration: isRecurring ? selectedDuration : nil, // Use selected duration for recurring
            isRecurring: isRecurring,
            userId: userId
        )
        
        Task {
            await ExpenseDataModel.shared.saveExpenseToSupabase(newExpense)
        }
        
        self.dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name("ExpenseAdded"), object: nil)
        }
    }
}
