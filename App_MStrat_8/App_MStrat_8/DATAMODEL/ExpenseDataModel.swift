
//
//  ExpenseDataModel.swift
//  App_MStrat_8
//
//  Created by student-2 on 26/12/24.
//
import Foundation
import UIKit
import Supabase

enum ExpenseCategory: String, CaseIterable, Codable {
    case food = "Food"
    case grocery = "Grocery"
    case fuel = "Fuel"
    case bills = "Bills"
    case travel = "Travel"
    case other = "Other"
    
    var associatedImage: UIImage {
        switch self {
        case .food:
            return UIImage(named: "icons8-kawaii-pizza-50") ?? UIImage()
        case .grocery:
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
}

struct Expense: Codable {
    let id: Int?
    var item_name: String
    var amount: Int
    var date: Date
    var category: ExpenseCategory
    var duration: Date?
    var is_recurring: Bool
    var user_id: Int?

    var image: UIImage {
        return category.associatedImage
    }

    enum CodingKeys: String, CodingKey {
        case id
        case item_name
        case amount
        case date
        case category
        case duration
        case is_recurring
        case user_id
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(item_name, forKey: .item_name)
        try container.encode(amount, forKey: .amount)
        try container.encode(date, forKey: .date)
        try container.encode(category, forKey: .category)
        try container.encodeIfPresent(duration, forKey: .duration)
        try container.encode(is_recurring, forKey: .is_recurring)
        try container.encodeIfPresent(user_id, forKey: .user_id)
    }

    // ✅ Add custom decoding for Codable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try? container.decode(Int.self, forKey: .id)
        item_name = try container.decode(String.self, forKey: .item_name)
        amount = try container.decode(Int.self, forKey: .amount)

        let dateString = try container.decode(String.self, forKey: .date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        guard let parsedDate = dateFormatter.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(forKey: .date,
                                                   in: container,
                                                   debugDescription: "Invalid date format: \(dateString)")
        }
        date = parsedDate

        category = try container.decode(ExpenseCategory.self, forKey: .category)

        if let durationString = try? container.decode(String.self, forKey: .duration) {
            duration = dateFormatter.date(from: durationString)
        } else {
            duration = nil
        }

        is_recurring = try container.decode(Bool.self, forKey: .is_recurring)
        user_id = try container.decodeIfPresent(Int.self, forKey: .user_id)
    }


    init(
        id: Int?,
        item_name: String,
        amount: Int,
        date: Date,
        category: ExpenseCategory,
        duration: Date?,
        is_recurring: Bool,
        user_id: Int?
    ) {
        self.id = id
        self.item_name = item_name
        self.amount = amount
        self.date = date
        self.category = category
        self.duration = duration
        self.is_recurring = is_recurring
        self.user_id = user_id
    }
}


class ExpenseDataModel {
    private var expenses: [Expense] = []
    static let shared = ExpenseDataModel()

    private init() {
        preloadExpenses()
    }

    func getAllExpenses() -> [Expense] {
        return expenses
    }
    
    func fetchExpensesFromSupabase(for userId: Int) async {
            let client = SupabaseAPIClient.shared.supabaseClient

            do {
                let response: PostgrestResponse<[Expense]> = try await client
                    .database
                    .from("expenses")
                    .select()
                    .eq("user_id", value: userId)
                    .order("id", ascending: false) // Latest first
                    .execute()

                let fetchedExpenses = response.value ?? []
                self.expenses = fetchedExpenses

                print("✅ Fetched \(fetchedExpenses.count) expenses from Supabase for user \(userId)")
            } catch {
                print("❌ Error fetching expenses from Supabase: \(error)")
            }
        }
    
    func fetchExpensesFromSupabase(for userId: Int, startDate: Date?, endDate: Date?, completion: @escaping ([Expense]) -> Void) {
        let client = SupabaseAPIClient.shared.supabaseClient

        Task {
            do {
                var query = client.database.from("expenses").select().eq("user_id", value: userId)

                if let startDate = startDate {
                    query = query.gte("date", value: startDate)  // Filter by start date
                }
                
                if let endDate = endDate {
                    query = query.lte("date", value: endDate)  // Filter by end date
                }

                let response: PostgrestResponse<[Expense]> = try await query.order("id", ascending: false).execute()

                let fetchedExpenses = response.value ?? []
                completion(fetchedExpenses)

            } catch {
                print("❌ Error fetching expenses from Supabase: \(error)")
                completion([])
            }
        }
    }

    
    func fetchExpensesForUser(userId: Int, completion: @escaping ([Expense]) -> Void) {
        let client = SupabaseAPIClient.shared.supabaseClient

        Task {
            do {
                let response: PostgrestResponse<[Expense]> = try await client
                    .database
                    .from("expenses")
                    .select()
                    .eq("user_id", value: userId)
                    .execute()
                
                let fetchedExpenses = response.value ?? []
                completion(fetchedExpenses)
            } catch {
                print("❌ Error fetching expenses: \(error)")
                completion([])
            }
        }
    }


    
    private func getDate(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string) ?? Date()
    }
    
