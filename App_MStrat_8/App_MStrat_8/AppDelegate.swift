//
//  AppDelegate.swift
//  App_MStrat_8
//
//  Created by Gaurang  on 04/12/24.
//

import UIKit
import SwiftUI
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://snnnvsfkhmujbpkdnynq.supabase.co")!,
    supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNubm52c2ZraG11amJwa2RueW5xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI4MDAyMjMsImV4cCI6MjA1ODM3NjIyM30.OBJQ0aIqSEGHASQ4OFPDjAy8IzZ-dltJ2D8X06_DSP4"
)

class SupabaseAPIClient {
    static let shared = SupabaseAPIClient()
    let supabaseClient: SupabaseClient

    private init() {
        supabaseClient = SupabaseClient(
            supabaseURL: URL(string: "https://snnnvsfkhmujbpkdnynq.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNubm52c2ZraG11amJwa2RueW5xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI4MDAyMjMsImV4cCI6MjA1ODM3NjIyM30.OBJQ0aIqSEGHASQ4OFPDjAy8IzZ-dltJ2D8X06_DSP4"
        )
    }
}


@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

