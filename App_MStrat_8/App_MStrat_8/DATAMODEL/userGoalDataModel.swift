import Foundation

struct Goal:Codable {
    var title: String
    var amount: Int
    var deadline: Date
    var savings: Int? // Track savings progress
    
    init(title: String, amount: Int, deadline: Date, savings: Int? = nil) {
        self.title = title
        self.amount = amount
        self.deadline = deadline
        self.savings = savings
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
}
