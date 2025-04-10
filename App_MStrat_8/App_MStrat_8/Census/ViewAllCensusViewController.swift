import UIKit

class ViewAllCensusViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView! // Connect this to your storyboard's table
    var expenses: [Expense] = []
    var groupedExpenses: [[Expense]] = []
    var sectionTitles: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        expenses = ExpenseDataModel.shared.getAllExpenses()

        // Group expenses by date (duration)
        groupExpensesByDate()

        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 15
        tableView.clipsToBounds = true

        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension

        tableView.reloadData()
    }

    // MARK: - Table View Delegate Methods

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    // MARK: - Table View Data Source Methods

    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedExpenses.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedExpenses[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ViewAllCensusTableViewCell", for: indexPath) as? ViewAllCensusTableViewCell else {
            fatalError("Unable to dequeue ViewAllCensusTableViewCell")
        }

        let expense = groupedExpenses[indexPath.section][indexPath.row]

        // Debugging: Check if category is being set
        print("Expense Category: \(expense.category.rawValue)")

        // Configure cell with expense details
        cell.expenseimage.image = expense.image
        cell.pricelabel.text = "Rs \(expense.amount)"
        cell.categorylabel.text = expense.category.rawValue.trimmingCharacters(in: .whitespacesAndNewlines)  // Display category name
        cell.titlelabel.text = expense.item_name

        return cell
    }

    // MARK: - Custom Header Setup

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }

    // MARK: - Grouping and Sorting Expenses by Date

    private func groupExpensesByDate() {
        var groupedByDate: [String: [Expense]] = [:] // Grouped by date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Format can be adjusted based on requirements

        // Iterate through all expenses and group them by date (duration)
        for expense in expenses {
            // Get the date as a string to use as the key for grouping
            let dateKey = dateFormatter.string(from: expense.date) // Default to current date if duration is nil
            
            // If the dateKey doesn't exist, create a new entry in the dictionary
            if groupedByDate[dateKey] == nil {
                groupedByDate[dateKey] = []
            }

            // Append the expense to the appropriate date group
            groupedByDate[dateKey]?.append(expense)
        }

        // Flatten the grouped data to be used in the tableView
        groupedExpenses = groupedByDate.values.map { $0 } // Convert the grouped dictionary into an array of expenses

        // Create section titles from the date keys and sort them in chronological order
        sectionTitles = Array(groupedByDate.keys).sorted { $0 < $1 } // Sort the dates chronologically

        // Debugging: Check grouping
        print("Grouped Expenses: \(groupedExpenses)")
        print("Section Titles: \(sectionTitles)")

        // Reload the table view to reflect the changes
        tableView.reloadData()
    }
}
