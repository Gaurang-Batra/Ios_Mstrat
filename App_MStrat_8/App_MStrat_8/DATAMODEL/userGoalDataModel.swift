import Foundation
import Supabase

struct Goal: Codable {
    var id: Int?
    var title: String
    var amount: Int
    var deadline: Date
    var savings: Int?
    var user_id: Int?

    init(id: Int? = nil, title: String, amount: Int, deadline: Date, savings: Int? = nil, user_id: Int? = nil) {
        self.id = id
        self.title = title
        self.amount = amount
        self.deadline = deadline
        self.savings = savings
        self.user_id = user_id
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case amount
        case deadline
        case savings
        case user_id
    }
}

class GoalDataModel {
    private var goals: [Goal] = []
    static let shared = GoalDataModel()
    private let client = SupabaseAPIClient.shared.supabaseClient

    private init() {}

    func getAllGoals() -> [Goal] {
        return goals
    }

    func addGoal(_ goal: Goal) {
        goals.append(goal)
        Task {
            await saveToSupabase(userId: goal.user_id)
        }
    }

    func getGoal(by title: String) -> Goal? {
        return goals.first { $0.title == title }
    }

    func addSavings(toGoalWithTitle title: String, amount: Int, userId: Int?) async {
        guard let index = goals.firstIndex(where: { $0.title == title }) else {
            print("❌ Goal with title '\(title)' not found")
            return
        }

        // Update local savings
        let currentSavings = (goals[index].savings ?? 0) + amount
        goals[index].savings = currentSavings

        // Check if savings meet or exceed the goal amount
        if currentSavings >= goals[index].amount {
            print("🎉 Goal '\(title)' achieved or exceeded! Deleting goal.")
            await deleteGoal(goal: goals[index], userId: userId)
            goals.remove(at: index)
        } else {
            print("💰 Added \(amount) to '\(title)'. Current savings: \(currentSavings) out of \(goals[index].amount)")
            await updateSavingsInSupabase(goal: goals[index], newSavings: currentSavings)
        }
    }

    private func updateSavingsInSupabase(goal: Goal, newSavings: Int) async {
        guard let goalId = goal.id else {
            print("❌ Goal ID is nil, cannot update savings")
            return
        }
        do {
            let response = try await client
                .from("goals")
                .update(["savings": newSavings])
                .eq("id", value: goalId)
                .execute()
            print("✅ Updated savings for goal ID \(goalId) to \(newSavings) in Supabase: \(response)")
        } catch {
            print("❌ Error updating savings for goal ID \(goalId): \(error.localizedDescription)")
        }
    }

    private func deleteGoal(goal: Goal, userId: Int?) async {
        guard let goalId = goal.id else {
            print("❌ Goal ID is nil, cannot delete goal")
            return
        }
        do {
            let response = try await client
                .from("goals")
                .delete()
                .eq("id", value: goalId)
                .eq("user_id", value: userId ?? 0)
                .execute()
            print("✅ Deleted goal ID \(goalId) from Supabase: \(response)")
        } catch {
            print("❌ Error deleting goal ID \(goalId): \(error.localizedDescription)")
        }
    }

    func saveToSupabase(userId: Int?) async {
        guard let userId = userId else {
            print("❌ No userId provided, cannot save goals")
            return
        }
        do {
            // Only insert goals without an ID (new goals)
            let goalsWithUserId = goals.filter { $0.id == nil }.map { goal in
                Goal(
                    id: goal.id,
                    title: goal.title,
                    amount: goal.amount,
                    deadline: goal.deadline,
                    savings: goal.savings,
                    user_id: userId
                )
            }
            if !goalsWithUserId.isEmpty {
                let response = try await client
                    .from("goals")
                    .insert(goalsWithUserId)
                    .execute()
                print("✅ Goals saved to Supabase: \(response)")
            }

            // Fetch all goals to sync IDs
            let fetchedGoals: [Goal] = try await client
                .from("goals")
                .select("*")
                .eq("user_id", value: userId)
                .order("deadline", ascending: true)
                .execute()
                .value
            self.goals = fetchedGoals
            print("✅ Refreshed local goals with IDs from Supabase: \(fetchedGoals.count) goals")
        } catch {
            print("❌ Error saving goals to Supabase: \(error.localizedDescription)")
        }
    }

    func fetchGoalsFromSupabase(userId: Int?) async throws -> [Goal] {
        guard let userId = userId else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No userId provided"])
        }
        do {
            let fetchedGoals: [Goal] = try await client
                .from("goals")
                .select("*")
                .eq("user_id", value: userId)
                .order("deadline", ascending: true)
                .execute()
                .value
            self.goals = fetchedGoals
            print("✅ Fetched \(fetchedGoals.count) goals for userId: \(userId)")
            return fetchedGoals
        } catch {
            print("❌ Error fetching goals from Supabase: \(error.localizedDescription)")
            throw error
        }
    }
}
