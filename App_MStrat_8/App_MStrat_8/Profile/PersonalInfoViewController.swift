import UIKit

class PersonalInfoViewController: UIViewController {

    @IBOutlet weak var saveandcontinue: UIButton!
    @IBOutlet weak var Nametextfield: UITextField!
    @IBOutlet weak var PhoneTextfield: UITextField!
    @IBOutlet weak var EmailTextfield: UITextField!
    
    private var isEditingEnabled = false
    var userId: Int?  // User ID passed from previous screen

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("This ID is in profile info: \(userId ?? -1)")
        
        configureSaveAndContinueButton()
        configureTextFields()
        preFillUserData()
        disableEditing()
        configureNavigationBar()
        updateSaveAndContinueButtonState()
    }

    func configureNavigationBar() {
        let editButton = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editButtonTapped)
        )
        navigationItem.rightBarButtonItem = editButton
    }

    @objc func editButtonTapped() {
        isEditingEnabled.toggle()
        if isEditingEnabled {
            enableEditing()
            navigationItem.rightBarButtonItem?.title = "Done"
        } else {
            disableEditing()
            navigationItem.rightBarButtonItem?.title = "Edit"
        }
        updateSaveAndContinueButtonState()
    }

    func enableEditing() {
        Nametextfield.isEnabled = true
        PhoneTextfield.isEnabled = true
    }

    func disableEditing() {
        Nametextfield.isEnabled = false
        PhoneTextfield.isEnabled = false
    }

    func updateSaveAndContinueButtonState() {
        saveandcontinue.isEnabled = !isEditingEnabled
        saveandcontinue.alpha = saveandcontinue.isEnabled ? 1.0 : 0.5
    }

    func configureSaveAndContinueButton() {
        saveandcontinue.setTitle("Save and Continue", for: .normal)
        saveandcontinue.setTitleColor(.white, for: .normal)
        saveandcontinue.backgroundColor = UIColor.systemBlue
        saveandcontinue.layer.cornerRadius = 8
    }

    func configureTextFields() {
        Nametextfield.placeholder = "Enter your name"
        PhoneTextfield.placeholder = "Enter your phone number"
        EmailTextfield.placeholder = "Email address cannot be changed"
        
        Nametextfield.isEnabled = false
        PhoneTextfield.isEnabled = false
        EmailTextfield.isEnabled = false
        
        Nametextfield.borderStyle = .roundedRect
        PhoneTextfield.borderStyle = .roundedRect
        EmailTextfield.textColor = UIColor.gray
    }

    func preFillUserData() {
        guard let userId = userId,
              let user = UserDataModel.shared.getUser(by: userId) else {
            print("User not found")
            return
        }
        
        Nametextfield.text = user.fullname
        EmailTextfield.text = user.email  // Email is not editable
        PhoneTextfield.text = ""  // If you have phone data, set it here
    }

    @IBAction func saveAndContinueTapped(_ sender: UIButton) {
        guard let name = Nametextfield.text, !name.isEmpty,
              let phone = PhoneTextfield.text, !phone.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }

        showAlert(title: "Changes Saved", message: "Your changes have been saved successfully.")
    }

    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
