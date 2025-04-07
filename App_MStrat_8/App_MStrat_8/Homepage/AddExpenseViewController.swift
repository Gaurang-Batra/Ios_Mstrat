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
    private let categories: [ExpenseCategory] = [.food, .grocery, .fuel, .bills, .travel, .other]
    private var selectedCategory: ExpenseCategory? // To store the selected category
    private var selectedImage: UIImage?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recurringSwitch.isOn = false
        deadlineview.isHidden = true
        calendarButton.isHidden = true
        durationlabel.isHidden = true
        Enterdedline.isHidden = true

        // Setup category buttons with images only (no titles)
        for (index, button) in CategoryButton.enumerated() {
            
            if index < categories.count {
                
                let category = categories[index]
                
                button.setImage(category.associatedImage, for: .normal)
              
                
                button.setTitle(nil, for: .normal) // Remove the title
                button.tag = index
                // Assign a tag for identification
                
                
                button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)

                // Adjust the image view content mode if necessary
                button.imageView?.contentMode = .scaleAspectFit
            }
        }

        // Add target for switch toggle
        recurringSwitch.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
    }

    // MARK: - Actions
    @objc func switchToggled() {
        // Toggle visibility based on switch state
        let isSwitchOn = recurringSwitch.isOn
        deadlineview.isHidden = !isSwitchOn
        calendarButton.isHidden = !isSwitchOn
        durationlabel.isHidden = !isSwitchOn
        Enterdedline.isHidden = !isSwitchOn
    }
    
    
    @IBAction func cancelbuttontapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func calendarButtonTapped(_ sender: UIButton) {
        showDatePicker()
    }

    func showDatePicker() {
        view.addSubview(datePicker)
        datePicker.frame = CGRect(x: 0, y: view.frame.height - datePicker.frame.height, width: view.frame.width, height: datePicker.frame.height)
        UIView.animate(withDuration: 0.3) {
            self.datePicker.frame.origin.y -= self.datePicker.frame.height
        }
    }

    @objc func categoryButtonTapped(_ sender: UIButton) {
        let categoryIndex = sender.tag
        
        // Ensure the category index is within bounds
        guard categoryIndex >= 0, categoryIndex < categories.count else {
            print("Invalid category index: \(categoryIndex)")
            return
        }
        
        // Update selected category
        selectedCategory = categories[categoryIndex]
        
        // Update associated image if available
        selectedImage = selectedCategory?.associatedImage
        
        // Debugging print
        if let categoryName = selectedCategory?.rawValue {
            print("Selected category: \(categoryName)")
        } else {
            print("No category selected")
        }
        
        // Visual feedback for the selected button
        updateButtonSelection(for: sender)
    }

    // Update button appearance to indicate selection
    private func updateButtonSelection(for selectedButton: UIButton) {
        for button in CategoryButton {
            button.backgroundColor = button == selectedButton ? UIColor.systemBlue: UIColor.systemGray5
        }
    }


    @IBAction func addexpenseTapped(_ sender: Any) {
        guard let itemName = itemNameTextField.text, !itemName.isEmpty,
              let amountText = amountTextField.text, let amount = Int(amountText),
              let selectedCategory = selectedCategory,
              let selectedImage = selectedImage else {
            print("Please provide valid input.")
            return
        }

        let isRecurring = recurringSwitch.isOn
        let duration = isRecurring ? datePicker.date : nil

        // Automatically use today's date for the expense
        let today = Date()

        ExpenseDataModel.shared.addExpense(
            itemName: itemName,
            amount: amount,
            image: selectedImage,
            category: selectedCategory,
            date: today,
            duration: duration,
            isRecurring: isRecurring
        )

        self.dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name("ExpenseAdded"), object: nil)
        }
    }

}
