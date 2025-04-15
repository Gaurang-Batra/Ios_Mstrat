//
//  SplitPalExpenseDataModel.swift
//  App_MStrat_8
//
//  Created by student-2 on 26/12/24.
//
import Foundation
import UIKit
import Supabase
import PostgREST

extension Notification.Name {
    static let newExpenseAddedInGroup = Notification.Name("newExpenseAddedInGroup")
}


struct ExpenseSplitForm: Codable {
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

    enum CodingKeys: String, CodingKey {
        case name, category, totalAmount, paidBy, groupId, splitOption, splitAmounts, payee, date, ismine
       
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encode(totalAmount, forKey: .totalAmount)
        try container.encode(paidBy, forKey: .paidBy)
        try container.encodeIfPresent(groupId, forKey: .groupId)
        try container.encodeIfPresent(splitOption, forKey: .splitOption)
        try container.encode(splitAmounts, forKey: .splitAmounts)
        try container.encode(payee, forKey: .payee)
        try container.encode(ismine, forKey: .ismine)

       
        let dateString = ISO8601DateFormatter().string(from: date)
        try container.encode(dateString, forKey: .date)
    }
}


enum SplitOption : String, Codable{
    case equally
    case unequally
}
struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    init<T: Encodable>(_ value: T?) {
        _encode = { encoder in
            var container = encoder.singleValueContainer()
            try container.encode(value)
        }
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
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
    
    
    func uploadExpenseSplitToSupabase(_ expense: ExpenseSplitForm, completion: @escaping (Result<Void, Error>) -> Void) {
        let client = SupabaseAPIClient.shared.supabaseClient

        print("📤 Starting upload of expense split to Supabase...")

        var base64Image: String? = nil
        if let image = expense.image,
           let imageData = image.jpegData(compressionQuality: 0.7) {
            base64Image = imageData.base64EncodedString()
            print("🖼️ Image converted to base64.")
        } else {
            print("🚫 No image to upload.")
        }

        let formattedDate = ISO8601DateFormatter().string(from: expense.date)
        print("📅 Date formatted: \(formattedDate)")

        let payload: [String: AnyEncodable] = [
            "name": AnyEncodable(expense.name),
            "category": AnyEncodable(expense.category),
            "total_amount": AnyEncodable(expense.totalAmount),
            "paid_by": AnyEncodable(expense.paidBy),
            "group_id": AnyEncodable(expense.groupId),
            "image": AnyEncodable(base64Image),
            "split_option": AnyEncodable(expense.splitOption?.rawValue),
            "split_amounts": AnyEncodable(expense.splitAmounts),
            "payee": AnyEncodable(expense.payee),
            "date": AnyEncodable(formattedDate),
            "ismine": AnyEncodable(expense.ismine)
        ]

        print("🧾 Payload prepared: \(payload)")

        Task {
            do {
                print("📥 Inserting into splitexpenses table...")
                let response: PostgrestResponse = try await client
                    .from("splitexpenses")
                    .insert([payload])
                    .select()
                    .single()
                    .execute()

                print("✅ Expense inserted. Response received.")

                let responseData = response.data
                var json: [String: Any]
                if let data = responseData as? Data {
                    json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
                } else if let dict = responseData as? [String: Any] {
                    json = dict
                } else {
                    throw NSError(domain: "SupabaseError", code: 3,
                                  userInfo: [NSLocalizedDescriptionKey: "❌ Response data is in an unexpected format"])
                }

                print("📦 Parsed response: \(json)")

                guard let expenseId = json["id"] as? Int else {
                    throw NSError(domain: "SupabaseError", code: 1,
                                  userInfo: [NSLocalizedDescriptionKey: "❌ Failed to get inserted expense ID"])
                }

                print("🆔 Inserted expense ID: \(expenseId)")

                for (userIdString, amount) in expense.splitAmounts {
                    print("👤 Handling user split: \(userIdString) => ₹\(amount)")

                    guard let userId = Int(userIdString) else {
                        print("⚠️ Invalid user ID format: \(userIdString)")
                        continue
                    }

                    do {
                        print("🔍 Checking for existing user_groupSplitexpense entry...")
                        let existingResponse: PostgrestResponse = try await client
                            .from("user_groupSplitexpense")
                            .select()
                            .eq("group_id", value: expense.groupId)
                            .eq("user_id", value: userId)
                            .eq("expense_id", value: expenseId)
                            .execute()

                        var existingData: [String: Any]? = nil
                        if let dataArray = existingResponse.data as? [[String: Any]], !dataArray.isEmpty {
                            existingData = dataArray.first
                        } else if let singleData = existingResponse.data as? [String: Any] {
                            existingData = singleData
                        }

                        if let existingData = existingData {
                            print("🔁 Record exists. Updating amount...")

                            if let existingAmount = existingData["amount"] as? Double,
                               let recordId = existingData["id"] as? Int {
                                let updatedAmount = existingAmount + amount

                                try await client
                                    .from("user_groupSplitexpense")
                                    .update([
                                        "amount": AnyEncodable(updatedAmount)
                                    ])
                                    .eq("id", value: recordId)
                                    .execute()

                                print("✅ Record updated for user \(userId). Amount: \(updatedAmount)")
                            } else {
                                print("⚠️ Missing fields in existing record.")
                            }
                        } else {
                            print("➕ No existing record. Inserting new one...")
                            let userExpensePayload: [String: AnyEncodable] = [
                                "expense_id": AnyEncodable(expenseId),
                                "user_id": AnyEncodable(userId),
                                "amount": AnyEncodable(amount),
                                "group_id": AnyEncodable(expense.groupId)
                            ]

                            try await client
                                .from("user_groupSplitexpense")
                                .insert([userExpensePayload])
                                .execute()
                            print("✅ New record inserted for user \(userId).")
                        }

                    } catch {
                        print("⚠️ Error during check/insert for user \(userId): \(error.localizedDescription)")
                        continue
                    }
                }

                DispatchQueue.main.async {
                    print("📦 Finalizing: Expense added locally.")
//                    self.addExpenseSplit(expense: expense)
                    print("✅ Upload completed successfully.")
                    completion(.success(()))
                }

            } catch {
                print("❌ Main error during upload: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

}
