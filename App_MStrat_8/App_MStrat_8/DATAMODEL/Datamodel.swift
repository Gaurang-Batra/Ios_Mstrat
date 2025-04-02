//
//  DATAMODELS.swift
//  App_MStrat_8
//
// UserDataModel.swift
//
// Created by Ankush Sharma on 12/12/24.
import Foundation
import UIKit

//user-----------
//struct User {
//    let id: Int
//    var email: String
//    var fullname: String
//    var password: String
//    var isVerified: Bool
//    var badges: [String]
//    var currentGoal: Goal?
//    var expenses: [Expense]
//}
//
//let firstUser = User(
//    id: 1,
//    email: "johndoe@example.com",
//    fullname: "John Doe",
//    password: "password123",
//    isVerified: true,
//    badges: [],
//    currentGoal: nil,
//    expenses: []
//)
//let secondUser = User(
//    id: 2,
//    email: "janesmith@example.com",
//    fullname: "Jane Smith",
//    password: "password456",
//    isVerified: false,
//    badges: [],
//    currentGoal: nil,
//    expenses: []
//)
//let thirdUser = User(
//    id: 3,
//    email: "alicej@example.com",
//    fullname: "Alice Johnson",
//    password: "password789",
//    isVerified: true,
//    badges: [],
//    currentGoal: nil,
//    expenses: []
//)
//
//class UserDataModel {
//    private var users: [User] = []
//    static let shared = UserDataModel()
//
//    private init() {
//        users.append(firstUser)
//        users.append(secondUser)
//        users.append(thirdUser)
//    }
//
//    func getAllUsers() -> [User] {
//        return self.users
//    }
//
//    func getUser(by id: Int) -> User? {
//        return users.first { $0.id == id }
//    }
//
//    func assignGoal(to userId: Int, goal: Goal) {
//        guard let index = users.firstIndex(where: { $0.id == userId }) else { return }
//        users[index].currentGoal = goal
//
//        let badge: String
//        switch goal.type {
//        case .yearly:
//            badge = "Monthly Achiever"
//        case .monthly:
//            badge = "Weekly Achiever"
//        case .weekly:
//            badge = "Daily Achiever"
//        case .daily:
//            badge = "Quick Challenger"
//        case .custom:
//            badge = "Custom Achiever"
//        }
//
//        users[index].badges.append(badge)
//    }
//
//    func getUserBadges(for userId: Int) -> [String] {
//        return users.first { $0.id == userId }?.badges ?? []
//    }
//}

