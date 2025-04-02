//
//  SplitpalViewController.swift
//  App_MStrat_8
//
//  Created by Gaurang  on 04/12/24.
//
import UIKit

class SplitpalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var Balanceviewcontainer: UIView!
    @IBOutlet weak var Groupsviewcontainer: UIView!
    @IBOutlet weak var addgroupbutton: UIButton!
    @IBOutlet weak var welcomeimage: UIImageView!
    @IBOutlet weak var tableView: UITableView!

    var selectedGroupIndex: Int? = nil
    var selectedImage: UIImage? = nil
    var userId : Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        print ("this id is on the split page : \(userId))")

        tableView.delegate = self
        tableView.dataSource = self

        if let image = UIImage(named: "Group") {
            welcomeimage.image = image
        }

        Balanceviewcontainer.layer.cornerRadius = 20
        Balanceviewcontainer.layer.masksToBounds = true

        setTopCornerRadius(for: Groupsviewcontainer, radius: 20)
        createVerticalDottedLineInBalanceContainer(atX: Balanceviewcontainer.bounds.size.width / (5/2))

        addgroupbutton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        addgroupbutton.titleLabel?.textAlignment = .center

        makeButtonCircular()
        tableView.separatorStyle = .singleLine

        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: .newGroupAdded, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: .newexpenseaddedingroup, object: nil)
//
//        tableView.reloadData() // Initial reload (if needed)
    }

//    deinit {
//        NotificationCenter.default.removeObserver(self, name: .newGroupAdded, object: nil)
//        NotificationCenter.default.removeObserver(self, name: .newexpenseaddedingroup, object: nil)
//    }

    @objc func reloadTableView() {
        tableView.reloadData()
    }

    func setTopCornerRadius(for view: UIView, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: view.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        view.layer.mask = maskLayer
    }

    func createVerticalDottedLineInBalanceContainer(atX xPosition: CGFloat) {
        let dottedLine = CAShapeLayer()
        let path = UIBezierPath()
        let centerY = Balanceviewcontainer.bounds.size.height / 2
        let lineLength: CGFloat = 98
        let startY = centerY - (lineLength / 2)
        let endY = startY + lineLength

        path.move(to: CGPoint(x: xPosition, y: startY))
        path.addLine(to: CGPoint(x: xPosition, y: endY))

        dottedLine.path = path.cgPath
        dottedLine.strokeColor = UIColor.black.withAlphaComponent(0.4).cgColor
        dottedLine.lineWidth = 1.5
        dottedLine.lineDashPattern = [6, 2]

        Balanceviewcontainer.layer.addSublayer(dottedLine)
    }

    func makeButtonCircular() {
        let sideLength = min(addgroupbutton.frame.size.width, addgroupbutton.frame.size.height)
        addgroupbutton.layer.cornerRadius = sideLength / 2
        addgroupbutton.layer.masksToBounds = true
    }

    // MARK: - UITableViewDataSource Methods

    func numberOfSections(in tableView: UITableView) -> Int {
        return GroupDataModel.shared.getAllGroups().count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SplitCell", for: indexPath)
        let group = GroupDataModel.shared.getAllGroups()[indexPath.section]
        cell.textLabel?.text = group.groupName
        cell.imageView?.image = group.category ?? UIImage(systemName: "photo")

        return cell
    }

    // MARK: - UITableViewDelegate Methods

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedGroupIndex = indexPath.section
        performSegue(withIdentifier: "Groupsdetails", sender: self)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }

    // MARK: - Segue Preparation
    
    @IBAction func addGroupButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "createsplitgroup", sender: self)
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Groupsdetails",
           let destinationVC = segue.destination as? GroupDetailViewController,
           let selectedIndex = selectedGroupIndex {
            destinationVC.userId = self.userId
            let selectedGroup = GroupDataModel.shared.getAllGroups()[selectedIndex]
            destinationVC.groupItem = selectedGroup
        }
        else if segue.identifier == "createsplitgroup" {
            if let navigationController = segue.destination as? UINavigationController,
               let createGroupVC = navigationController.topViewController as? CreateGroupViewController {
                
                createGroupVC.userId = self.userId
                print("id passed to create splitgroup form page")
            }
        }
    }
}
