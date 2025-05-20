////
////  notificationTableViewController.swift
////  App_MStrat_8
////
////  Created by student-2 on 07/05/25.
////
//
//import UIKit
//protocol NotificationCellDelegate: AnyObject {
//    func didTapAcceptButton(for notification: Notifications)
//}
//
//    class notificationTableViewController: UITableViewController, NotificationCellDelegate {
//        
//        var notifications: [Notifications] = []
//        var users: [Int: String] = [:] // Cache for inviter names
//        var userId: Int?
//
//        override func viewDidLoad() {
//            super.viewDidLoad()
//            tableView.register(UINib(nibName: "notificationTableViewCell", bundle: nil), forCellReuseIdentifier: "NotificationCell")
//        }
//
//        override func viewWillAppear(_ animated: Bool) {
//            super.viewWillAppear(animated)
//            fetchNotifications()
//        }
//
//        func fetchNotifications() {
//            guard let currentUserId = userId else {
//                print("❌ No current user ID available")
//                return
//            }
//            
//            Task {
//                let fetchedNotifications = await GroupDataModel.shared.fetchNotificationsForUser(userId: currentUserId)
//                self.notifications = fetchedNotifications.filter { $0.status == "pending" }
//                
//                // Fetch inviter names
//                for notification in notifications {
//                    let inviterId = notification.inviter_id
//                    if users[inviterId] == nil {
//                        if let user = UserDataModel.shared.getUser(by: inviterId) {
//                            users[inviterId] = user.fullname
//                        }
//                    }
//                }
//                
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//            }
//        }
//
//        // MARK: - Table view data source
//        override func numberOfSections(in tableView: UITableView) -> Int {
//            return 1
//        }
//
//        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//            return notifications.count
//        }
//
//        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as? notificationTableViewCell else {
//                return UITableViewCell()
//            }
//            
//            let notification = notifications[indexPath.row]
//            let inviterName = users[notification.inviter_id]
//            cell.configure(with: notification, inviterName: inviterName)
//            cell.delegate = self
//            return cell
//        }
//
//        // MARK: - NotificationCellDelegate
//        func didTapAcceptButton(for notification: Notifications) {
//            guard let currentUserId = userId,
//                  let notificationId = notification.id else {
//                print("❌ Missing user ID or notification ID")
//                return
//            }
//            
//            Task {
//                let success = await GroupDataModel.shared.handleNotificationAcceptance(
//                    notificationId: notificationId,
//                    groupId: notification.group_id,
//                    userId: currentUserId
//                )
//                
//                if success {
//                    // Remove the notification from the list
//                    self.notifications.removeAll { $0.id == notificationId }
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                    }
//                }
//            }
//        }
//    }
//
//