//for Goal-----------
//
//struct Goal {
//    let id: Int
//    var title: String
//    var amount: Int
//    var deadline: Date
//    var savings: Int
//    var type: GoalType
//}
//enum GoalType {
//    case daily
//    case weekly
//    case monthly
//    case yearly
//    case custom
//}
//
//
//let firstGoal = Goal(id: 1, title: "Buy a New Laptop", amount: 1200, deadline: DateFormatter().date(from: "2025-01-15")!, savings: 78, type: .yearly)
//let secondGoal = Goal(id: 2, title: "Vacation Fund", amount: 3000, deadline: DateFormatter().date(from: "2025-06-01")!, savings: 787, type: .monthly)
//let thirdGoal = Goal(id: 3, title: "Emergency Savings", amount: 5000, deadline: DateFormatter().date(from: "2025-12-31")!, savings: 454, type: .daily)
//
//class GoalDataModel {
//    private var goals: [Goal] = []
//    static let shared = GoalDataModel()
//
//    private init() {
//        goals.append(firstGoal)
//        goals.append(secondGoal)
//        goals.append(thirdGoal)
//    }
//
//    func getAllGoals() -> [Goal] {
//        return self.goals
//    }
//
//    func addGoal(_ goal: Goal) {
//        goals.append(goal)
//    }
//
//    func getGoal(by id: Int) -> Goal? {
//        return goals.first { $0.id == id }
//    }
//    func addSavings(toGoalWithId id: Int, amount: Int) {
//        guard let index = goals.firstIndex(where: { $0.id == id }) else { return }
//        goals[index].savings += amount
//        if goals[index].savings > goals[index].amount {
//            print("Congratulations! You've exceeded your goal savings for \(goals[index].title).")
//        } else {
//            print("Added \(amount) to \(goals[index].title). Current savings: \(goals[index].savings) out of \(goals[index].amount).")
//        }
//    }
//
//
////    func deleteGoal(by id: Int) {
////        if let index = goals.firstIndex(where: { $0.id == id }) {
////            goals.remove(at: index)
////        }
////    }
//}
//
////for Allowance-------------
//
//struct Allowance {
//    var amount: Double
//    var isRecurring: Bool
//    var duration: Duration?
//    var customDate: Date?
//    mutating func deductAmount(_ expenseAmount: Double) {
//           if expenseAmount <= amount {
//               amount -= expenseAmount
//           } else {
//               print("Insufficient allowance. Cannot deduct \(expenseAmount).")
//           }
//       }
//}
//
//enum Duration: String {
//    case oneWeek = "1 Week"
//    case twoWeeks = "2 Weeks"
//    case oneMonth = "1 Month"
//    case twoMonths = "2 Months"
//    case custom = "Custom"
//}
//
//let firstAllowance = Allowance(amount: 50.0, isRecurring: true, duration: .oneWeek, customDate: nil)
//let secondAllowance = Allowance(amount: 100.0, isRecurring: false, duration: nil, customDate: Date())
//let thirdAllowance = Allowance(amount: 75.0, isRecurring: true, duration: .oneMonth, customDate: nil)
//
//class AllowanceDataModel {
//    private var allowances: [Allowance] = []
//    static let shared = AllowanceDataModel()
//    
//    private init() {
//        allowances.append(firstAllowance)
//        allowances.append(secondAllowance)
//        allowances.append(thirdAllowance)
//    }
//    
//    func getAllAllowances() -> [Allowance] {
//        return self.allowances
//    }
//    
//    func getAllowances(by duration: Duration) -> [Allowance] {
//        return allowances.filter { $0.duration == duration }
//    }
//    
//    func addAllowance(_ allowance: Allowance) {
//        allowances.append(allowance)
//    }
//    func deductExpense(fromAllowance index: Int, expenseAmount: Double) {
//            guard allowances.indices.contains(index) else {
//                print("Invalid allowance index.")
//                return
//            }
//            allowances[index].deductAmount(expenseAmount)
//        }
//}
//
//for Addexpence----------

//enum ExpenseCategory: String, CaseIterable {
//    case car = "Car"
//    case rent = "Rent"
//    case grocery = "Grocery"
//    case gym = "Gym"
//    case other = "Other"
//}
//
//struct Expense {
//    let id: Int
//    var itemName: String
//    var amount: Int
//    var image: UIImage
//    var category: ExpenseCategory
//    var duration: Date?
//    var isRecurring: Bool
//}
//
//let firstExpense = Expense(
//    id: 1,
//    itemName: "Buy a New Laptop",
//    amount: 1200,
//    image: UIImage(named: "laptop")!,
//    category: .other,
//    duration: DateFormatter().date(from: "2025-01-15"),
//    isRecurring: false
//)
//
//let secondExpense = Expense(
//    id: 2,
//    itemName: "Vacation Fund",
//    amount: 3000,
//    image: UIImage(named: "vacation")!,
//    category: .other,
//    duration: DateFormatter().date(from: "2025-06-01"),
//    isRecurring: true
//)
//
//let thirdExpense = Expense(
//    id: 3,
//    itemName: "Emergency Savings",
//    amount: 5000,
//    image: UIImage(named: "savings")!,
//    category: .other,
//    duration: DateFormatter().date(from: "2025-12-31"),
//    isRecurring: true
//)
//
//class ExpenseDataModel {
//    private var expenses: [Expense] = []
//    static let shared = ExpenseDataModel()
//
//    private init() {
//        expenses.append(firstExpense)
//        expenses.append(secondExpense)
//        expenses.append(thirdExpense)
//    }
//
//    func getAllExpenses() -> [Expense] {
//        return self.expenses
//    }
//
//    func addExpense(_ expense: Expense) {
//        if ExpenseCategory.allCases.contains(expense.category) {
//            expenses.append(expense)
//            AllowanceDataModel.shared.deductExpense(fromAllowance: 0, expenseAmount: Double(expense.amount))
//        } else {
//            print("Invalid category. Expense not added.")
//        }
//    }
//
//    func checkRecurringExpenses() {
//        let currentDate = Date()
//
//        for expense in expenses {
//            if expense.isRecurring, let duration = expense.duration {
//                if Calendar.current.isDate(currentDate, inSameDayAs: duration) {
//                    promptUserForRecurringExpense(expense)
//                }
//            }
//        }
//    }
//
//    private func promptUserForRecurringExpense(_ expense: Expense) {
//        print("Do you want to add \(expense.itemName) again?")
//    }
//}


