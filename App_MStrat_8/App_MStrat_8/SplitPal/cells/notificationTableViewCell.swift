//
//  notificationTableViewCell.swift
//  App_MStrat_8
//
//  Created by student-2 on 07/05/25.
import UIKit

class notificationTableViewCell: UITableViewCell {
    var username: UILabel!
    var acceptbutton: UIButton!
    var notification: Notifications?
    weak var delegate: NotificationCellDelegate?

    // Card view for the cell
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Remove default selection style
        selectionStyle = .none
        backgroundColor = .clear

        // Add card view to content view
        contentView.addSubview(cardView)

        // Initialize username label
        username = UILabel()
        username.translatesAutoresizingMaskIntoConstraints = false
        username.numberOfLines = 0 // Allow multiple lines
        username.font = .systemFont(ofSize: 16, weight: .medium)
        username.textColor = .black
        cardView.addSubview(username)

        // Initialize accept button
        acceptbutton = UIButton(type: .system)
        acceptbutton.translatesAutoresizingMaskIntoConstraints = false
        acceptbutton.setTitle("Accept", for: .normal)
        acceptbutton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        acceptbutton.setTitleColor(.white, for: .normal)
        acceptbutton.backgroundColor = .systemBlue
        acceptbutton.layer.cornerRadius = 8
        acceptbutton.addTarget(self, action: #selector(acceptButtonTapped), for: .touchUpInside)
        cardView.addSubview(acceptbutton)

        // Set up constraints
        NSLayoutConstraint.activate([
            // Card view constraints (8pt margin on sides, 4pt between cells)
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            // Username label constraints
            username.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            username.trailingAnchor.constraint(equalTo: acceptbutton.leadingAnchor, constant: -12),
            username.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            username.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),

            // Accept button constraints
            acceptbutton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            acceptbutton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            acceptbutton.widthAnchor.constraint(equalToConstant: 80),
            acceptbutton.heightAnchor.constraint(equalToConstant: 32)
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
