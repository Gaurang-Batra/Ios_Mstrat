import UIKit
import SwiftUI
import Foundation

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

    @IBOutlet weak var noExpenseImage: UIImageView!
    @IBOutlet weak var noexpenseaddedlabel: UILabel!
    
    @IBOutlet weak var nobadgesimage: UIImageView!
    
    var expenses: [Expense] = []
    var currentGoal: Goal?
    var goals: [Goal] = []
    private var goalSavings: Int = 0
    var userId: Int? {
        didSet {
            print("✅ Set userId in homeViewController: \(userId ?? 0)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // ✅ Verify userId is set
        guard let userId = userId else {
            print("❌ No userId set in homeViewController, redirecting to login")
            redirectToLogin()
            return
        }
        print("🌟 Home page loaded with userId: \(userId)")

        // UI Setup
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
        NotificationCenter.default.addObserver(self, selector: #selector(updateTotalExpense), name: NSNotification.Name("remainingAllowanceLabel"), object: nil)

        styleTextField(AddExpense)
        refreshExpenses()
        updateTotalExpense()
        loadGoals()
        
        Addgoalgoalbutton.setTitle("Add Goal", for: .normal)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateGoalButton()
        refreshExpenses() // Refresh data when view reappears
    }

    // MARK: - Goal UI
    @objc func updateSavedAmount(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let goalAmount = userInfo["goalAmount"] as? Int {
            savedAmountLabel.text = "\(goalAmount)"
            UIView.animate(withDuration: 0.1) {
                self.Addgoalgoalbutton.frame.origin.y -= 22
            }
            loadGoals()
        }
    }

    private func loadGoals() {
        goals = GoalDataModel.shared.getAllGoals()
        if let _ = goals.first {
            Addgoalgoalbutton.setTitle("0", for: .normal)
            Addgoalgoalbutton.setTitleColor(.black, for: .normal)
            lineDotted.isHidden = false
        } else {
            Addgoalgoalbutton.setTitle("Add Goal", for: .normal)
            lineDotted.isHidden = true
        }
    }

    private func updateGoalButton() {
        Addgoalgoalbutton.setTitle(goalSavings == 0 ? "Add Goal" : "\(goalSavings)", for: .normal)
    }

    @IBAction func addSavingTapped(_ sender: UIButton) {
        guard let expenseText = AddExpense.text, !expenseText.isEmpty, let expenseValue = Int(expenseText) else {
            showAlert(title: "Invalid Input", message: "Please enter a valid number.")
            return
        }

        goalSavings += expenseValue
        updateGoalButton()

        for (index, threshold) in badgeThresholds.enumerated() {
            if goalSavings >= threshold && unlockedBadgeCount <= index {
                unlockedBadgeCount = index + 1
                badgesCollectionView.reloadData()
            }
        }

        if let goalAmountText = savedAmountLabel.text,
           let goalAmount = Int(goalAmountText),
           goalSavings >= goalAmount {
            showAlert(title: "Goal Hit!", message: "Congratulations! You have reached your goal")
            goalSavings = 0
            savedAmountLabel.text = ""
            Addgoalgoalbutton.setTitle("Add Goal", for: .normal)
            Addgoalgoalbutton.setTitleColor(.systemBlue, for: .normal)
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
        guard let userId = self.userId else {
            print("⚠️ userId is nil, cannot update expenses")
            redirectToLogin()
            return
        }

        Task {
            async let allowances = AllowanceDataModel.shared.getAllowances(forUserId: userId)
            async let expenses = ExpenseDataModel.shared.fetchExpensesForUser(userId: userId)
            
            let totalAllowance = (await allowances).reduce(0.0) { $0 + $1.amount }
            let totalExpense = (await expenses).reduce(0.0) { $0 + Double($1.amount) }
            let remaining = totalAllowance - totalExpense
            
            DispatchQueue.main.async {
                self.totalexpenselabel.text = String(format: "Rs. %.0f", totalExpense)
                self.remaininfAllowancelabel.text = String(format: "Rs. %.0f", remaining)
                self.remaininfAllowancelabel.textColor = remaining < 0 ? .red : .systemGreen
                if remaining < 0 {
                    self.showAlert(title: "Allowance Limit Reached", message: "You have exceeded your total allowance!")
                }
            }
        }
    }

    @objc private func refreshExpenses() {
        guard let userId = self.userId else {
            print("⚠️ userId is nil, cannot refresh expenses")
            redirectToLogin()
            return
        }

        Task {
            await ExpenseDataModel.shared.fetchExpensesFromSupabase(for: userId)
            self.expenses = ExpenseDataModel.shared.getAllExpenses()
            DispatchQueue.main.async {
                // Toggle visibility of noExpenseImage and noexpenseaddedlabel based on expenses count
                self.noExpenseImage.isHidden = !self.expenses.isEmpty
                self.noexpenseaddedlabel.isHidden = !self.expenses.isEmpty
                // Reload collection view
                self.collectionView.reloadData()
                // Reload badges collection view to ensure badge visibility is updated
                self.badgesCollectionView.reloadData()
                print("✅ Refreshed expenses for userId: \(userId), count: \(self.expenses.count)")
            }
        }
    }

    private func redirectToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = loginVC
            window.makeKeyAndVisible()
        }
    }

    private func styleTextField(_ textField: UITextField) {
        textField.frame.size.height = 45
        let cornerRadius: CGFloat = 10
        let maskPath = UIBezierPath(roundedRect: textField.bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
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
        return UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 0)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.97), heightDimension: .absolute(100))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 0)
            return section
        }
    }

    var badgesarray: [String] = ["Rs_500-removebg-preview", "Rs_500-removebg-preview", "Rs_500-removebg-preview", "Rs_500-removebg-preview"]
    let badgeThresholds = [100, 500, 1000, 2000]
    var unlockedBadgeCount = 0

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return min(expenses.count, 4)
        } else if collectionView == self.badgesCollectionView {
            // Toggle visibility of nobadgesimage based on unlockedBadgeCount
            self.nobadgesimage.isHidden = unlockedBadgeCount > 0
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
            cell.Badgesimage.image = UIImage(named: badgesarray[indexPath.row])
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
        path.move(to: CGPoint(x: centerX, y: 10))
        path.addLine(to: CGPoint(x: centerX, y: mainlabel.bounds.height - 10))
        dottedLine.path = path.cgPath
        dottedLine.strokeColor = UIColor.black.withAlphaComponent(0.4).cgColor
        dottedLine.lineWidth = 1.5
        dottedLine.lineDashPattern = [6, 2]
        mainlabel.layer.addSublayer(dottedLine)
    }

    func createHorizontalLayoutForBadges() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(180), heightDimension: .absolute(150))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .absolute(80))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        return UICollectionViewCompositionalLayout(section: section)
    }

    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddExpenseScreen",
           let nav = segue.destination as? UINavigationController,
           let destVC = nav.viewControllers.first as? CategoryNameViewController {
            destVC.userId = self.userId
        } else if segue.identifier == "showGoalViewController",
                  let nav = segue.destination as? UINavigationController,
                  let destVC = nav.viewControllers.first as? GoalViewController {
            destVC.userId = self.userId
        } else if segue.identifier == "AddAllowance",
                  let nav = segue.destination as? UINavigationController,
                  let destVC = nav.viewControllers.first as? AllowanceViewController {
            destVC.userId = self.userId
        }
    }
}
