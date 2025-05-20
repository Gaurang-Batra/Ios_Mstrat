
//
//  splitPalGroupsDataModel.swift
//  App_MStrat_8
//
//  Created by student-2 on 26/12/24.
//
import Foundation
import UIKit
import Supabase

extension Notification.Name {
    static let newGroupAdded = Notification.Name("newGroupAdded")
}




struct Group: Codable {
    var id: Int?
    var group_name: String
    var category: UIImage?
    var members: [Int]
    var expenses: [ExpenseSplitForm]?
    var user_id: Int?

    enum CodingKeys: String, CodingKey {
        case id, group_name, category, members, expenses, user_id
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(group_name, forKey: .group_name)
        try container.encode(members, forKey: .members)
        try container.encodeIfPresent(expenses, forKey: .expenses)
        try container.encodeIfPresent(user_id, forKey: .user_id)
        if let imageData = category?.jpegData(compressionQuality: 0.8) {
            let base64String = imageData.base64EncodedString()
            try container.encode(base64String, forKey: .category)
        } else {
            try container.encodeNil(forKey: .category)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        group_name = try container.decode(String.self, forKey: .group_name)
        members = try container.decode([Int].self, forKey: .members)
        expenses = try container.decodeIfPresent([ExpenseSplitForm].self, forKey: .expenses)
        user_id = try container.decodeIfPresent(Int.self, forKey: .user_id)
        if let base64String = try? container.decode(String.self, forKey: .category),
           let imageData = Data(base64Encoded: base64String),
           let image = UIImage(data: imageData) {
            category = image
        } else {
            category = nil
        }
    }

    init(id: Int? = nil, group_name: String, category: UIImage?, members: [Int], expenses: [ExpenseSplitForm]? = nil, user_id: Int? = nil) {
        self.id = id
        self.group_name = group_name
        self.category = category
        self.members = members
        self.expenses = expenses
        self.user_id = user_id
    }
}

struct UserGroupLink: Codable {
    let user_id: Int
    let group_id: Int
}
struct UserGroupJoin: Decodable {
    let group_id: Int
    let groups: Group
}



struct Notifications: Codable {
    let id: Int?
    let recipient_id: Int
    let group_id: Int
    let group_name: String
    let inviter_id: Int
    let status: String
    let created_at: String?
}




class GroupDataModel {
    private var groups: [Group] = []
    private var users: [User] = []
    
    static let shared = GroupDataModel()

    private init() {
//        // Sample users
//        users.append(User(id: 1, email: "user1@example.com", fullname: "John", password: "password", is_verified: true, badges: [], currentGoal: nil, expenses: []))
//        users.append(User(id: 2, email: "user2@example.com", fullname: "Steve", password: "password", is_verified: true, badges: [], currentGoal: nil, expenses: []))
//        users.append(User(id: 3, email: "user3@example.com", fullname: "Jack", password: "password", is_verified: true, badges: [], currentGoal: nil, expenses: []))
//
//        // Sample groups with expenses
//        let expense1 = ExpenseSplitForm(
//            name: "Dinner with Friends",
//            category: "Food",
//            totalAmount: 100.0,
//            paidBy: "John Doe",
//            groupId: 1,
//            image: UIImage(named: "icons8-holiday-50")!,
//            splitOption: .equally,
//            splitAmounts: ["John Doe": 200.0, "Alice Johnson": 300.0],
//            payee: [1],
//            date: Date(),
//            ismine: true
//        )
//        
//        let expense2 = ExpenseSplitForm(
//            name: "Hotel Stay",
//            category: "Accommodation",
//            totalAmount: 300.0,
//            paidBy: "Steve",
//            groupId: 2,
//            image: UIImage(named: "icons8-holiday-50")!,
//            splitOption: .unequally,
//            splitAmounts: ["Jack": 100.0, "Steve": 200.0],
//            payee:[ 4],
//            date: Date(),
//            
//            ismine: false
//        )
//        
//        // Sample groups with expenses
//        groups.append(Group(
//            id: 1, // Added an ID for each group
//            groupName: "Tech ",
//            category: UIImage(named: "icons8-holiday-50"),
//            members: [1, 2],
//            expenses: [expense1]
//        ))
//        groups.append(Group(
//            id: 2, // Added an ID for each group
//            groupName: "Travel Enthusiasts",
//            category: UIImage(named: "icons8-holiday-50"),
//            members: [3],
//            expenses: [expense2]
//        ))
    }
   
