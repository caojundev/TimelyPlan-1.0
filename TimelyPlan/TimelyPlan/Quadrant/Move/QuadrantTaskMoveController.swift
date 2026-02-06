//
//  QuadrantTaskMoveController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/17.
//

import Foundation

class QuadrantTaskMoveController {
    
    /// 移动任务到特定象限
    func moveTask(_ task: TodoTask, to quadrant: Quadrant) {
        let filterRule = QuadrantSettingAgent.shared.filterRule(for: quadrant)
        let updater = TodoFilterTaskUpdater()
        guard let changes = updater.changes(for: task, with: filterRule), !changes.isEmpty else {
            return
        }
        
        let filterTypes = changes.filterTypes
        if filterTypes.subtracting([.priority, .myDay]).count > 0 {
            /// 弹窗确认
            let chnageVC = TodoFilterTaskChangeViewController(task: task, changes: changes)
            chnageVC.showAsNavigationRoot()
        } else {
            /// 直接更新
            todo.updateTask(task, withChanges: changes)
        }
    }
    
}
