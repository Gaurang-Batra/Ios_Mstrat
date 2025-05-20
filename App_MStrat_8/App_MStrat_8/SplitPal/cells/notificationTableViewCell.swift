//
//  notificationTableViewCell.swift
//  App_MStrat_8
//
//  Created by student-2 on 07/05/25.
//
import UIKit

class notificationTableViewCell: UITableViewCell {

    var username: UILabel!
    var acceptbutton: UIButton!
    var notification: Notifications?
    weak var delegate: NotificationCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Initialize username label
        username = UILabel()
        username.translatesAutoresizingMaskIntoConstraints = false
        username.numberOfLines = 0 // Allow multiple lines
        username.font = .systemFont(ofSize: 16)
        contentView.addSubview(username)

        // Initialize accept button
        acceptbutton = UIButton(type: .system)
        acceptbutton.translatesAutoresizingMaskIntoConstraints = false
        acceptbutton.setTitle("Accept", for: .normal)
        acceptbutton.titleLabel?.font = .systemFont(ofSize: 16)
        acceptbutton.addTarget(self, action: #selector(acceptButtonTapped), for: .touchUpInside)
        contentView.addSubview(acceptbutton)

        // Set up constraints
        NSLayoutConstraint.activate([
            // Username label constraints
            username.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            username.trailingAnchor.constraint(equalTo: acceptbutton.leadingAnchor, constant: -8),
            username.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            username.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            // Accept button constraints
            acceptbutton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            acceptbutton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            acceptbutton.widthAnchor.constraint(equalToConstant: 80)
        ])
    }

    @objc func acceptButtonTapped() {
        guard let notification = notification else { return }
        delegate?.didTapAcceptButton(for: notification)
    }

    func configure(with notification: Notifications, inviterName: String?) {
        self.notification = notification
        username.text = "\(inviterName ?? "Someone") invited you to join \(notification.group_name)"
        acceptbutton.setTitle("Accept", for: .normal)
    }
}
