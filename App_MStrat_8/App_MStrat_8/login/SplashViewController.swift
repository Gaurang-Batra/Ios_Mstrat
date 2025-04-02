//
//  SplashViewController.swift
//  loginpg
//
//  Created by Gaurav on 17/01/25.
//

import UIKit

class SplashViewController: UIViewController {
    
    @IBOutlet var circleview: [UIView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make all circle views circular and set their color to very light gray
        for (index, view) in circleview.enumerated() {
            // Ensure the view is a square by setting equal width and height
            let size = min(view.frame.width, view.frame.height)
            view.frame.size = CGSize(width: size, height: size)
            
            // Make the view circular
            view.layer.cornerRadius = size / 2
            view.layer.masksToBounds = true
            
            // Set the color to very light gray
            view.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0) // Light gray
            
            // Add animation
//            addBounceAnimation(to: view, delay: Double(index) * 0.2)
        }
        
        // Hide the navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
//    private func addBounceAnimation(to view: UIView, delay: TimeInterval) {
//        // Create the bounce animation
//        let animation = CABasicAnimation(keyPath: "transform.scale")
//        animation.fromValue = 1.0
//        animation.toValue = 1.1
//        animation.duration = 1.0
//        animation.autoreverses = true
//        animation.repeatCount = .infinity
//        animation.beginTime = CACurrentMediaTime() + delay
//        
//        // Add animation to the layer
//        view.layer.add(animation, forKey: "bounce")
//    }
}
