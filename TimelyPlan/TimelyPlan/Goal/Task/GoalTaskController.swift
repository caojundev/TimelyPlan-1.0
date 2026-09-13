//
//  GoalTaskController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/4.
//

import Foundation
import UIKit

class GoalTaskController {
    
    func performMenuAction(_ type: GoalTaskMenuType, for task: GoalTask) {
        switch type {
        case .completeAll:
            completeAll(for: task)
        case .addRecord:
            addRecordManually(for: task)
        case .reset:
            resetProgress(for: task)
        case .addToMyDay:
            GoalRepository.updateGoalTask(task, isAddedToMyDay: true)
        case .removeFromMyDay:
            GoalRepository.updateGoalTask(task, isAddedToMyDay: false)
        case .startFocus:
            FocusPresenter.quickStartFocus(for: task)
        case .move:
            moveTask(task)
        case .edit:
            GoalPresenter.editGoalTask(task)
        case .delete:
            deleteTask(task)
        }
    }
    
    /// 移动任务到其他目标计划
    func moveTask(_ task: GoalTask) {
        let vc = GoalTaskMoveViewController(goalPlan: task.planFeature)
        vc.didSelectGoalPlan = { goalPlan in
            GoalRepository.moveGoalTask(task, to: goalPlan)
        }
        vc.didSelectInbox = {
            GoalRepository.moveGoalTaskToInbox(task)
        }
        
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .formSheet
        navController.show()
    }
    
    /// 重置进度：删除目标任务的全部记录（日期区间为 nil），并按剩余记录重算当前值回退到初始值
    func resetProgress(for task: GoalTask) {
        let cancelAction = TPAlertAction.cancel
        let resetAction = TPAlertAction(type: .destructive, title: resGetString("Reset")) { action in
            TPImpactFeedback.feedbackWithWarningStyle()
            GoalRepository.deleteRecords(for: task, fromDate: nil, toDate: nil)
        }
    
        let title = resGetString("Reset Progress")
        let message = resGetString("All records will be deleted and the progress will be reset. Are you sure?")
        let vc = TPAlertController(title: title, message: message)
        vc.actions = [cancelAction, resetAction]
        vc.show()
    }
    
    /// 弹窗确认删除任务
    func deleteTask(_ task: GoalTask){
        let deleteAction = TPAlertAction(type: .destructive,
                                         title: resGetString("Delete")) { action in
            GoalRepository.deleteGoalTask(task)
        }
        
        let cancelAction = TPAlertAction(type: .cancel,
                                         title: resGetString("Cancel"))
        
        let format: String = resGetString("\"%@\" will be permanently deleted.")
        let message = String(format: format, task.displayName)
        let alertController = TPAlertController(title: resGetString("Delete Goal Task"),
                                                message: message,
                                                actions: [cancelAction, deleteAction])
        alertController.show()
    }
    
    /// 完成所有：推进到目标值（100%）
    func completeAll(for task: GoalTask) {
        TPImpactFeedback.feedbackWithSuccessStyle()
        GoalRepository.completeAll(for: task)
    }
    
    /// 手动输入记录
    func addRecordManually(for task: GoalTask) {
        let inputVC = GoalRecordInputViewController.inputViewController(for: task)
        inputVC.completion = { value, inputType, remark in
            /// 更新当前数值并写入一条目标记录
            GoalRepository.record(amount: value,
                                  inputType: inputType,
                                  note: remark,
                                  for: task)
        }
        
        inputVC.show()
    }

    /// 点击复选框记录进度或切换完成状态
    func clickCheckbox(for task: GoalTask) {
        if task.isCompleted {
            /// 已完成的任务：点击取消完成
            TPImpactFeedback.impactWithSoftStyle()
            GoalRepository.updateGoalTask(task, isCompleted: false)
            return
        }
        
        /// 无有效进度范围（开始值 == 目标值）的任务：点击直接完成
        if task.checkType == .normal {
            TPImpactFeedback.impactWithMediumStyle()
            GoalRepository.updateGoalTask(task, isCompleted: true)
            return
        }
        
        /// 自动记录模式：直接累加一次预设数值
        if let autoValue = task.autoRecordedCurrentValue() {
            let oldValue = task.currentValue
            TPImpactFeedback.feedbackWithSuccessStyle()
            GoalRepository.updateGoalTask(task, currentValue: autoValue)
            GoalRepository.addRecord(amount: autoValue - oldValue, for: task)
            return
        }
        
        /// 手动输入记录
        let inputVC = GoalRecordInputViewController.inputViewController(for: task)
        inputVC.completion = { value, inputType, remark in
            /// 更新当前数值并写入一条目标记录
            GoalRepository.record(amount: value,
                                  inputType: inputType,
                                  note: remark,
                                  for: task)
        }
        
        inputVC.show()
    }
    
}
