import UIKit

protocol AddMemberCellDelegate: AnyObject {
    func didTapInviteButton(for user: User)
}

class AddmemberCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var invitebutton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!

    weak var delegate: AddMemberCellDelegate? // Delegate to notify the parent controller
    private var user: User?        // To store the associated user
    private var isInvited: Bool = false // Track the current invitation state
    
    override func awakeFromNib() {
        super.awakeFromNib()
        invitebutton.addTarget(self, action: #selector(inviteButtonClicked), for: .touchUpInside)
    }
    
    @objc func inviteButtonClicked() {
        guard let user = user else {
            print("No user associated with this cell.")
            return
        }

        // Toggle the button's state
        isInvited.toggle()

        if isInvited {
            // Notify the delegate that the user is invited
            delegate?.didTapInviteButton(for: user)
            invitebutton.setTitle("Sent", for: .normal)
            invitebutton.setTitleColor(.black, for: .normal)
            invitebutton.backgroundColor = .systemGray5
        } else {
            // User canceled the invitation
            delegate?.didTapInviteButton(for: user)
            invitebutton.setTitle("Invite", for: .normal)
            invitebutton.setTitleColor(.systemBlue, for: .normal)
            invitebutton.backgroundColor = .clear
        }
    }
    
    // Configure the cell with user data
    func configure(with user: User) {
        self.user = user
        nameLabel.text = user.fullname

        // Reset button state when reusing the cell
        isInvited = false
        invitebutton.setTitle("Invite", for: .normal)
        invitebutton.setTitleColor(.systemBlue, for: .normal)
        invitebutton.backgroundColor = .clear
    }
}
