import Foundation
import UIKit
import Supabase
import PostgREST

extension Notification.Name {
    static let newExpenseAddedInGroup = Notification.Name("newExpenseAddedInGroup")
}

struct ExpenseSplitForm: Codable {
    var id: Int?
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
        case id
        case name
        case category
        case totalAmount = "total_amount"
        case paidBy = "paid_by"
        case groupId = "group_id"
        case splitOption = "split_option"
        case splitAmounts = "split_amounts"
        case payee
        case date
        case ismine
        case image
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(String.self, forKey: .category)
        totalAmount = try container.decode(Double.self, forKey: .totalAmount)
        paidBy = try container.decode(String.self, forKey: .paidBy)
        groupId = try container.decodeIfPresent(Int.self, forKey: .groupId)
        splitOption = try container.decodeIfPresent(SplitOption.self, forKey: .splitOption)
        splitAmounts = try container.decode([String: Double].self, forKey: .splitAmounts)
        payee = try container.decode([Int].self, forKey: .payee)
        ismine = try container.decode(Bool.self, forKey: .ismine)
        
        let dateString = try container.decode(String.self, forKey: .date)
        if let date = ISO8601DateFormatter().date(from: dateString) {
            self.date = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Invalid date format")
        }
        
        if let base64Image = try? container.decodeIfPresent(String.self, forKey: .image),
           let imageData = Data(base64Encoded: base64Image) {
            image = UIImage(data: imageData)
        } else {
            image = nil
        }
    }

    init(id: Int? = nil, name: String, category: String, totalAmount: Double, paidBy: String, groupId: Int?, image: UIImage? = nil, splitOption: SplitOption?, splitAmounts: [String: Double], payee: [Int], date: Date, ismine: Bool) {
        self.id = id
        self.name = name
        self.category = category
        self.totalAmount = totalAmount
        self.paidBy = paidBy
        self.groupId = groupId
        self.image = image
        self.splitOption = splitOption
        self.splitAmounts = splitAmounts
        self.payee = payee
        self.date = date
        self.ismine = ismine
    }
}

enum SplitOption: String, Codable {
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
        // Updated sample data to use user IDs as keys
        let firstExpenseSplit = ExpenseSplitForm(
            id: 1,
            name: "Dinner with Friends",
            category: "Food",
            totalAmount: 100.0,
            paidBy: "Ajay (You)",
            groupId: 1,
            image: UIImage(named: "icons8-holiday-50"),
            splitOption: .equally,
            splitAmounts: ["1": 50.0, "2": 50.0],
            payee: [1, 2],
            date: Date(),
            ismine: true
        )

        let secondExpenseSplit = ExpenseSplitForm(
            id: 2,
            name: "Trip Expense",
            category: "Travel",
            totalAmount: 500.0,
            paidBy: "Alice Johnson",
            groupId: 2,
            image: UIImage(named: "icons8-holiday-50"),
            splitOption: .unequally,
            splitAmounts: ["1": 200.0, "2": 300.0],
            payee: [1, 2],
            date: Date(),
            ismine: false
        )

