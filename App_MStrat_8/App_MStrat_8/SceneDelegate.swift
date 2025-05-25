//
//  SceneDelegate.swift
//  App_MStrat_8
//
//  Created by Gaurang  on 04/12/24.
//
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let userId = UserDefaults.standard.storedUserId {
            print("🌟 Fetched userId from UserDefaults: \(userId)")
            let tabBarController = storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
            
            if let viewControllers = tabBarController.viewControllers {
                for viewController in viewControllers {
                    if let navController = viewController as? UINavigationController,
                       let rootVC = navController.viewControllers.first {
                        passUserId(to: rootVC, userId: userId)
                    } else {
                        passUserId(to: viewController, userId: userId)
                    }
                }
            }
            
            window?.rootViewController = tabBarController
        } else {
            print("❌ No userId found in UserDefaults, showing login screen")
            let navController = storyboard.instantiateViewController(withIdentifier: "startingpagevc") as! UINavigationController
            window?.rootViewController = navController
        }
        
        window?.makeKeyAndVisible()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        if let userId = UserDefaults.standard.storedUserId {
            print("🌟 App resumed with userId: \(userId)")
        } else {
            print("❌ No userId on resume, redirecting to login")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let navController = storyboard.instantiateViewController(withIdentifier: "startingpagevc") as! UINavigationController
            window?.rootViewController = navController
        }
    }

    private func passUserId(to viewController: UIViewController, userId: Int) {
        if let homeVC = viewController as? homeViewController {
            homeVC.userId = userId
            print("✅ UserId passed to homeViewController: \(userId)")
        } else if let splitpalVC = viewController as? SplitpalViewController {
            splitpalVC.userId = userId
            print("✅ UserId passed to SplitpalViewController: \(userId)")
        } else if let censusVC = viewController as? CensusViewController {
            censusVC.userId = userId
            print("✅ UserId passed to CensusViewController: \(userId)")
        } else if let profileVC = viewController as? PersonalInformationViewController {
            profileVC.userId = userId
            print("✅ UserId passed to PersonalInformationViewController: \(userId)")
        } else {
            print("⚠️ Unhandled view controller: \(type(of: viewController))")
        }
    }
}

extension UserDefaults {
    var storedUserId: Int? {
        get {
            if object(forKey: "userId") != nil {
                return integer(forKey: "userId")
            }
            return nil
        }
        set {
            if let userId = newValue {
                set(userId, forKey: "userId")
                print("✅ Saved userId to UserDefaults: \(userId)")
            } else {
                removeObject(forKey: "userId")
                print("✅ Cleared userId from UserDefaults")
            }
            synchronize()
        }
    }
}
