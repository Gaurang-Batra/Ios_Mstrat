import Foundation
import Supabase


struct Goal: Codable {
    var title: String
    var amount: Int
    var deadline: Date
    var savings: Int?
    var user_id: Int? // ✅ Add this

    init(title: String, amount: Int, deadline: Date, savings: Int? = nil, user_id: Int? = nil) {
        self.title = title
        self.amount = amount
        self.deadline = deadline
        self.savings = savings
        self.user_id = user_id
    }
}


class GoalDataModel {
    private var goals: [Goal] = []
    static let shared = GoalDataModel()

    private init() {}

    func getAllGoals() -> [Goal] {
        return goals
    }

    func addGoal(_ goal: Goal) {
        goals.append(goal)
    }

    func getGoal(by title: String) -> Goal? {
        return goals.first { $0.title == title }
    }

    func addSavings(toGoalWithTitle title: String, amount: Int) {
        guard let index = goals.firstIndex(where: { $0.title == title }) else { return }
        goals[index].savings = (goals[index].savings ?? 0) + amount
        if goals[index].savings! > goals[index].amount {
            print("Congratulations! You've exceeded your goal savings for \(goals[index].title).")
        } else {
            print("Added \(amount) to \(goals[index].title). Current savings: \(goals[index].savings!) out of \(goals[index].amount).")
        }
    }

    func saveToSupabase(userId: Int?) async {
        do {
            let client = SupabaseAPIClient.shared.supabaseClient
            let goalsWithUserId = goals.map { goal in
                Goal(title: goal.title, amount: goal.amount, deadline: goal.deadline, savings: goal.savings, user_id: userId)
            }
            let response = try await client
                .from("goals")
                .insert(goalsWithUserId)
                .execute()

            print("✅ Goals saved to Supabase: \(response)")
        } catch {
            print("❌ Error saving goals: \(error.localizedDescription)")
        }
    }
}
