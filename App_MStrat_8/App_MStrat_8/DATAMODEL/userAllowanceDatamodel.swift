//
//  userAllowanceDatamodel.swift
//  App_MStrat_8
//
//  Created by student-2 on 26/12/24.
//

import Foundation
import Supabase

struct Allowance:Codable {
    var amount: Double
    var isRecurring: Bool?
    var duration: Duration?
    var customDate: Date?
    var user_id : Int?
    
    mutating func deductAmount(_ expenseAmount: Double) {
        if expenseAmount <= amount {
            amount -= expenseAmount
        } else {
            print("Insufficient allowance. Cannot deduct \(expenseAmount).")
        }
    }
}

enum Duration: String, Codable {
    case oneWeek = "1 Week"
    case twoWeeks = "2 Weeks"
    case oneMonth = "1 Month"
    case twoMonths = "2 Months"
    case custom = "Custom"
}

let firstAllowance = Allowance(amount: 0.0, isRecurring: true, duration: .oneWeek, customDate: nil)

class AllowanceDataModel {
    private var allowances: [Allowance] = []
    static let shared = AllowanceDataModel()
    
    private init() {
        allowances.append(firstAllowance)
    }
    
    func getAllAllowances() -> [Allowance] {
        return self.allowances
    }
    
    func getAllowances(by duration: Duration) -> [Allowance] {
        return allowances.filter { $0.duration == duration }
    }
    
    func addAllowance(_ allowance: Allowance) {
        allowances.append(allowance)
    }
    
    func deductExpense(fromAllowance index: Int, expenseAmount: Double) {
        guard allowances.indices.contains(index) else {
            print("Invalid allowance index.")
            return
        }
        var updatedAllowance = allowances[index]
        updatedAllowance.deductAmount(expenseAmount)
        allowances[index] = updatedAllowance
    }
    
 

}
