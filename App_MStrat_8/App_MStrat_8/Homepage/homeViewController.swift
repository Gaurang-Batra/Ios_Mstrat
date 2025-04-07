import UIKit
import SwiftUI

class homeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var expensebutton: UIButton!
    @IBOutlet weak var mainlabel: UIView!
    @IBOutlet var circleview: [UIView]!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var roundcornerciew: [UIView]!
    @IBOutlet weak var AddExpense: UITextField!
    @IBOutlet weak var totalexpenselabel: UILabel!
    @IBOutlet weak var remaininfAllowancelabel: UILabel!
    @IBOutlet weak var Addgoalgoalbutton: UIButton!
    @IBOutlet weak var addSaving: UIButton!
    @IBOutlet weak var lineDotted: UILabel!
    @IBOutlet weak var savedAmountLabel: UILabel!
    
    @IBOutlet weak var ContentView: UIView!
    
   
    
    var expenses: [Expense] = []
    var currentGoal: Goal?
    var goals: [Goal] = []
    private var goalSavings: Int = 0
    var userId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        
//        ScrollView.alwaysBounceVertical = true
//        ScrollView.showsVerticalScrollIndicator = true

        
        print("this id is on home page \(userId)")
        lineDotted.isHidden = true
        mainlabel.layoutIfNeeded()
        createVerticalDottedLineInBalanceContainer()
        circleview.forEach { makeCircular(view: $0) }
        roundcornerciew.forEach { roundCorners(of: $0, radius: 10) }

        expensebutton.layer.cornerRadius = expensebutton.frame.size.width / 2
        expensebutton.clipsToBounds = true

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = createLayout()

        NotificationCenter.default.addObserver(self, selector: #selector(refreshExpenses), name: NSNotification.Name("ExpenseAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateSavedAmount(_:)), name: NSNotification.Name("GoalAdded"), object: nil)

        styleTextField(AddExpense)
        refreshExpenses()
        updateTotalExpense()
        NotificationCenter.default.addObserver(self, selector: #selector(updateTotalExpense), name: NSNotification.Name("remaininfAllowancelabel"), object: nil)
        loadGoals()
        
        // Set initial title of Addgoalgoalbutton
        Addgoalgoalbutton.setTitle("Add Goal", for: .normal)
    }

    @objc func updateSavedAmount(_ notification: Notification) {
        // Get the goal amount from the notification
        if let userInfo = notification.userInfo,
           let goalAmount = userInfo["goalAmount"] as? Int {
            
            // Update the label with the goal amount
            savedAmountLabel.text = "\(goalAmount)"
            UIView.animate(withDuration: 0.1) {
                // Shift the button 29 units upwards (modify its y position)
                self.Addgoalgoalbutton.frame.origin.y -= 22
            }

            // Check if there are any goals and show/hide the dotted line
            loadGoals() // Reload goals to check if any exist
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("GoalAdded"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateGoalButton()
    }

    private func loadGoals() {
        // Get all goals from the shared GoalDataModel
        goals = GoalDataModel.shared.getAllGoals()
        
        // Update the title of the Add Goal button to reflect the first goal's amount if exists
        if let firstGoal = goals.first {
            Addgoalgoalbutton.setTitle("0", for: .normal)
            Addgoalgoalbutton.setTitleColor(.black, for: .normal)
            // Show the dotted line if a goal is present
            lineDotted.isHidden = false
        } else {
            Addgoalgoalbutton.setTitle("Add Goal", for: .normal)
            // Hide the dotted line if no goal is present
            lineDotted.isHidden = true
        }
    }

    private func updateGoalButton() {
        if goalSavings == 0 {
            Addgoalgoalbutton.setTitle("Add Goal", for: .normal)
        } else {
            
            Addgoalgoalbutton.setTitle("\(goalSavings)", for: .normal)
        }

    }

    @IBAction func addSavingTapped(_ sender: UIButton) {
        guard let expenseText = AddExpense.text, !expenseText.isEmpty, let expenseValue = Int(expenseText)
                
                
                
        else {
            showAlert(title: "Invalid Input", message: "Please enter a valid number.")
            return
        }

        // Add the entered value to the current savings
        goalSavings += expenseValue
        
        

        // Update the goal button title
        updateGoalButton()
        
        if let goalAmountText = savedAmountLabel.text,
               let goalAmount = Int(goalAmountText),
               goalSavings >= goalAmount {
                // Logic for when the goal is hit
                print("Goal Hit! Congratulations! You have reached your goal.")
                showAlert(title: "Goal Hit!", message: "Congratulations! You have reached your goal")
                // Reset savings and update UI
                goalSavings = 0
                savedAmountLabel.text = ""
                Addgoalgoalbutton.setTitle("Add Goal", for: .normal)
            Addgoalgoalbutton.setTitleColor(UIColor.systemBlue, for: .normal)
                Addgoalgoalbutton.frame.origin.y += 22
            lineDotted.isHidden = true
            AddExpense.text = nil
                updateGoalButton()
                return
            }
        // Clear the AddExpense text field after adding
        AddExpense.text = nil
    }

    @objc private func updateTotalExpense() {
        let totalExpense = AllowanceDataModel.shared.getAllAllowances().reduce(0) { $0 + $1.amount }
        remaininfAllowancelabel.text = String(format: " Rs.%.0f", totalExpense)
    }

    @objc private func refreshExpenses() {
        expenses = ExpenseDataModel.shared.getAllExpenses()
        collectionView.reloadData()
        
        // Add functionality to update total expense label when new expense is appended
        updateTotalExpenseLabelWithAppendedExpense()
    }

    private func updateTotalExpenseLabelWithAppendedExpense() {
        // Calculate the total of all appended expenses
        let appendedTotal = expenses.reduce(0) { $0 + $1.amount }
        
        // Update the totalexpenselabel with the new total value
        totalexpenselabel.text = "Rs.\(appendedTotal)"
    }

    private func styleTextField(_ textField: UITextField) {
        textField.frame.size.height = 45
        let cornerRadius: CGFloat = 10
        let maskPath = UIBezierPath(
            roundedRect: textField.bounds,
            byRoundingCorners: [.topLeft, .bottomLeft],
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        textField.layer.mask = maskLayer
    }

    private func roundCorners(of view: UIView, radius: CGFloat) {
        view.layer.cornerRadius = radius
        view.layer.masksToBounds = true
    }

    private func makeCircular(view: UIView) {
        let size = min(view.frame.width, view.frame.height)
        view.layer.cornerRadius = size / 2
        view.layer.masksToBounds = true
    }

    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 0)
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.97),
                heightDimension: .absolute(100)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 0)
            return section
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (expenses.count>=4){
            return 4
        }
        else{
            return expenses.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? SetExpenseCollectionViewCell else {
            fatalError("Unable to dequeue SetExpenseCollectionViewCell")
        }
        let expense = expenses[indexPath.row]
        cell.configure(with: expense)
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        return cell
    }

    func createVerticalDottedLineInBalanceContainer() {
        let dottedLine = CAShapeLayer()
        let path = UIBezierPath()
        let centerX = mainlabel.bounds.width / 2
        let startY: CGFloat = 10
        let endY = mainlabel.bounds.height - 10
        path.move(to: CGPoint(x: centerX, y: startY))
        path.addLine(to: CGPoint(x: centerX, y: endY))
        dottedLine.path = path.cgPath
        dottedLine.strokeColor = UIColor.black.withAlphaComponent(0.4).cgColor
        dottedLine.lineWidth = 1.5
        dottedLine.lineDashPattern = [6, 2]
        mainlabel.layer.addSublayer(dottedLine)
    }

    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