        expenseSplits.append(firstExpenseSplit)
        expenseSplits.append(secondExpenseSplit)
    }

    func getAllExpenseSplits() -> [ExpenseSplitForm] {
        return expenseSplits
    }

    func getExpenseSplits(forGroup groupId: Int) async -> [ExpenseSplitForm] {
        do {
            let expenses = try await fetchExpenseSplits(forGroup: groupId)
            return expenses
        } catch {
            print("❌ Failed to fetch expenses: \(error.localizedDescription)")
            return expenseSplits.filter { $0.groupId == groupId } // Fallback to local cache
        }
    }

    // Keep the completion-based version for backward compatibility
    func getExpenseSplits(forGroup groupId: Int, completion: @escaping ([ExpenseSplitForm]) -> Void) {
        Task {
            let expenses = await getExpenseSplits(forGroup: groupId)
            DispatchQueue.main.async {
                completion(expenses)
            }
        }
    }

    func fetchExpenseSplits(forGroup groupId: Int) async throws -> [ExpenseSplitForm] {
            let client = SupabaseAPIClient.shared.supabaseClient
            print("📥 Fetching expenses for group ID: \(groupId)...")

            let response: PostgrestResponse = try await client
                .from("splitexpenses")
                .select()
                .eq("group_id", value: groupId)
                .order("id", ascending: false)
                .execute()

            print("✅ Response received from splitexpenses table.")
            var dataArray: [[String: Any]] = []
            if let array = response.data as? [[String: Any]] {
                dataArray = array
            } else if let singleDict = response.data as? [String: Any] {
                dataArray = [singleDict]
            } else if let rawData = response.data as? Data {
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: rawData, options: [])
                    if let array = jsonObject as? [[String: Any]] {
                        dataArray = array
                    } else if let singleDict = jsonObject as? [String: Any] {
                        dataArray = [singleDict]
                    } else {
                        throw NSError(domain: "SupabaseError", code: 2, userInfo: [NSLocalizedDescriptionKey: "❌ Response data is not a valid JSON array or object"])
                    }
                } catch {
                    throw NSError(domain: "SupabaseError", code: 2, userInfo: [NSLocalizedDescriptionKey: "❌ Failed to deserialize response data: \(error.localizedDescription)"])
                }
            } else {
                if (response.data as? [Any])?.isEmpty ?? true {
                    print("ℹ️ No expenses found for group ID: \(groupId). Returning empty array.")
                    expenseSplits = []
                    return []
                } else {
                    throw NSError(domain: "SupabaseError", code: 2, userInfo: [NSLocalizedDescriptionKey: "❌ Response data is in an unexpected format: \(type(of: response.data))"])
                }
            }

            var fetchedExpenses: [ExpenseSplitForm] = []

            for json in dataArray {
                do {
                    guard let id = json["id"] as? Int,
                          let name = json["name"] as? String,
                          let category = json["category"] as? String,
                          let totalAmountRaw = json["total_amount"],
                          let paidBy = json["paid_by"] as? String,
                          let payee = json["payee"] as? [Int],
                          let dateString = json["date"] as? String,
                          let ismine = json["ismine"] as? Bool,
                          let splitAmountsJson = json["split_amounts"] as? [String: Any] else {
                        print("⚠️ Missing or invalid required fields in expense: \(json)")
                        continue
                    }

                    print("📋 Parsing expense: \(name), Payee IDs: \(payee), Paid by: \(paidBy)")

                    let totalAmount: Double
                    if let doubleValue = totalAmountRaw as? Double {
                        totalAmount = doubleValue
                    } else if let intValue = totalAmountRaw as? Int {
                        totalAmount = Double(intValue)
                    } else if let numberValue = totalAmountRaw as? NSNumber {
                        totalAmount = Double(truncating: numberValue)
                    } else if let stringValue = totalAmountRaw as? String, let doubleFromString = Double(stringValue) {
                        totalAmount = doubleFromString
                    } else {
                        print("⚠️ Invalid total_amount format: \(totalAmountRaw)")
                        continue
                    }

                    let dateFormatter = ISO8601DateFormatter()
                    guard let date = dateFormatter.date(from: dateString) else {
                        print("⚠️ Invalid date format: \(dateString)")
                        continue
                    }

                    var splitOption: SplitOption?
                    if let splitOptionString = json["split_option"] as? String {
                        splitOption = SplitOption(rawValue: splitOptionString)
                    }

                    var splitAmounts: [String: Double] = [:]
                    for (key, value) in splitAmountsJson {
                        if let amount = value as? Double {
                            splitAmounts[key] = amount
                        } else if let amountInt = value as? Int {
                            splitAmounts[key] = Double(amountInt)
                        } else if let amountString = value as? String, let amountDouble = Double(amountString) {
                            splitAmounts[key] = amountDouble
                        } else {
                            print("⚠️ Invalid split_amounts value for key \(key): \(value)")
                            continue
                        }
                    }

                    // Validate payee IDs
                    if payee.isEmpty {
                        print("⚠️ Empty payee array for expense: \(name). Checking split_amounts for user IDs.")
                        let possiblePayeeIds = splitAmounts.keys.compactMap { Int($0) }
                        if !possiblePayeeIds.isEmpty {
                            print("🔧 Inferred payee IDs from split_amounts: \(possiblePayeeIds)")
                        } else {
                            print("❌ No valid payee IDs found in split_amounts for expense: \(name)")
                        }
                    } else {
                        // Verify payee IDs exist in users table
                        for payeeId in payee {
                            if let user = await UserDataModel.shared.getUser(fromSupabaseBy: payeeId) {
                                print("✅ Payee ID \(payeeId) exists: \(user.fullname)")
                            } else {
                                print("❌ Payee ID \(payeeId) does not exist in users table for expense: \(name)")
                            }
                        }
                    }

                    var image: UIImage?
                    if let base64Image = json["image"] as? String,
                       let imageData = Data(base64Encoded: base64Image) {
                        image = UIImage(data: imageData)
                    }

                    let expense = ExpenseSplitForm(
                        id: id,
                        name: name,
                        category: category,
                        totalAmount: totalAmount,
                        paidBy: paidBy,
                        groupId: groupId,
                        image: image,
                        splitOption: splitOption,
                        splitAmounts: splitAmounts,
                        payee: payee,
                        date: date,
                        ismine: ismine
                    )

                    fetchedExpenses.append(expense)
                    print("✅ Parsed expense: \(name) (ID: \(id))")
                } catch {
                    print("⚠️ Error parsing expense: \(error.localizedDescription)")
                    continue
                }
            }

            expenseSplits = fetchedExpenses
            print("✅ Fetched \(fetchedExpenses.count) expenses for group \(groupId).")
            return fetchedExpenses
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
                    var updatedExpense = expense
                    updatedExpense.id = expenseId
                    self.addExpenseSplit(expense: updatedExpense)
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
