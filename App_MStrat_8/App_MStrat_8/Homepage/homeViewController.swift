import UIKit
import Supabase

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
    
    // Badge-related properties
    let badgeThresholds = [100, 500, 1000, 1500]
    var badgesarray: [String] = []
    let badgeImages = [
        100: "badge_100",
        500: "badge_500",
        1000: "badge_1000",
        1500: "badge_1500"
    ]
    var unlockedBadgeCount = 0
    
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let userId = userId else {
            print("❌ No userId set in homeViewController, redirecting to login")
            redirectToLogin()
            return
        }
        print("🌟 Home page loaded with userId: \(userId)")

        // UI setup
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

        // Add loading indicator
        loadingIndicator.center = ContentView.center
        ContentView.addSubview(loadingIndicator)

        // Observers
        NotificationCenter.default.addObserver(self, selector: #selector(refreshExpenses), name: NSNotification.Name("ExpenseAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateSavedAmount(_:)), name: NSNotification.Name("GoalAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTotalExpense), name: NSNotification.Name("remainingAllowanceLabel"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshExpenses), name: .newExpenseAddedInGroup, object: nil)

        styleTextField(AddExpense)
        
        // Fetch initial data
        Task {
            await fetchInitialData()
        }
        
        Addgoalgoalbutton.setTitle("Add Goal", for: .normal)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await fetchInitialData()
        }
    }

    private func fetchInitialData() async {
        guard let userId = userId else {
            print("❌ No userId, cannot fetch initial data")
            DispatchQueue.main.async {
                self.redirectToLogin()
            }
            return
        }
        
        DispatchQueue.main.async {
            self.loadingIndicator.startAnimating()
            self.noexpenseaddedlabel.text = "Loading data..."
        }
        
        do {
            let goals = try await GoalDataModel.shared.fetchGoalsFromSupabase(userId: userId)
            await ExpenseDataModel.shared.fetchExpensesFromSupabase(for: userId)
            // Fetch user badges
            if let user = await UserDataModel.shared.getUser(fromSupabaseBy: userId) {
                self.badgesarray = user.badges ?? []
                self.unlockedBadgeCount = self.badgesarray.count
            }
            DispatchQueue.main.async {
                self.goals = goals
                self.loadGoals()
                self.expenses = ExpenseDataModel.shared.getAllExpenses()
                self.refreshExpenses()
                self.updateTotalExpense()
                self.noexpenseaddedlabel.isHidden = !self.expenses.isEmpty
                self.noExpenseImage.isHidden = !self.expenses.isEmpty
                self.nobadgesimage.isHidden = self.unlockedBadgeCount > 0
                self.badgesCollectionView.reloadData()
                self.loadingIndicator.stopAnimating()
                print("✅ Initial data loaded: \(goals.count) goals, \(self.expenses.count) expenses, \(self.badgesarray.count) badges")
            }
        } catch {
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                self.showAlert(title: "Error", message: "Failed to load data: \(error.localizedDescription)")
            }
        }
    }

    func loadGoals() {
        goals = GoalDataModel.shared.getAllGoals()
        if let firstGoal = goals.first {
            currentGoal = firstGoal
            goalSavings = firstGoal.savings ?? 0
            savedAmountLabel.text = "\(firstGoal.amount)"
            Addgoalgoalbutton.setTitle("\(goalSavings)", for: .normal)
            Addgoalgoalbutton.setTitleColor(.black, for: .normal)
            lineDotted.isHidden = false
        } else {
            currentGoal = nil
            goalSavings = 0
            savedAmountLabel.text = ""
            Addgoalgoalbutton.setTitle("Add Goal", for: .normal)
            Addgoalgoalbutton.setTitleColor(.systemBlue, for: .normal)
            lineDotted.isHidden = true
        }
        nobadgesimage.isHidden = unlockedBadgeCount > 0
        badgesCollectionView.reloadData()
    }

    private func updateBadges(savingsAmount: Int) async {
        guard let userId = userId else { return }
        var newBadges = badgesarray // Start with existing badges
        
        // Check for new badges to award based on savings
        for threshold in badgeThresholds {
            if savingsAmount >= threshold {
                if let badgeImage = badgeImages[threshold], !newBadges.contains(badgeImage) {
                    newBadges.append(badgeImage)
                }
            }
        }
        
        // Only update if new badges were earned
        if newBadges.count > badgesarray.count {
            badgesarray = newBadges
            unlockedBadgeCount = newBadges.count
            await updateUserBadgesInSupabase(badges: newBadges)
            
            DispatchQueue.main.async {
                self.nobadgesimage.isHidden = self.unlockedBadgeCount > 0
                self.badgesCollectionView.reloadData()
            }
        }
    }

    private func updateUserBadgesInSupabase(badges: [String]) async {
        guard let userId = userId else { return }
        do {
            try await SupabaseAPIClient.shared.supabaseClient
                .database
                .from("users")
                .update(["badges": badges])
                .eq("id", value: userId)
                .execute()
            print("✅ Updated badges for user \(userId): \(badges)")
            // Update cache
            if var user = UserDataModel.shared.getUser(by: userId) {
                user.badges = badges
                UserDataModel.shared.userCache[userId] = user
            }
        } catch {
            print("❌ Failed to update badges in Supabase: \(error)")
            DispatchQueue.main.async {
                self.showAlert(title: "Error", message: "Failed to update badges: \(error.localizedDescription)")
            }
        }
    }

    private func updateGoalButton() {
        Addgoalgoalbutton.setTitle(goalSavings == 0 && goals.isEmpty ? "Add Goal" : "\(goalSavings)", for: .normal)
    }

    @IBAction func addSavingTapped(_ sender: UIButton) {
        guard let expenseText = AddExpense.text, !expenseText.isEmpty, let expenseValue = Int(expenseText) else {
            showAlert(title: "Invalid Input", message: "Please enter a valid number.")
            return
        }

        guard let currentGoal = goals.first else {
            showAlert(title: "No Goal", message: "Please add a goal before saving.")
            return
        }

        Task {
            // Add savings to the goal
            await GoalDataModel.shared.addSavings(toGoalWithTitle: currentGoal.title, amount: expenseValue, userId: userId)

            // Sync goals with Supabase
            do {
                let goals = try await GoalDataModel.shared.fetchGoalsFromSupabase(userId: userId)
                let newSavings = goals.first?.savings ?? 0
                DispatchQueue.main.async {
                    self.goals = goals
                    self.loadGoals()
                    
                    // Check if goal was deleted
                    if GoalDataModel.shared.getGoal(by: currentGoal.title) == nil {
                        self.showAlert(title: "Goal Hit!", message: "Congratulations! You have reached your goal for '\(currentGoal.title)'")
                        self.Addgoalgoalbutton.frame.origin.y += 22
                    }
                    
                    self.AddExpense.text = nil
                }
                // Update badges based on new savings amount
                await updateBadges(savingsAmount: newSavings)
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Failed to sync goals: \(error.localizedDescription)")
                }
            }
        }
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

    @objc private func updateSavedAmount(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let goalAmount = userInfo["goalAmount"] as? Int {
            savedAmountLabel.text = "\(goalAmount)"
            UIView.animate(withDuration: 0.1) {
                self.Addgoalgoalbutton.frame.origin.y -= 22
            }
            Task {
                await fetchInitialData()
            }
        }
    }

    @objc private func updateTotalExpense() {
        guard let userId = self.userId else {
            print("⚠️ userId is nil, cannot update expenses")
            redirectToLogin()
            return
        }

        Task {
            async let allowances = AllowanceDataModel.shared.getAllowances(forUserId: userId)
            async let personalExpenses = ExpenseDataModel.shared.fetchExpensesForUser(userId: userId)

            let groups = await GroupDataModel.shared.fetchGroupsForUser(userId: userId)
            let groupIds = groups.compactMap { $0.id }
            var totalGroupExpense: Double = 0.0

            let client = SupabaseAPIClient.shared.supabaseClient

            if !groupIds.isEmpty {
                do {
                    let response: PostgrestResponse = try await client
                        .from("user_groupSplitexpense")
                        .select("amount,expense_id")
                        .eq("user_id", value: userId)
                        .in("group_id", values: groupIds)
                        .execute()

                    if let dataArray = response.data as? [[String: Any]] {
                        for record in dataArray {
                            if let amount = record["amount"] as? Double,
                               let expenseId = record["expense_id"] as? Int {
                                totalGroupExpense += amount
                                print("📋 User \(userId) owes ₹\(amount) for expense ID \(expenseId)")
                            } else {
                                print("⚠️ Invalid data for expense ID \(record["expense_id"] ?? "unknown"): amount = \(record["amount"] ?? "nil")")
                            }
                        }
                    } else {
                        print("ℹ️ No group expense records found for user \(userId) in groups \(groupIds)")
                    }
                    print("✅ Total group expense for user \(userId): ₹\(totalGroupExpense)")
                } catch {
                    print("❌ Error fetching user_groupSplitexpense: \(error.localizedDescription)")
                    totalGroupExpense = 0.0
                    DispatchQueue.main.async {
                        self.showAlert(title: "Data Error", message: "Failed to fetch group expenses. Totals may be incomplete.")
                    }
                }
            } else {
                print("ℹ️ User \(userId) is not part of any groups")
            }

            let totalAllowance = (await allowances).reduce(0.0) { $0 + $1.amount }
            let totalPersonalExpense = (await personalExpenses).reduce(0.0) { $0 + Double($1.amount) }
            let totalExpense = totalPersonalExpense + totalGroupExpense
            let remaining = totalAllowance - totalExpense

            DispatchQueue.main.async {
                self.totalexpenselabel.text = String(format: "Rs. %.0f", totalExpense)
                self.remaininfAllowancelabel.text = String(format: "Rs. %.0f", remaining)
                self.remaininfAllowancelabel.textColor = remaining < 0 ? .red : .systemGreen
                if remaining < 0 {
                    self.showAlert(title: "Allowance Limit Reached", message: "You have exceeded your total allowance!")
                }
                print("📊 Final: Personal: ₹\(totalPersonalExpense), Group: ₹\(totalGroupExpense), Total: ₹\(totalExpense), Remaining: ₹\(remaining)")
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
                self.noExpenseImage.isHidden = !self.expenses.isEmpty
                self.noexpenseaddedlabel.isHidden = !self.expenses.isEmpty
                self.collectionView.reloadData()
                self.badgesCollectionView.reloadData()
                print("✅ Refreshed expenses for userId: \(userId), count: \(self.expenses.count)")
                self.updateTotalExpense()
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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return min(expenses.count, 4)
        } else if collectionView == self.badgesCollectionView {
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