    func createInvitationNotification(recipientId: Int, groupId: Int, groupName: String, inviterId: Int) async -> Bool {
        let client = SupabaseAPIClient.shared.supabaseClient
        let notification = Notifications(
            id: nil,
            recipient_id: recipientId,
            group_id: groupId,
            group_name: groupName,
            inviter_id: inviterId,
            status: "pending",
            created_at: nil
        )
        
        do {
            let response = try await client
                .database
                .from("notifications")
                .insert(notification)
                .execute()
            print("✅ Notification created for user \(recipientId) for group \(groupId)")
            return true
        } catch {
            print("❌ Error creating notification: \(error)")
            return false
        }
    }

    // Fetch notifications for a user
    func fetchNotificationsForUser(userId: Int) async -> [Notifications] {
        let client = SupabaseAPIClient.shared.supabaseClient
        
        do {
            let response: PostgrestResponse<[Notifications]> = try await client
                .database
                .from("notifications")
                .select()
                .eq("recipient_id", value: userId)
                .execute()
            
            return response.value ?? []
        } catch {
            print("❌ Error fetching notifications: \(error)")
            return []
        }
    }

    // Update notification status and add user to group if accepted
    func handleNotificationAcceptance(notificationId: Int, groupId: Int, userId: Int) async -> Bool {
        let client = SupabaseAPIClient.shared.supabaseClient
        
        do {
            // Update notification status to accepted
            let updateResponse = try await client
                .database
                .from("notifications")
                .update(["status": "accepted"])
                .eq("id", value: notificationId)
                .execute()
            
            // Add user to group in user_groups table
            let link = UserGroupLink(user_id: userId, group_id: groupId)
            let linkResponse = try await client
                .database
                .from("user_groups")
                .insert(link)
                .execute()
            
            print("✅ User \(userId) added to group \(groupId) after accepting notification")
            return true
        } catch {
            print("❌ Error handling notification acceptance: \(error)")
            return false
        }
    }
    func addGroupToUser(userId: Int, groupId: Int) {
        guard let index = users.firstIndex(where: { $0.id == userId }) else { return }
        
        if users[index].groups == nil {
            users[index].groups = []
        }

        if !users[index].groups!.contains(groupId) {
            users[index].groups!.append(groupId)
            print("Group \(groupId) added to user \(userId)")
        }
    }

    func addUsersToGroupInUserGroupsTable(groupId: Int64, userIds: [Int]) async {
        let client = SupabaseAPIClient.shared.supabaseClient
        for userId in userIds {
            let link = UserGroupLink(user_id: userId, group_id: Int(groupId))

            do {
                // Insert link only if both group and user exist in the respective tables
                let response = try await client
                    .database
                    .from("user_groups")
                    .insert(link)
                    .execute()

                print("✅ Linked user \(userId) to group \(groupId)")

            } catch {
                print("❌ Error linking user \(userId) to group \(groupId): \(error)")
            }
        }
    }








    func saveGroupToSupabase(group: Group, userId: Int) async -> Int64? {
        do {
            var groupToSave = group
            groupToSave.user_id = userId

            let client = SupabaseAPIClient.shared.supabaseClient

            let response = try await client
                .database
                .from("groups")
                .insert(groupToSave, returning: .representation)
                .select()
                .execute()
                
            // Check if the response contains data
            let responseData = response.data
            
            do {
                let insertedGroups = try JSONDecoder().decode([Group].self, from: responseData)
                if let savedGroup = insertedGroups.first, let groupId = savedGroup.id {
                    print("✅ Group saved with ID: \(groupId)")
                    return Int64(groupId)
                } else {
                    print("❌ No group data found in response")
                    return nil
                }
            } catch {
                print("❌ Error decoding response: \(error)")
                return nil
            }

        } catch {
            print("❌ Error saving group: \(error)")
            return nil
        }
    }





    
    func handleGroupCreationFlow(groupName: String, category: UIImage?, members: [Int], userId: Int) {
        Task {
            if let group = createGroup(groupName: groupName, category: category, members: members) {
                if let groupId = await saveGroupToSupabase(group: group, userId: userId) {
                    await addUsersToGroupInUserGroupsTable(groupId: groupId, userIds: members)
                } else {
                    print("❌ Failed to save group to Supabase")
                }
            }
        }
    }


    
    
