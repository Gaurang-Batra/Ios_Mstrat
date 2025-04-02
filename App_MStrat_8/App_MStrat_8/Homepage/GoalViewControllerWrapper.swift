//
//  GoalViewControllerWrapper.swift
//  App_MStrat_8
//
//  Created by student-2 on 24/03/25.
//

import Foundation
import SwiftUI
import UIKit

struct GoalViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> GoalViewController {
        return GoalViewController()
    }
    
    func updateUIViewController(_ uiViewController: GoalViewController, context: Context) {}
}
