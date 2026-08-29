//
//  GanttEventProcessor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/29.
//

import Foundation
import UIKit

class GanttEventProcessor {
    
    /// 点击事项
    func clickEvent(_ event: GanttEvent) {
        switch event.source {
        case .todo:
            clickTodoEvent(event)
        case .goal:
            break
        }
    }
    
    /// 点击待办
    private func clickTodoEvent(_ event: GanttEvent) {
        guard let task = event.sourceItem as? TodoTask else {
            return
        }
        
        let editVC = TodoTaskEditViewController(task: task)
        let navController = UINavigationController(rootViewController: editVC)
        if let sheet = navController.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.detents = [.medium(), .large()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
        }
        
        navController.show()
    }
}
