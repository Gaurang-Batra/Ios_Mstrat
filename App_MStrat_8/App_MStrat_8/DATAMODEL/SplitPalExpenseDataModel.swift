//
//  SplitPalExpenseDataModel.swift
//  App_MStrat_8
//
//  Created by student-2 on 26/12/24.
//
import Foundation
import UIKit

extension Notification.Name {
    static let newExpenseAddedInGroup = Notification.Name("newExpenseAddedInGroup")
}


struct ExpenseSplitForm {
    var name: String
    var category: String
    var totalAmount: Double
    var paidBy: String
    var groupId: Int?
    var image: UIImage?
    var splitOption: SplitOption?
    var splitAmounts: [String: Double]
    var payee: [Int]
    var date: Date
    var ismine: Bool
}

enum SplitOption : String, Codable{
    case equally
    case unequally
}

class SplitExpenseDataModel {
    private var expenseSplits: [ExpenseSplitForm] = []
    static let shared = SplitExpenseDataModel()

    private init() {
        let firstExpenseSplit = ExpenseSplitForm(
            name: "Dinner with Friends",
            category: "Food",
            totalAmount: 100.0,
            paidBy: "Ajay (You)",
            groupId: 1,
            image: UIImage(named: "icons8-holiday-50"),
            splitOption: .equally,
            splitAmounts: ["John Doe": 200.0, "Alice Johnson": 300.0],
            payee: [1],
            date: Date(),
            ismine: true
        )

        let secondExpenseSplit = ExpenseSplitForm(
            name: "Trip Expense",
            category: "Travel",
            totalAmount: 500.0,
            paidBy: "Alice Johnson",
            groupId: 2,
            image: UIImage(named: "icons8-holiday-50"),
            splitOption: .unequally,
            splitAmounts: ["John Doe": 200.0, "Alice Johnson": 300.0],
            payee: [2],
            date: Date(),
            ismine: false
        )

        expenseSplits.append(firstExpenseSplit)
        expenseSplits.append(secondExpenseSplit)
    }

    func getAllExpenseSplits() -> [ExpenseSplitForm] {
        return self.expenseSplits
    }

    func getExpenseSplits(forGroup groupId: Int) -> [ExpenseSplitForm] {
        return expenseSplits.filter { $0.groupId == groupId }
    }

    func addExpenseSplit(expense: ExpenseSplitForm) {
        expenseSplits.insert(expense, at: 0)
               NotificationCenter.default.post(name: .newExpenseAddedInGroup, object: nil)
          
    }


    func updateSplitAmounts(expense: inout ExpenseSplitForm, newSplitAmounts: [String: Double]) {
        if expense.splitOption == .unequally {
            expense.splitAmounts = newSplitAmounts
        }
    }

    func deleteExpenseSplit(name: String) {
        if let index = expenseSplits.firstIndex(where: { $0.name == name }) {
            expenseSplits.remove(at: index)
        }
    }
}