    private func preloadExpenses() {
        let expenseList : [Expense] = [

       ]

        self.expenses = expenseList
    }


    func addExpense(itemName: String, amount: Int, category: ExpenseCategory, date: Date, duration: Date?, isRecurring: Bool, userId: Int? = nil) -> Expense {
        let newId = (expenses.last?.id ?? 0) + 1
        let newExpense = Expense(
            id: newId,
            item_name: itemName,
            amount: amount,
            date: date,
            category: category,
            duration: duration,
            is_recurring: isRecurring,
            user_id: userId
        )
        expenses.insert(newExpense, at: 0)
        print("New expense added: \(newExpense.item_name) with ID \(String(describing: newExpense.id)) on \(newExpense.date). Recurring on: \(newExpense.duration != nil ? "\(newExpense.duration!)" : "N/A"). Is recurring: \(newExpense.is_recurring)")
        return newExpense
    }

    func checkRecurringExpenses() {
        let currentDate = Date()
        let calendar = Calendar.current

        for expense in expenses where expense.is_recurring {
            if let duration = expense.duration,
               calendar.isDate(currentDate, inSameDayAs: duration) {
                promptUserForRecurringExpense(expense)
            }
        }
    }

    private func promptUserForRecurringExpense(_ expense: Expense) {
        print("Do you want to add \(expense.item_name) again?")
    }

