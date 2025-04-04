//
//  CensusViewController.swift
//  App_MStrat_8
//
//  Created by student-2 on 15/01/25.
//

import UIKit

import Charts
import DGCharts

class CensusViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var ExpenseSegmentedController: UISegmentedControl!
    var expenses: [Expense] = []
    var groupedExpenses: [[Expense]] = []  // Array to store grouped expenses by date
    var sectionDates: [String] = []  // Dates for sections
    
    var userId : Int?
    var barChartView: BarChartView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print ( "this is om the census page : \(userId)")
        // Assign delegates
        tableView.delegate = self
        tableView.dataSource = self

        // Load expenses from the shared data model
        loadExpenses()
        ExpenseSegmentedController.selectedSegmentIndex = 0 // Default to weekly
        
        
        setupBarChart()

        // Remove the separator lines between table cells
        tableView.separatorStyle = .none

        // Round corners of the table view
        tableView.layer.cornerRadius = 15  // Adjust the corner radius as needed
        tableView.clipsToBounds = true      // Ensure content is clipped to rounded corners

        // Set row height for table view
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension

        // Add notification observer to listen for new expenses
        NotificationCenter.default.addObserver(self, selector: #selector(onExpenseAdded(_:)), name: NSNotification.Name("ExpenseAdded"), object: nil)
    }

    deinit {
        // Remove observer when the view controller is deallocated
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ExpenseAdded"), object: nil)
    }
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        showBarChartWithExpenseData()
    }

    
    private func setupBarChart() {
        barChartView = BarChartView()
        barChartView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(barChartView)

        NSLayoutConstraint.activate([
            barChartView.topAnchor.constraint(equalTo: ExpenseSegmentedController.bottomAnchor, constant: 20),
            barChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            barChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            barChartView.heightAnchor.constraint(equalToConstant: 240)
        ])
        
        // Padding inside chart
        barChartView.extraTopOffset = 20

        showBarChartWithExpenseData()
    }


    private func showBarChartWithExpenseData() {
        let allExpenses = ExpenseDataModel.shared.getAllExpenses()
        let calendar = Calendar.current
        let today = Date()
        
        var filteredExpenses: [Expense] = []
        var labels: [String] = []
        var values: [Double] = []

        switch ExpenseSegmentedController.selectedSegmentIndex {
        case 0: // Weekly (by weekday)
            filteredExpenses = allExpenses.filter {
                guard let diff = calendar.dateComponents([.day], from: $0.date, to: today).day else { return false }
                return diff >= 0 && diff < 7
            }

            var weekdayTotals: [Int: Double] = [:]
            for expense in filteredExpenses {
                let weekday = calendar.component(.weekday, from: expense.date)
                weekdayTotals[weekday, default: 0] += Double(expense.amount)
            }

            let weekdaySymbols = calendar.shortWeekdaySymbols
            for weekday in 1...7 {
                labels.append(weekdaySymbols[weekday % 7])
                values.append(weekdayTotals[weekday] ?? 0)
            }

        case 1: // Monthly (by month in current year)
            filteredExpenses = allExpenses.filter {
                calendar.isDate($0.date, equalTo: today, toGranularity: .year)
            }

            var monthTotals: [Int: Double] = [:]
            for expense in filteredExpenses {
                let month = calendar.component(.month, from: expense.date)
                monthTotals[month, default: 0] += Double(expense.amount)
            }

            let monthSymbols = calendar.shortMonthSymbols
            for month in 1...12 {
                labels.append(monthSymbols[month - 1])
                values.append(monthTotals[month] ?? 0)
            }

        case 2: // Yearly (e.g. 2022, 2023, 2024)
            let uniqueYears = Set(allExpenses.map { calendar.component(.year, from: $0.date) }).sorted()
            var yearTotals: [Int: Double] = [:]
            for expense in allExpenses {
                let year = calendar.component(.year, from: expense.date)
                yearTotals[year, default: 0] += Double(expense.amount)
            }

            for year in uniqueYears {
                labels.append("\(year)")
                values.append(yearTotals[year] ?? 0)
            }

        default:
            break
        }

        var entries: [BarChartDataEntry] = []
        for (index, value) in values.enumerated() {
            entries.append(BarChartDataEntry(x: Double(index), y: value))
        }

        let dataSet = BarChartDataSet(entries: entries, label: "Expenses")
        dataSet.colors = ChartColorTemplates.material()
        let data = BarChartData(dataSet: dataSet)

        barChartView.data = data
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.granularity = 1
        barChartView.rightAxis.enabled = false
        barChartView.animate(yAxisDuration: 1.4)
    }


    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 15
        tableView.clipsToBounds = true
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension

        // Move table view down below the chart
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: barChartView.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Notification Handler
    @objc private func onExpenseAdded(_ notification: Notification) {
        // Reload expenses and refresh the table view
        loadExpenses()
        tableView.reloadData()
    }

    // MARK: - Load Expenses
    private func loadExpenses() {
        expenses = ExpenseDataModel.shared.getAllExpenses() // Fetch all expenses
        groupExpensesByDate() // Group expenses by date
    }

    // MARK: - Table View Delegate Methods

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100 // Fixed height for each row
    }

    // MARK: - Table View Data Source Methods

    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedExpenses.count  // Return the number of sections based on the grouped expenses
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedExpenses[section].count  // Return the number of rows for the current section
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ViewAllCensusTableViewCell", for: indexPath) as? ViewAllCensusTableViewCell else {
            fatalError("Unable to dequeue ViewAllCensusTableViewCell")
        }

        let expense = groupedExpenses[indexPath.section][indexPath.row]

        // Configure the cell with expense data
        cell.expenseimage.image = expense.image
        cell.pricelabel.text = "Rs \(expense.amount)"
        cell.categorylabel.text = expense.category.rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        cell.titlelabel.text = expense.itemName

        return cell
    }

    // MARK: - Custom Header Setup

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionDates[section]  // Return the date for the current section
    }

    // MARK: - Grouping and Sorting Expenses by Date

    private func groupExpensesByDate() {
        // First, sort the expenses by date
        let sortedExpenses = expenses.sorted { (expense1, expense2) -> Bool in
            guard let date1 = expense1.duration, let date2 = expense2.duration else {
                return false
            }
            return date1 < date2  // Sort by date in ascending order
        }
        
        // Group expenses by date after sorting
        var grouped: [String: [Expense]] = [:]
        
        for expense in sortedExpenses {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"  // Format the date to display in a readable format
            let dateString = dateFormatter.string(from: expense.duration ?? Date())
            
            if grouped[dateString] == nil {
                grouped[dateString] = []
            }
            
            grouped[dateString]?.append(expense)
        }

        // Assign grouped expenses to the groupedExpenses array
        groupedExpenses = Array(grouped.values)
        
        // Assign section titles (dates)
        sectionDates = Array(grouped.keys).sorted()  // Sort the section dates (headers)
    }
}
