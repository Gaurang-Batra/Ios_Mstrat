//
//  NotificationViewController.swift
//  App_MStrat_8
//
//  Created by student-2 on 08/05/25.
//

import UIKit

protocol NotificationCellDelegate: AnyObject {
    func didTapAcceptButton(for notification: Notifications)
}

class NotificationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NotificationCellDelegate {
    var notifications: [Notifications] = []
    var users: [Int: String] = [:]
    var userId: Int? {
        didSet {
            print("NotificationViewController userId set to: \(userId ?? -1)")
        }
    }

    private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔔 NotificationViewController loaded with userId: \(userId ?? -1)")

        // Set up navigation bar
        title = "Notifications"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissViewController)
        )

        // Set up the table view
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        // Set constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // Register the cell class
        tableView.register(notificationTableViewCell.self, forCellReuseIdentifier: "notification")

        // Set table view delegate and data source
        tableView.delegate = self
        tableView.dataSource = self

        // Add refresh control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshNotifications), for: .valueChanged)
        tableView.refreshControl = refreshControl

        // Fetch notifications
        fetchNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchNotifications()
    }

    @objc func dismissViewController() {
        if navigationController != nil {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    @objc func refreshNotifications() {
        fetchNotifications()
    }

    func fetchNotifications() {
        guard let currentUserId = userId else {
            print("❌ No current user ID available")
            refreshControl?.endRefreshing()
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Error",
                    message: "User ID is missing. Please log in again.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
            return
        }

        Task {
            print("🔔 Fetching notifications for userId: \(currentUserId)")
            let fetchedNotifications = await GroupDataModel.shared.fetchNotificationsForUser(userId: currentUserId)
            self.notifications = fetchedNotifications.filter { $0.status == "pending" }
            print("🔔 Fetched \(self.notifications.count) pending notifications: \(self.notifications.map { $0.group_name })")

            // Fetch inviter names
            for notification in notifications {
                let inviterId = notification.inviter_id
                if users[inviterId] == nil {
                    if let user = UserDataModel.shared.getUser(by: inviterId) {
                        users[inviterId] = user.fullname
                        print("🔔 Cached inviter name: \(user.fullname) for inviterId: \(inviterId)")
                    } else {
                        users[inviterId] = "Unknown User"
                        print("🔔 No user found for inviterId: \(inviterId)")
                    }
                }
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                if self.notifications.isEmpty {
                    print("🔔 No pending notifications to display")
                    self.showEmptyStateMessage()
                }
            }
        }
    }

    private func showEmptyStateMessage() {
        let label = UILabel()
        label.text = "No pending notifications"
        label.textAlignment = .center
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundView = label
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView = notifications.isEmpty ? tableView.backgroundView : nil
        return notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "notification", for: indexPath) as? notificationTableViewCell else {
            print("❌ Failed to dequeue notificationTableViewCell")
            return UITableViewCell()
        }

        let notification = notifications[indexPath.row]
        let inviterName = users[notification.inviter_id] ?? "Unknown User"
        cell.configure(with: notification, inviterName: inviterName)
        cell.delegate = self
        return cell
    }

    // MARK: - Table view delegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    // MARK: - NotificationCellDelegate

    func didTapAcceptButton(for notification: Notifications) {
        guard let currentUserId = userId,
              let notificationId = notification.id else {
            print("❌ Missing user ID or notification ID")
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Error",
                    message: "Cannot process request. Missing user or notification data.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
            return
        }

        Task {
            print("🔔 Accepting notification ID: \(notificationId) for group: \(notification.group_id)")
            let success = await GroupDataModel.shared.handleNotificationAcceptance(
                notificationId: notificationId,
                groupId: notification.group_id,
                userId: currentUserId
            )

            if success {
                print("🔔 Successfully accepted notification ID: \(notificationId)")
                self.notifications.removeAll { $0.id == notificationId }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    let alert = UIAlertController(
                        title: "Success",
                        message: "You have joined the group '\(notification.group_name)'",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            } else {
                print("❌ Failed to accept notification ID: \(notificationId)")
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "Error",
                        message: "Failed to join the group. Please try again.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
