// membersdatamodel.swift
//  App_MStrat_8
//
//  Created by student-2 on 10/12/24.
//
// membersdatamodel.swift
// App_MStrat_8

import Foundation

// Define the Member struct
struct Member {
    var profile: String
    var name: String
    var phonenumber: String
    var ismember: Bool // Flag to determine if the person is a member
}

// Global array containing all members (both invited and actual members)
var globalMembers: [Member] = [
    // Invited
    Member(profile: "👩‍🎤", name: "Alice Cooper", phonenumber: "456-789-0123", ismember: false),
    Member(profile: "👨‍🚀", name: "Charlie Brown", phonenumber: "567-890-1234", ismember: false),
    
    // Actual members
    Member(profile: "👨‍💻", name: "John Doe", phonenumber: "123-456-7890", ismember: true),
    Member(profile: "👩‍⚕️", name: "Jane Smith", phonenumber: "234-567-8901", ismember: true),
    Member(profile: "👨‍🍳", name: "Bob Johnson", phonenumber: "345-678-9012", ismember: true)
]