    func groupExpensesByDate() -> [String: [Expense]] {
        var groupedByDate: [String: [Expense]] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for expense in expenses {
            let dateKey = dateFormatter.string(from: expense.date)
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

    
    func saveExpenseToSupabase(_ expense: Expense) async {
        do {
            let client = SupabaseAPIClient.shared.supabaseClient

            // Create a copy without the ID
            var expenseData = expense
            expenseData = Expense(
                id: nil, // remove id from insertion
                item_name: expense.item_name,
                amount: expense.amount,
                date: expense.date,
                category: expense.category,
                duration: expense.duration,
                is_recurring: expense.is_recurring,
                user_id: expense.user_id
            )

            let response = try await client
                .from("expenses")
                .insert(expenseData)
                .execute()

            print("✅ Expense saved to Supabase (without id): \(response)")
        } catch {
            print("❌ Failed to save expense to Supabase: \(error.localizedDescription)")
        }
    }


}




////
////  ExpenseDataModel.swift
////  App_MStrat_8
////
////  Created by student-2 on 26/12/24.
////
//import Foundation
//import UIKit
//
//enum ExpenseCategory: String, CaseIterable,Codable {
//    case food = "Food"
//    case grocery = "Grocery"
//    case fuel = "Fuel"
//    case bills = "Bills"
//    case travel = "Travel"
//    case other = "Other"
//
//
//    var associatedImage: UIImage {
//        switch self {
//        case .food:
////            print("inside food")
//            return UIImage(named: "icons8-kawaii-pizza-50") ?? UIImage()
//        case .grocery:
////            print("inside grocery")
//            return UIImage(named: "icons8-vegetarian-food-50") ?? UIImage()
//        case .fuel:
//            return UIImage(named: "icons8-fuel-50") ?? UIImage()
//        case .bills:
//            return UIImage(named: "icons8-cheque-50") ?? UIImage()
//        case .travel:
//            return UIImage(named: "icons8-holiday-50") ?? UIImage()
//        case .other:
//            return UIImage(named: "icons8-more-50-2") ?? UIImage()
//        }
//    }
//
////    var associatedImage: UIImage {
////            switch self {
////            case .food:
////                let image = UIImage(named: "icons8-kawaii-pizza-50")
////                print("Food image loaded: \(image != nil)")
////                return image ?? UIImage()
////            case .grocery:
////                let image = UIImage(named: "icons8-vegetarian-food-50")
////                print("Grocery image loaded: \(image != nil)")
////                return image ?? UIImage()
////            case .fuel:
////                let image = UIImage(named: "icons8-fuel-50")
////                print("Fuel image loaded: \(image != nil)")
////                return image ?? UIImage()
////            case .bills:
////                let image = UIImage(named: "icons8-cheque-50")
////                print("Bills image loaded: \(image != nil)")
////                return image ?? UIImage()
////            case .travel:
////                let image = UIImage(named: "icons8-holiday-50")
////                print("Travel image loaded: \(image != nil)")
////                return image ?? UIImage()
////            case .other:
////                let image = UIImage(named: "icons8-more-50-2")
////                print("Other image loaded: \(image != nil)")
////                return image ?? UIImage()
////            }
////        }
//}
//
//struct Expense {
//    let id: Int
//    var itemName: String
//    var amount: Int
//    var image: UIImage
//    var date: Date
//    var category: ExpenseCategory
//    var duration: Date?
//    var isRecurring: Bool
//}
//
//
////let firstExpense = Expense(
////    id: 1,
////    itemName: "food wash",
////    amount: 1200,
////    image: ExpenseCategory.food.associatedImage,
////    category: .food,
////    duration: DateFormatter().date(from: "2024-01-15"),
////    isRecurring: false
////)
////
////let secondExpense = Expense(
////    id: 2,
////    itemName: "home grocery",
////    amount: 3000,
////    image: ExpenseCategory.grocery.associatedImage,
////    category: .grocery,
////    duration: DateFormatter().date(from: "2024-06-01"),
////    isRecurring: true
////)
////
////let thirdExpense = Expense(
////    id: 3,
////    itemName: "Banana",
////    amount: 5000,
////    image: ExpenseCategory.grocery.associatedImage,
////    category: .grocery,
////    duration: DateFormatter().date(from: "2025-12-31"),
////    isRecurring: true
////)
////
////let fourthExpense = Expense(
////    id: 4,
////    itemName: "Pay food Insurance",
////    amount: 1500,
////    image: ExpenseCategory.food.associatedImage,
////    category: .food,
////    duration: DateFormatter().date(from: "2020-01-15"),
////    isRecurring: false
////)
////
////let fifthExpense = Expense(
////    id: 5,
////    itemName: "Monthly grocery",
////    amount: 3000,
////    image: ExpenseCategory.grocery.associatedImage,
////    category: .grocery,
////    duration: DateFormatter().date(from: "2025-06-01"),
////    isRecurring: true
////)
////
////let sixthExpense = Expense(
////    id: 6,
////    itemName: "Grocery Shopping",
////    amount: 200,
////    image: ExpenseCategory.grocery.associatedImage,
////    category: .grocery,
////    duration: DateFormatter().date(from: "2025-12-31"),
////    isRecurring: true
////)
//class ExpenseDataModel {
//    private var expenses: [Expense] = []
//    static let shared = ExpenseDataModel()
//
//    private init() {
//        preloadExpenses()
//    }
//
//    func getAllExpenses() -> [Expense] {
//        return expenses
//    }
//
//    private func getDate(_ string: String) -> Date {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        return formatter.date(from: string) ?? Date()
//    }
//
//    private func preloadExpenses() {
//        let expenseList = [
//            Expense(id: 1, itemName: "food wash", amount: 1200, image: ExpenseCategory.food.associatedImage, date: getDate("2025-04-05"), category: .food, duration: getDate(""), isRecurring: false),
//
//        ]
//
//        self.expenses = expenseList
//    }
//
//    func addExpense(itemName: String, amount: Int, image: UIImage, category: ExpenseCategory, date: Date, duration: Date?, isRecurring: Bool) {
//        let newId = (expenses.last?.id ?? 0) + 1
//        let newExpense = Expense(
//            id: newId,
//            itemName: itemName,
//            amount: amount,
//            image: image,
//            date: date,
//            category: category,
//            duration: duration,
//            isRecurring: isRecurring
//        )
//        expenses.insert(newExpense, at: 0)
//        print("New expense added: \(newExpense.itemName) with ID \(newExpense.id) on \(newExpense.date). Recurring on: \(newExpense.duration != nil ? "\(newExpense.duration!)" : "N/A"). Is recurring: \(newExpense.isRecurring)")
//    }
//
//
//    func checkRecurringExpenses() {
//        let currentDate = Date()
//        let calendar = Calendar.current
//
//        for expense in expenses where expense.isRecurring {
//            if let duration = expense.duration,
//               calendar.isDate(currentDate, inSameDayAs: duration) {
//                promptUserForRecurringExpense(expense)
//            }
//        }
//    }
//
//    private func promptUserForRecurringExpense(_ expense: Expense) {
//        print("Do you want to add \(expense.itemName) again?")
//    }
//
//    func groupExpensesByDate() -> [String: [Expense]] {
//        var groupedByDate: [String: [Expense]] = [:]
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//
//        for expense in expenses {
//            let dateKey = dateFormatter.string(from: expense.date) // Group by `date`, not `duration`
//            groupedByDate[dateKey, default: []].append(expense)
//        }
//
//        return groupedByDate
//    }
//
//    func groupedExpenses() -> [[Expense]] {
//        return groupExpensesByDate().values.map { $0 }
//    }
//
//    func sectionTitles() -> [String] {
//        return groupExpensesByDate().keys.sorted()
//    }
//
//    func updateExpense(_ updatedExpense: Expense) {
//        if let index = expenses.firstIndex(where: { $0.id == updatedExpense.id }) {
//            expenses[index] = updatedExpense
//        }
//    }
//
//}
