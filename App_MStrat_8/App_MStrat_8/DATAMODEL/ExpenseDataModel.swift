//
//  ExpenseDataModel.swift
//  App_MStrat_8
//
//  Created by student-2 on 26/12/24.
//
import Foundation
import UIKit

enum ExpenseCategory: String, CaseIterable {
    case food = "Food"
    case grocery = "Grocery"
    case fuel = "Fuel"
    case bills = "Bills"
    case travel = "Travel"
    case other = "Other"
    

    var associatedImage: UIImage {
        switch self {
        case .food:
//            print("inside food")
            return UIImage(named: "icons8-kawaii-pizza-50") ?? UIImage()
        case .grocery:
//            print("inside grocery")
            return UIImage(named: "icons8-vegetarian-food-50") ?? UIImage()
        case .fuel:
            return UIImage(named: "icons8-fuel-50") ?? UIImage()
        case .bills:
            return UIImage(named: "icons8-cheque-50") ?? UIImage()
        case .travel:
            return UIImage(named: "icons8-holiday-50") ?? UIImage()
        case .other:
            return UIImage(named: "icons8-more-50-2") ?? UIImage()
        }
    }
    
//    var associatedImage: UIImage {
//            switch self {
//            case .food:
//                let image = UIImage(named: "icons8-kawaii-pizza-50")
//                print("Food image loaded: \(image != nil)")
//                return image ?? UIImage()
//            case .grocery:
//                let image = UIImage(named: "icons8-vegetarian-food-50")
//                print("Grocery image loaded: \(image != nil)")
//                return image ?? UIImage()
//            case .fuel:
//                let image = UIImage(named: "icons8-fuel-50")
//                print("Fuel image loaded: \(image != nil)")
//                return image ?? UIImage()
//            case .bills:
//                let image = UIImage(named: "icons8-cheque-50")
//                print("Bills image loaded: \(image != nil)")
//                return image ?? UIImage()
//            case .travel:
//                let image = UIImage(named: "icons8-holiday-50")
//                print("Travel image loaded: \(image != nil)")
//                return image ?? UIImage()
//            case .other:
//                let image = UIImage(named: "icons8-more-50-2")
//                print("Other image loaded: \(image != nil)")
//                return image ?? UIImage()
//            }
//        }
}

struct Expense {
    let id: Int
    var itemName: String
    var amount: Int
    var image: UIImage
    var date: Date
    var category: ExpenseCategory
    var duration: Date?
    var isRecurring: Bool
}


//let firstExpense = Expense(
//    id: 1,
//    itemName: "food wash",
//    amount: 1200,
//    image: ExpenseCategory.food.associatedImage,
//    category: .food,
//    duration: DateFormatter().date(from: "2024-01-15"),
//    isRecurring: false
//)
//
//let secondExpense = Expense(
//    id: 2,
//    itemName: "home grocery",
//    amount: 3000,
//    image: ExpenseCategory.grocery.associatedImage,
//    category: .grocery,
//    duration: DateFormatter().date(from: "2024-06-01"),
//    isRecurring: true
//)
//
//let thirdExpense = Expense(
//    id: 3,
//    itemName: "Banana",
//    amount: 5000,
//    image: ExpenseCategory.grocery.associatedImage,
//    category: .grocery,
//    duration: DateFormatter().date(from: "2025-12-31"),
//    isRecurring: true
//)
//
//let fourthExpense = Expense(
//    id: 4,
//    itemName: "Pay food Insurance",
//    amount: 1500,
//    image: ExpenseCategory.food.associatedImage,
//    category: .food,
//    duration: DateFormatter().date(from: "2020-01-15"),
//    isRecurring: false
//)
//
//let fifthExpense = Expense(
//    id: 5,
//    itemName: "Monthly grocery",
//    amount: 3000,
//    image: ExpenseCategory.grocery.associatedImage,
//    category: .grocery,
//    duration: DateFormatter().date(from: "2025-06-01"),
//    isRecurring: true
//)
//
//let sixthExpense = Expense(
//    id: 6,
//    itemName: "Grocery Shopping",
//    amount: 200,
//    image: ExpenseCategory.grocery.associatedImage,
//    category: .grocery,
//    duration: DateFormatter().date(from: "2025-12-31"),
//    isRecurring: true
//)
class ExpenseDataModel {
    private var expenses: [Expense] = []
    static let shared = ExpenseDataModel()

    private init() {
        preloadExpenses()
    }

    func getAllExpenses() -> [Expense] {
        return expenses
    }
    
    private func getDate(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string) ?? Date()
    }
    
    private func preloadExpenses() {
        let expenseList = [
            Expense(id: 1, itemName: "food wash", amount: 1200, image: ExpenseCategory.food.associatedImage, date: getDate("2025-04-08"), category: .food, duration: getDate(""), isRecurring: false),
            Expense(id: 2, itemName: "food wash", amount: 1200, image: ExpenseCategory.food.associatedImage, date: getDate("2025-03-08"), category: .food, duration: getDate(""), isRecurring: false),
            Expense(id: 3, itemName: "food wash", amount: 1200, image: ExpenseCategory.food.associatedImage, date: getDate("2025-01-08"), category: .food, duration: getDate(""), isRecurring: false),
            Expense(id: 4, itemName: "food wash", amount: 1200, image: ExpenseCategory.food.associatedImage, date: getDate("2025-03-08"), category: .food, duration: getDate(""), isRecurring: false),
            Expense(id: 5, itemName: "food wash", amount: 1200, image: ExpenseCategory.food.associatedImage, date: getDate("2025-01-08"), category: .food, duration: getDate(""), isRecurring: false),
        ]

        self.expenses = expenseList
    }

    func addExpense(itemName: String, amount: Int, image: UIImage, category: ExpenseCategory, date: Date, duration: Date?, isRecurring: Bool) {
        let newId = (expenses.last?.id ?? 0) + 1
        let newExpense = Expense(
            id: newId,
            itemName: itemName,
            amount: amount,
            image: image,
            date: date,
            category: category,
            duration: duration,
            isRecurring: isRecurring
        )
        expenses.insert(newExpense, at: 0)
        print("New expense added: \(newExpense.itemName) with ID \(newExpense.id) on \(newExpense.date). Recurring on: \(newExpense.duration != nil ? "\(newExpense.duration!)" : "N/A"). Is recurring: \(newExpense.isRecurring)")
    }


    func checkRecurringExpenses() {
        let currentDate = Date()
        let calendar = Calendar.current

        for expense in expenses where expense.isRecurring {
            if let duration = expense.duration,
               calendar.isDate(currentDate, inSameDayAs: duration) {
                promptUserForRecurringExpense(expense)
            }
        }
    }

    private func promptUserForRecurringExpense(_ expense: Expense) {
        print("Do you want to add \(expense.itemName) again?")
    }

    func groupExpensesByDate() -> [String: [Expense]] {
        var groupedByDate: [String: [Expense]] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for expense in expenses {
            let dateKey = dateFormatter.string(from: expense.date) // Group by `date`, not `duration`
            groupedByDate[dateKey, default: []].append(expense)
        }

        return groupedByDate
    }

    func groupedExpenses() -> [[Expense]] {
        return groupExpensesByDate().values.map { $0 }
    }

    func sectionTitles() -> [String] {
        return groupExpensesByDate().keys.sorted()
    }
    
    func updateExpense(_ updatedExpense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == updatedExpense.id }) {
            expenses[index] = updatedExpense
        }
    }

}
