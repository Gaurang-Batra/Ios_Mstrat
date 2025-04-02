//
//  BackgroundViewController.swift
//  loginpg
//
//  Created by Gaurav on 17/01/25.
//

import UIKit


class BackgroundViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBackgroundCircles()
    }
    
    func addBackgroundCircles() {
        // Array of circles' positions, sizes, and colors
        let circles = [
            (CGRect(x: -100, y: -100, width: 300, height: 300), UIColor.systemGray),
            (CGRect(x: 50, y: 100, width: 100, height: 100), UIColor.systemGray2),
            (CGRect(x: 200, y: 50, width: 50, height: 50), UIColor.systemGray3),
            (CGRect(x: 20, y: 500, width: 200, height: 200), UIColor.systemGray),
            (CGRect(x: 300, y: 600, width: 150, height: 150), UIColor.systemGray2)
        ]
        
        for circle in circles {
            let circleView = UIView(frame: circle.0)
            circleView.backgroundColor = circle.1
            circleView.layer.cornerRadius = circle.0.width / 2 // Make it circular
            circleView.alpha = 0.8
            self.view.addSubview(circleView)
            self.view.sendSubviewToBack(circleView)
        }
    }
}
