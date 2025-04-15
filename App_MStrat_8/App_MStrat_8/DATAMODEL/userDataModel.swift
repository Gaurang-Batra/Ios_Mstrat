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



class UserDataModel {
    private var users: [User] = []
    static let shared = UserDataModel()
    
    private init() {}
    
    private let client = SupabaseAPIClient.shared.supabaseClient
    
    func getAllUsers() -> [User] {
        return self.users
    }
    
    func getAllUsersfromsupabase(completion: @escaping ([User]?, Error?) -> Void) {
        Task {
            do {
                let users: [User] = try await SupabaseAPIClient.shared.supabaseClient
                    .database
                    .from("users")
                    .select()
                    .execute()
                    .value // 👈 this gives you the decoded array directly

                completion(users, nil)
            } catch {
                completion(nil, error)
            }
        }
    }

    
    func getUser(by id: Int) -> User? {
        return users.first { $0.id == id }
    }
    func getUser(fromSupabaseBy id: Int) async -> User? {
        let client = SupabaseAPIClient.shared.supabaseClient

        do {
            let response: PostgrestResponse<User> = try await client
                .database
                .from("users")
                .select()
                .eq("id", value: id)
                .single()
                .execute()

            let user = response.value
            print("✅ Fetched user: \(user.fullname)")
            return user

        } catch {
            print("❌ Error fetching user from Supabase: \(error)")
            return nil
        }
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
//    \
    func updateUser(userId: Int, name: String, phone: String, completion: @escaping (Result<Void, Error>) -> Void) {
           let payload: [String: AnyEncodable] = [
               "fullname": AnyEncodable(name),
               "phone": AnyEncodable(phone)  // Assuming you have a "phone" field in your Supabase table
           ]
           
           Task {
               do {
                   try await client
                       .from("users")  // Assuming your users table is called "users"
                       .update(payload)
                       .eq("id", value: userId)  // Filter by userId
                       .execute()
                   
                   DispatchQueue.main.async {
                       completion(.success(()))
                   }
               } catch {
                   DispatchQueue.main.async {
                       completion(.failure(error))
                   }
               }
           }
       }
    
    func updatePassword(userId: Int, newPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let payload: [String: AnyEncodable] = [
            "password": AnyEncodable(newPassword)  // Assuming you have a "password" field in your Supabase table
        ]
        
        Task {
            do {
                try await client
                    .from("users")  // Assuming your users table is called "users"
                    .update(payload)
                    .eq("id", value: userId)  // Filter by userId
                    .execute()
                
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func updateUser(_ user: User) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user  
        }
    }



    func getUserBadges(for userId: Int) -> [String] {
        return users.first { $0.id == userId }?.badges ?? []
    }
}
