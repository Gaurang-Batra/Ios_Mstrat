//
//  userDataModel.swift
//  App_MStrat_8
//
//  Created by student-2 on 26/12/24.
//

import Foundation
import Supabase
//user-----------
struct User:Codable {
    let id: Int?
    var email: String
    var fullname: String
    var password: String
    var is_verified: Bool?
    var badges: [String]?
    var currentGoal: Goal?
    var groups : [Int ]?
    var expenses: [Expense]?
    var allowance : [Allowance]?
}



let firstUser = User(
    id: 1,
    email: "ankush@gmail.com",
    fullname: "John Doe",
    password: "9",
    is_verified: true,
    badges: [],
    currentGoal: nil,
    groups: [1,2],
    expenses: []
)
let secondUser = User(
    id: 2,
    email: "janesmith@example.com",
    fullname: "Jane Smith",
    password: "password456",
    is_verified: false,
    badges: [],
    currentGoal: nil,
    expenses: []
)
let thirdUser = User(
    id: 0,
    email: "alicej@example.com",
    fullname: "Alice Johnson",
    password: "password789",
    is_verified: true,
    badges: [],
    currentGoal: nil,
    expenses: []
)
//let zerothUser = User(
//    id: 0,
//    email: "Ajay@example.com",
//    fullname: "Ajay (You)",
//    password: "password138",
//    isVerified: true,
//    badges: [],
//    currentGoal: nil,
//    expenses: []
//)

class UserDataModel {
    private var users: [User] = []
    static let shared = UserDataModel()
    
    private init() {
        users.append(firstUser)
        users.append(secondUser)
        users.append(thirdUser)

    }
    
    func getAllUsers() -> [User] {
        return self.users
    }
    
    func getUser(by id: Int) -> User? {
        return users.first { $0.id == id }
    }
    
    
    func assignGoal(to userId: Int, goal: Goal) {
        guard let index = users.firstIndex(where: { $0.id == userId }) else { return }
        users[index].currentGoal = goal
        
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
        
        //        users[index].badges.append(badge)
    }
    
    func createUser(email: String, fullname: String, password: String) -> User {
        let newId = (users.map { $0.id ?? 0 }.max() ?? 0) + 1

        let newUser = User(
            id: newId,
            email: email,
            fullname: fullname,
            password: password,
            is_verified: false,
            badges: [],
            currentGoal: nil,
            expenses: []
        )

        users.append(newUser)

  
        Task {
            do {
                let client = SupabaseAPIClient.shared.supabaseClient

                let insertData = User(
                    id: nil,
                    email: email,
                    fullname: fullname,
                    password: password,
                    is_verified: false
                )

                try await client
                    .from("users")
                    .insert([insertData])
                    .execute()

                print(" Inserted user into Supabase without ID.")
            } catch {
                print(" Supabase insert failed: \(error)")
            }
        }


        return newUser
    }





//
//    func createUser(email: String, fullname: String, password: String) -> User {
//        let newId = (users.map { $0.id }.max() ?? 0) + 1
//        let newUser = User(
//            id: newId,
//            email: email,
//            fullname: fullname,
//            password: password,
//            isVerified: false,
//            badges: [],
//            currentGoal: nil,
//            expenses: []
//        )¯
//        users.append(newUser)
//        return newUser
//    }
//    
    func updateUser(_ user: User) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user  
        }
    }



    func getUserBadges(for userId: Int) -> [String] {
        return users.first { $0.id == userId }?.badges ?? []
    }
}