    func createGroup(groupName: String, category: UIImage?, members: [Int]) -> Group? {
        if members.isEmpty {
            print("Cannot create a group without members.")
            return nil
        }

        let newGroup = Group(id: nil, group_name: groupName, category: category, members: members, expenses: nil)
        groups.insert(newGroup, at: 0)
                print("New group added: \(newGroup.group_name)")  // Debugging line
                NotificationCenter.default.post(name: .newGroupAdded, object: nil)
        return newGroup
    }
    
    func getAllGroupsFromSupabase(completion: @escaping ([Group]?, Error?) -> Void) {
        Task {
            let client = SupabaseAPIClient.shared.supabaseClient
            do {
                // Fetch groups from the "groups" table
                let response: PostgrestResponse = try await client
                    .database
                    .from("groups")
                    .select()
                    .execute()

                // Now directly decode response.data into [Group] without checking for nil
                do {
                    let groups = try JSONDecoder().decode([Group].self, from: response.data)
                    completion(groups, nil)
                } catch {
                    completion(nil, error)
                }
            } catch {
                completion(nil, error)
            }
        }
    }
    
    func fetchGroupsForUser(userId: Int) async -> [Group] {
        let client = SupabaseAPIClient.shared.supabaseClient

        do {
            let response: [UserGroupJoin] = try await client
                .from("user_groups")
                .select("group_id, groups!user_groups_group_id_fkey(id, group_name, category, members, user_id)")
                .eq("user_id", value: userId)
                .execute()
                .value

            let groups = response.map { $0.groups }
            print("✅ Fetched \(groups.count) groups for user \(userId): \(groups.map { $0.group_name })")
            return groups
        } catch {
            print("❌ Error fetching groups from Supabase: \(error)")
            return []
        }
    }
    // Fetch members of a group from user_groups table
    func fetchGroupMembers(groupId: Int, includeUserDetails: Bool = false, completion: @escaping (Result<[Any], Error>) -> Void) {
        Task {
            do {
                let client = SupabaseAPIClient.shared.supabaseClient
                let response: [UserGroupLink] = try await client
                    .database
                    .from("user_groups")
                    .select()
                    .eq("group_id", value: groupId)
                    .execute()
                    .value
                
                let memberIds = response.map { $0.user_id }
                print("✅ Fetched \(memberIds.count) members for group \(groupId): \(memberIds)")
                
                if includeUserDetails {
                    var users: [User] = []
                    for userId in memberIds {
                        if let user = await UserDataModel.shared.getUser(fromSupabaseBy: userId) {
                            users.append(user)
                        }
                    }
                    completion(.success(users))
                } else {
                    completion(.success(memberIds))
                }
            } catch {
                print("❌ Error fetching group members: \(error)")
                completion(.failure(error))
            }
        }
    }









       
    

    func getAllGroups() -> [Group] {
           return self.groups
       }

    // Fetch user data by userId
    func getUserById(_ userId: Int) -> User? {
        return users.first { $0.id == userId }
    }
    
    // Add a member to a group by groupName and userId
    func addMemberToGroup(groupId: Int, userId: Int) {
        guard let groupIndex = groups.firstIndex(where: { $0.id == groupId }) else {
            print("Group not found!")
            return
        }

        if !groups[groupIndex].members.contains(userId) {
            groups[groupIndex].members.append(userId)
            print("User \(userId) added to group \(groupId).")

            // ✅ Add the group to the user locally
            addGroupToUser(userId: userId, groupId: groupId)
            
            // ✅ Update Supabase
//            Task {
//                await addUsersToGroupInUserGroupsTable(userId: userId)
//            }
        } else {
            print("User \(userId) is already a member of the group.")
        }
    }



