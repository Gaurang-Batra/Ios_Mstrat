import Foundation
import Supabase
import SwiftSMTP

//user-----------
struct User: Codable {
    let id: Int?
    var email: String
    var fullname: String
    var password: String
    var is_verified: Bool?
    var verification_code: String?
    var badges: [String]?
    var currentGoal: Goal?
    var groups: [Int]?
    var expenses: [Expense]?
    var allowance: [Allowance]?
    var is_guest: Bool?

   
}

class UserDataModel {
    private var users: [User] = []
    private var pendingUsers: [String: User] = [:] // Temporary storage for unverified users
    static let shared = UserDataModel()
    private var passwordResetOTPs: [String: String] = [:]
    
    private init() {}
    
    private let client = SupabaseAPIClient.shared.supabaseClient
    
    func getAllUsers() -> [User] {
        return self.users
    }
    
    func getAllUsersfromsupabase(completion: @escaping ([User]?, Error?) -> Void) {
        Task {
            do {
                let query = SupabaseAPIClient.shared.supabaseClient
                    .database
                    .from("users")
                    .select("id, email, fullname, password, is_verified, verification_code, is_guest, groups")

                let response: PostgrestResponse<[User]> = try await query.execute()
                let users = response.value

                if users.isEmpty {
                    print("⚠️ No users found.")
                } else {
                    print("✅ Fetched users: \(users)")
                }

                completion(users, nil)

            } catch {
                print("❌ Error fetching users: \(error)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                        case .typeMismatch(let type, let context):
                            print("Type mismatch for \(type): \(context.debugDescription)")
                            print("Coding path: \(context.codingPath)")
                        case .valueNotFound(let type, let context):
                            print("Value not found for \(type): \(context.debugDescription)")
                        case .keyNotFound(let key, let context):
                            print("Key not found: \(key), \(context.debugDescription)")
                        case .dataCorrupted(let context):
                            print("Data corrupted: \(context.debugDescription)")
                        @unknown default:
                            print("Unknown decoding error: \(error)")
                    }
                }
                completion(nil, error)
            }
        }
    }



    
    func getUser(by id: Int) -> User? {
        return users.first { $0.id == id }
    }
    func getUserByEmail(_ email: String) async -> User? {
        do {
            let response: [User] = try await client
                .database
                .from("users")
                .select()
                .eq("email", value: email)
                .execute()
                .value
            return response.first
        } catch {
            print("❌ Error fetching user by email: \(error)")
            return nil
        }
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
    }
    func deleteUser(userId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
            Task {
                do {
                    try await client
                        .database
                        .from("users")
                        .delete()
                        .eq("id", value: userId)
                        .execute()
                    // Update local cache
                    users.removeAll { $0.id == userId }
//                    pendingUsers.removeAll { $0.value.id == userId }
                    print("🗑️ User \(userId) deleted successfully.")
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                } catch {
                    print("❌ Error deleting user: \(error)")
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
    
    func deleteGuestUser(user: User) {
        guard user.is_guest == true, let id = user.id else { return }
        Task {
            do {
                try await client
                    .database
                    .from("users")
                    .delete()
                    .eq("id", value: id)
                    .execute()
                users.removeAll { $0.id == id }
                print("🗑️ Guest user deleted.")
            } catch {
                print("❌ Error deleting guest user: \(error)")
            }
        }
    }
    
    func createGuestUser() async -> User? {
        let uuid = UUID().uuidString
        let guestEmail = "guest_\(uuid)@guest.com"
        
        let guestUser = User(
            id: nil,
            email: guestEmail,
            fullname: "Guest\(uuid)",
            password: "guest_pass_\(uuid)",
            is_verified: false,
            verification_code: nil,

            is_guest: true
        )
        
        do {
            let response: PostgrestResponse<User> = try await SupabaseAPIClient.shared.supabaseClient
                .database
                .from("users")
                .insert([guestUser])
                .select()
                .single()
                .execute()
            
            let insertedUser = response.value
            guard let userId = insertedUser.id else {
                print("❌ Failed to retrieve inserted guest user ID")
                return nil
            }
            
            print("✅ Guest user inserted with ID: \(userId)")
            users.append(insertedUser)
            return insertedUser
        } catch {
            print("❌ Failed to insert guest user: \(error)")
            return nil
        }
    }
    
    func createUser(email: String, fullname: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        let verificationCode = String(format: "%04d", Int.random(in: 0...9999))
        
        let newUser = User(
            id: nil,
            email: email,
            fullname: fullname,
            password: password,
            is_verified: false,
            verification_code: verificationCode,
            is_guest: false
        )
        
        // Store user temporarily
        pendingUsers[email] = newUser
        
        // Send verification email
        sendVerificationEmail(to: email, code: verificationCode) { success, message in
            if success {
                print("✅ \(message)")
                completion(.success(newUser))
            } else {
                print("❌ \(message)")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: message])))
            }
        }
    }
    
    func validateResetOTP(email: String, otp: String) -> Bool {
        guard let storedOTP = passwordResetOTPs[email] else {
            return false
        }
        return storedOTP == otp
    }

    // Clear OTP after use
    func clearResetOTP(email: String) {
        passwordResetOTPs.removeValue(forKey: email)
    }
    
    func verifyUser(email: String, code: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let pendingUser = pendingUsers[email] else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found in pending list"])))
            return
        }
        
        if pendingUser.verification_code == code {
            completion(.success(()))
        } else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid verification code"])))
        }
    }
    
    func confirmUser(email: String, completion: @escaping (Result<User, Error>) -> Void) {
        guard let pendingUser = pendingUsers[email] else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found in pending list"])))
            return
        }
        
        Task {
            do {
                // Insert user into Supabase and retrieve the inserted user with ID
                let response: PostgrestResponse<User> = try await client
                    .database
                    .from("users")
                    .insert([pendingUser])
                    .select()
                    .single()
                    .execute()
                
                // Since .single() ensures one result, response.value is non-optional
                let confirmedUser = response.value
                print("✅ Inserted user into Supabase with ID: \(confirmedUser.id ?? -1)")
                
                // Verify that the user has a valid ID
                guard confirmedUser.id != nil else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Inserted user has no ID"])
                }
                
                users.append(confirmedUser)
                pendingUsers.removeValue(forKey: email) // Clear from pending
                completion(.success(confirmedUser))
            } catch {
                print("❌ Supabase insert failed: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func checkUserExists(email: String, fullname: String) async -> (emailExists: Bool, fullnameExists: Bool) {
        do {
            let response: [User] = try await client
                .database
                .from("users")
                .select()
                .or("email.eq.\(email),fullname.eq.\(fullname)")
                .execute()
                .value
            let emailExists = response.contains { $0.email.lowercased() == email.lowercased() }
            let fullnameExists = response.contains { $0.fullname.lowercased() == fullname.lowercased() }
            return (emailExists, fullnameExists)
        } catch {
            print("❌ Error checking user existence: \(error)")
            return (false, false)
        }
    }
    func generateAndStoreOTP(for email: String) -> String {
        let otp = String(format: "%04d", Int.random(in: 0...9999))
        passwordResetOTPs[email] = otp
        return otp
    }
    
    func sendPasswordResetOTP(to email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let otp = generateAndStoreOTP(for: email)
        sendVerificationEmail(to: email, code: otp) { success, message in
            if success {
                print("✅ OTP sent to \(email): \(otp)")
                completion(.success(()))
            } else {
                print("❌ \(message)")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: message])))
            }
        }
    }
    private func sendVerificationEmail(to email: String, code: String, completion: @escaping (Bool, String) -> Void) {
        let smtp = SMTP(
            hostname: "smtp.gmail.com",
            email: "sharmankush004a@gmail.com",
            password: "bszb vxlu fabx fyns",
            port: 465,
            tlsMode: .requireTLS
        )

        let from = Mail.User(name: "Ankush", email: "sharmankush004a@gmail.com")
        let to = Mail.User(name: "User", email: email)

        let mail = Mail(
            from: from,
            to: [to],
            subject: "Verification Code",
            text: """
            Hello!
            Welcome to Mstart.
            Your verification code is: \(code).
            Please enter this code to verify your account.
            Best Regards,
            Team Mstart
            """
        )

        smtp.send(mail) { error in
            if let error = error {
                completion(false, "Error sending email: \(error.localizedDescription)")
            } else {
                completion(true, "Verification email sent successfully to \(email)")
            }
        }
    }
    
    func updateUser(userId: Int, name: String, phone: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let payload: [String: AnyEncodable] = [
            "fullname": AnyEncodable(name),
            "phone": AnyEncodable(phone)
        ]
        
        Task {
            do {
                try await client
                    .database
                    .from("users")
                    .update(payload)
                    .eq("id", value: userId)
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
            "password": AnyEncodable(newPassword)
        ]
        
        Task {
            do {
                try await client
                    .database
                    .from("users")
                    .update(payload)
                    .eq("id", value: userId)
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
