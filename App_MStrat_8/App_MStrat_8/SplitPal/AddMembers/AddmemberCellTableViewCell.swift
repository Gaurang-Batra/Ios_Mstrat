import UIKit

protocol AddMemberCellDelegate: AnyObject {
    func didTapInviteButton(for user: User)
}

class AddmemberCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var invitebutton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!

    weak var delegate: AddMemberCellDelegate?
    private var user: User?
    private var isInvited: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        invitebutton.addTarget(self, action: #selector(inviteButtonClicked), for: .touchUpInside)
    }

    @objc func inviteButtonClicked() {
        guard let user = user else {
            print("No user associated with this cell.")
            return
        }
        print("user with this id is added to the new group : \(user)")

        isInvited.toggle()

        if isInvited {
            delegate?.didTapInviteButton(for: user)
            invitebutton.setTitle("Sent", for: .normal)
            invitebutton.setTitleColor(.black, for: .normal)
            invitebutton.backgroundColor = .systemGray5
        } else {
            delegate?.didTapInviteButton(for: user)
            invitebutton.setTitle("Invite", for: .normal)
            invitebutton.setTitleColor(.systemBlue, for: .normal)
            invitebutton.backgroundColor = .clear
        }
    }

    func configure(with user: User) {
        self.user = user
        nameLabel.text = user.fullname

        isInvited = false
        invitebutton.setTitle("Invite", for: .normal)
        invitebutton.setTitleColor(.systemBlue, for: .normal)
        invitebutton.backgroundColor = .clear
    }
}
