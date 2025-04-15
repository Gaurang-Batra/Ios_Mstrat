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
    
    @IBOutlet weak var badgesCollectionView: UICollectionView!
    
    
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
        
//        UserDataModel.shared.getAllUsersfromsupabase { users, error in
//               if let error = error {
//                   print("Error fetching users: \(error.localizedDescription)")
//               } else if let users = users {
//                   print("This is all the user data: \(users)")
//                   // You can also store it if needed:
//                   // self.users = users
//               }
//           }

        
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
        badgesCollectionView.delegate = self
        badgesCollectionView.dataSource = self
        badgesCollectionView.collectionViewLayout = createHorizontalLayoutForBadges()


        NotificationCenter.default.addObserver(self, selector: #selector(refreshExpenses), name: NSNotification.Name("ExpenseAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateSavedAmount(_:)), name: NSNotification.Name("GoalAdded"), object: nil)
        
        NotificationCenter.default.post(name: NSNotification.Name("ExpenseAdded"), object: nil)


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
        guard let expenseText = AddExpense.text, !expenseText.isEmpty, let expenseValue = Int(expenseText) else {
            showAlert(title: "Invalid Input", message: "Please enter a valid number.")
            return
        }

        goalSavings += expenseValue
        updateGoalButton()

        // 🏆 Unlock new badges based on thresholds
        for (index, threshold) in badgeThresholds.enumerated() {
            if goalSavings >= threshold && unlockedBadgeCount <= index {
                unlockedBadgeCount = index + 1 // Unlock next badge
                badgesCollectionView.reloadData()
            }
        }

        // 🎯 Check for goal hit
        if let goalAmountText = savedAmountLabel.text,
           let goalAmount = Int(goalAmountText),
           goalSavings >= goalAmount {
            showAlert(title: "Goal Hit!", message: "Congratulations! You have reached your goal")
            goalSavings = 0
            savedAmountLabel.text = ""
            Addgoalgoalbutton.setTitle("Add Goal", for: .normal)
            Addgoalgoalbutton.setTitleColor(UIColor.systemBlue, for: .normal)
            Addgoalgoalbutton.frame.origin.y += 22
            lineDotted.isHidden = true
            updateGoalButton()
        }

        AddExpense.text = nil
    }
    @IBAction func expenseButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "AddExpenseScreen", sender: self)
    }
    
    @IBAction func AddGoalTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showGoalViewController", sender: self)
    }

    @IBAction func AddaAllowancetappde(_ sender: Any) {
        performSegue(withIdentifier: "AddAllowance", sender: self)
    }
    



    @objc private func updateTotalExpense() {
        let totalAllowance = AllowanceDataModel.shared.getAllAllowances().reduce(0.0) { $0 + $1.amount }
        let totalExpense = ExpenseDataModel.shared.getAllExpenses().reduce(0.0) { $0 + Double($1.amount) }

        let remaining = totalAllowance - totalExpense

        // Show both total expense and remaining (can be negative now)
        totalexpenselabel.text = String(format: "Rs. %.0f", totalExpense)
        remaininfAllowancelabel.text = String(format: "Rs. %.0f", remaining)
        
        if remaining < 0 {
            remaininfAllowancelabel.textColor = .red
        } else {
            remaininfAllowancelabel.textColor = .systemGreen // or your default color
        }

    }

    @objc private func refreshExpenses() {
        expenses = ExpenseDataModel.shared.getAllExpenses()
        collectionView.reloadData()
        
        // Add functionality to update total expense label when new expense is appended
        updateTotalExpense()
//        updateTotalExpenseLabelWithAppendedExpense()
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
    var badgesarray : [String] = ["Rs_500-removebg-preview","Rs_500-removebg-preview","Rs_500-removebg-preview","Rs_500-removebg-preview"]
    
    let badgeThresholds = [100, 500, 1000, 2000]
   

    var unlockedBadgeCount = 0 // Keeps track of how many badges are unlocked

    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView{
            return min(expenses.count,4)
        }else if collectionView == self.badgesCollectionView
        {
            return unlockedBadgeCount
        }
        return 0
       
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == self.collectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? SetExpenseCollectionViewCell else {
                fatalError("Unable to dequeue SetExpenseCollectionViewCell")
            }
            let expense = expenses[indexPath.row]
            cell.configure(with: expense)
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            return cell

        } else if collectionView == self.badgesCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "badges", for: indexPath) as? BadgesCollectionViewCell else {
                fatalError("Unable to dequeue BadgesCollectionViewCell")
            }
            let imageName = badgesarray[indexPath.row]
            cell.Badgesimage.image = UIImage(named: imageName)
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            return cell
        }


        fatalError("Unknown collectionView")
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
    
    func createHorizontalLayoutForBadges() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(180),
            heightDimension: .absolute(150)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(100), // Adjust based on expected total width
            heightDimension: .absolute(80)   // Height of the collection view
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        return UICollectionViewCompositionalLayout(section: section)
    }



    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddExpenseScreen" {
            // The destination is a UINavigationController
            if let navController = segue.destination as? UINavigationController,
               let destinationVC = navController.viewControllers.first as? CategoryNameViewController {
                destinationVC.userId = self.userId
            }
        }
        else if segue.identifier == "showGoalViewController" {
            // The destination is a UINavigationController
            if let navController = segue.destination as? UINavigationController,
               let destinationVC = navController.viewControllers.first as? GoalViewController {
                destinationVC.userId = self.userId
            }
        }
        
        else if segue.identifier == "AddAllowance" {
            // The destination is a UINavigationController
            if let navController = segue.destination as? UINavigationController,
               let destinationVC = navController.viewControllers.first as? AllowanceViewController {
                destinationVC.userId = self.userId
            }
        }
    }


    
    
}