//for creting groups----------------

//struct Group {
//    var id : Int
//    var groupName: String
//    var category: String
//    var members: [Int]
//}
//
//class GroupDataModel {
//    private var groups: [Group] = []
//    private var users: [User] = []
//    
//    static let shared = GroupDataModel()
//
//    private init() {
//        users.append(User(id: 101, email: "user1@example.com", fullname: "john", password: "password", isVerified: true, badges: [], currentGoal: nil, expenses: []))
//        users.append(User(id: 102, email: "user2@example.com", fullname: "steve", password: "password", isVerified: true, badges: [], currentGoal: nil, expenses: []))
//        users.append(User(id: 103, email: "user3@example.com", fullname: "jack", password: "password", isVerified: true, badges: [], currentGoal: nil, expenses: []))
//        
//        groups.append(Group(id: 1, groupName: "Tech Lovers", category: "Technology", members: [101, 102]))
//        groups.append(Group(id: 3, groupName: "Travel Enthusiasts", category: "Travel", members: [103]))
//    }
//
//    func createGroup(groupName: String, category: String, members: [Int]) {
//        let newGroup = Group(id: (groups.last?.id ?? 0) + 1, groupName: groupName, category: category, members: members)
//        groups.append(newGroup)
//    }
//
//    func addMemberToGroup(groupName: String, userId: Int) {
//        if let groupIndex = groups.firstIndex(where: { $0.groupName == groupName }) {
//            if !groups[groupIndex].members.contains(userId) {
//                groups[groupIndex].members.append(userId)
//            }
//        }
//    }
//
//    func getAllGroups() -> [Group] {
//        return self.groups
//    }
//
//    func getGroupByName(groupName: String) -> Group? {
//        return groups.first { $0.groupName == groupName }
//    }
//
//    func addSplitExpense(expense: ExpenseSplitForm) {
//        guard let groupIndex = groups.firstIndex(where: { $0.id == expense.groupId }) else { return }
//
//        let group = groups[groupIndex]
//        let memberIds = group.members
//
//        for memberId in memberIds {
//            if let user = users.first(where: { $0.id == memberId }) {
//                print("Notifying \(user.fullname) about the new expense: \(expense.name)")
//            }
//        }
//    }
//}
//
////for creating expense split form ----------------
//struct ExpenseSplitForm {
//    var name: String
//    var category: String
//    var totalAmount: Double
//    var paidBy: String
//    var groupId: Int
//    var image: UIImage
//    var splitOption: SplitOption
//    var splitAmounts: [String: Double]?
//    var date: Date
//}
//
//enum SplitOption {
//    case equally
//    case unequally
//}
//
//class SplitExpenseDataModel {
//    private var expenseSplits: [ExpenseSplitForm] = []
//    static let shared = SplitExpenseDataModel()
//
//    private init() {
//        let firstExpenseSplit = ExpenseSplitForm(
//            name: "Dinner with Friends",
//            category: "Food",
//            totalAmount: 100.0,
//            paidBy: "John Doe",
//            groupId: 1,
//            image: UIImage(named: "dinner.jpg")!,
//            splitOption: .equally,
//            splitAmounts: nil,
//            date: Date()
//        )
//        
//        let secondExpenseSplit = ExpenseSplitForm(
//            name: "Trip Expense",
//            category: "Travel",
//            totalAmount: 500.0,
//            paidBy: "Alice Johnson",
//            groupId: 2,
//            image: UIImage(named: "trip.jpg")!,
//            splitOption: .unequally,
//            splitAmounts: ["John Doe": 200.0, "Alice Johnson": 300.0],
//            date: Date()
//        )
//        
//        expenseSplits.append(firstExpenseSplit)
//        expenseSplits.append(secondExpenseSplit)
//    }
//
//    func getAllExpenseSplits() -> [ExpenseSplitForm] {
//        return self.expenseSplits
//    }
//
//    func getExpenseSplits(forGroup groupId: Int) -> [ExpenseSplitForm] {
//        return expenseSplits.filter { $0.groupId == groupId }
//    }
//
//    func getAmountToBePaid(by participant: String, for expense: ExpenseSplitForm) -> Double? {
//        if let splitAmounts = expense.splitAmounts {
//            return splitAmounts[participant]
//        }
//        return nil
//    }
//
//    func addExpenseSplit(expense: ExpenseSplitForm) {
//        expenseSplits.append(expense)
//    }
//
//    func updateSplitAmounts(expense: inout ExpenseSplitForm, newSplitAmounts: [String: Double]) {
//        if expense.splitOption == .unequally {
//            expense.splitAmounts = newSplitAmounts
//        }
//    }
//
//    func deleteExpenseSplit(name: String) {
//        if let index = expenseSplits.firstIndex(where: { $0.name == name }) {
//            expenseSplits.remove(at: index)
//        }
//    }
//}