    // Function to automatically calculate split amounts for equally split expenses
    func calculateEqualSplit(for expense: ExpenseSplitForm, groupMembers: [String]) -> [String: Double] {
        guard expense.splitOption == .equally else {
            return [:]
        }

        let splitAmount = expense.totalAmount / Double(groupMembers.count)
        var splitAmounts: [String: Double] = [:]

        for member in groupMembers {
            splitAmounts[member] = splitAmount
        }

        return splitAmounts
    }

    // Add a new expense to a group and calculate the split amounts
    func addExpenseToGroup(groupId: Int, expense: ExpenseSplitForm) {
        guard var group = groups.first(where: { $0.id == groupId }) else {
            print("Group not found!")
            return
        }

        // Now expense is mutable, so we can modify its properties
        var mutableExpense = expense

        if mutableExpense.splitOption == .equally {
            // Fetch the group members' names (you can update this to use actual names from the users array)
            let groupMembers = group.members.map { getUserById($0)?.fullname ?? "Unknown" }
            // Calculate split amounts
            mutableExpense.splitAmounts = calculateEqualSplit(for: mutableExpense, groupMembers: groupMembers)
        }

        // Add the expense to the group
        if group.expenses == nil {
            group.expenses = []
        }

        group.expenses?.append(mutableExpense)
        print("Expense added to group \(groupId): \(mutableExpense.name)")
    }

}

//
//import Foundation
//import UIKit
//
//struct Group {
//    var id : Int
//    var groupName: String
//    var category: UIImage?
//    var members: [Int]
//}
//
//class GroupDataModel {
//    private var groups: [Group] = []
//    private var users: [User] = []
//
//    static let shared = GroupDataModel()
//
//    private init() {
//        users.append(User(id: 101, email: "user1@example.com", fullname: "john", password: "password", isVerified: true, badges: [], currentGoal: nil, expenses: []))
//        users.append(User(id: 102, email: "user2@example.com", fullname: "steve", password: "password", isVerified: true, badges: [], currentGoal: nil, expenses: []))
//        users.append(User(id: 103, email: "user3@example.com", fullname: "jack", password: "password", isVerified: true, badges: [], currentGoal: nil, expenses: []))
//
//        groups.append(Group(
//                    id: 1,
//                    groupName: "Tech",
//                    category: UIImage(named: "icons8-group-50"), // Replace with your image asset
//                    members: [101, 102]
//                ))
//                groups.append(Group(
//                    id: 2,
//                    groupName: "Gym Buddy's",
//                    category: UIImage(named: "icons8-runners-crossing-finish-line-50"), // Replace with your image asset
//                    members: [103]
//                ))
//    }
//
//    func createGroup(groupName: String, category: UIImage?, members: [Int]) {
//            // Check if groupName is unique
//            guard !groups.contains(where: { $0.groupName == groupName }) else {
//                print("Group with the name '\(groupName)' already exists.")
//                return
//            }
//
//            // Check if all member IDs are valid
//            let invalidMembers = members.filter { userId in !users.contains(where: { $0.id == userId }) }
//            if !invalidMembers.isEmpty {
//                print("Invalid member IDs: \(invalidMembers)")
//                return
//            }
//
//            // Create and append the new group
//            let newGroup = Group(id: (groups.last?.id ?? 0) + 1, groupName: groupName, category: category, members: members)
//            groups.append(newGroup)
//        }
//
//    func addMemberToGroup(groupName: String, userId: Int) {
//        if let groupIndex = groups.firstIndex(where: { $0.groupName == groupName }) {
//            if !groups[groupIndex].members.contains(userId) {
//                groups[groupIndex].members.append(userId)
//            }
//        }
//    }
//
//    func getAllGroups() -> [Group] {
//        return self.groups
//    }
//
//    func getGroupByName(groupName: String) -> Group? {
//        return groups.first { $0.groupName == groupName }
//    }
//
//    func addSplitExpense(expense: ExpenseSplitForm) {
//        guard let groupIndex = groups.firstIndex(where: { $0.id == expense.groupId }) else { return }
//
//        let group = groups[groupIndex]
//        let memberIds = group.members
//
//        for memberId in memberIds {
//            if let user = users.first(where: { $0.id == memberId }) {
//                print("Notifying \(user.fullname) about the new expense: \(expense.name)")
//            }
//        }
//    }
//}