enum ExpenseTimeSegment {
    case daily
    case weekly
    case monthly
    case yearly
}

struct ExpenseData {
    var date: Date
    var totalAmount: Double
}

class ExpenseGraphDataModel {
    private var dailyExpenses: [ExpenseData] = []
    private var weeklyExpenses: [ExpenseData] = []
    private var monthlyExpenses: [ExpenseData] = []
    private var yearlyExpenses: [ExpenseData] = []

    static let shared = ExpenseGraphDataModel()

    private init() {
        generateMockData()
    }

    func getExpenses(for segment: ExpenseTimeSegment) -> [ExpenseData] {
        switch segment {
        case .daily:
            return dailyExpenses
        case .weekly:
            return weeklyExpenses
        case .monthly:
            return monthlyExpenses
        case .yearly:
            return yearlyExpenses
        }
    }

    private func generateMockData() {
        let calendar = Calendar.current
        let today = Date()
//        for i in 0..<7 {
//            if let day = calendar.date(byAdding: .day, value: -i, to: today) {
//                dailyExpenses.append(ExpenseData(date: day, totalAmount: Double.random(in: 20...200)))
//            }
//        }
//        for i in 0..<4 {
//            if let week = calendar.date(byAdding: .weekOfYear, value: -i, to: today) {
//                weeklyExpenses.append(ExpenseData(date: week, totalAmount: Double.random(in: 200...800)))
//            }
//        }
//
//        for i in 0..<6 {
//            if let month = calendar.date(byAdding: .month, value: -i, to: today) {
//                monthlyExpenses.append(ExpenseData(date: month, totalAmount: Double.random(in: 500...2000)))
//            }
//        }
//
//        for i in 0..<5 {
//            if let year = calendar.date(byAdding: .year, value: -i, to: today) {
//                yearlyExpenses.append(ExpenseData(date: year, totalAmount: Double.random(in: 5000...20000)))
//            }
//        }
    }
}
//struct GroupSplitTests {
//    var image: UIImage?
//    var name: String
//}
//
//var group: [GroupSplitTests] = [
//    
//        GroupSplitTests(image: UIImage(named: "Spl") ?? UIImage(systemName: "Split"), name: "Travel"),
//        GroupSplitTests(image: UIImage(named: "icons8-history-50") ?? UIImage(systemName: "icons8-history-50"), name: "Work"),
//        
//        GroupSplitTests(image: UIImage(named: "Split1") ?? UIImage(systemName: "Split"), name: "Travel"),
//        GroupSplitTests(image: UIImage(named: "icons8-history-50") ?? UIImage(systemName: "icons8-history-50"), name: "Work")
//    
//
//]


