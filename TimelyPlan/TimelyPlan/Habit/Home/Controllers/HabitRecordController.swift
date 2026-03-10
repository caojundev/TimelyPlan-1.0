//
//  HabitRecordController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/7/9.
//

import UIKit

class HabitRecordController: NSObject {

    /// 点击记录按钮
    func clickRecrod(for task: HabitTask, on date: Date) {
        if task.goal.mode == .checkin {
            /// 打卡模式，完成所有
            completeAll(for: task, on: date)
        } else {
            let recordType = task.goal.validatedRecordType
            switch recordType {
            case .completeAll:
                completeAll(for: task, on: date)
            case .manually:
                recordManually(for: task, on: date)
            case .automatically:
                recordAutomatically(for: task, on: date)
            }
        }
    }
    
    // 完成所有
    func completeAll(for task: HabitTask, on date: Date) {
        TPImpactFeedback.feedbackWithSuccessStyle()
        habit.completeAll(for: task, on: date)
    }

    // 手动输入记录
    func recordManually(for task: HabitTask, on date: Date) {
        let vc = HabitRecordInputAlertController()
        vc.alertTitle = resGetString("Record")
        vc.completion = { number, type in
            habit.updateRecord(amount: number.int64Value, inputType: type, for: task, on: date)
        }

        vc.popoverShow()
    }

    // 自动输入
    func recordAutomatically(for task: HabitTask, on date: Date) {
        let amount = task.goal.validatedRecordAmount
        habit.updateRecord(amount: amount,
                           inputType: .byIncrement,
                           for: task,
                           on: date)
    }

    // MARK: - 跳过今日
    func skipToday(for task: HabitTask, on date: Date, from sourceView: UIView?) {
        /*
        let vc = ReasonTagSelectViewController(style: .grouped, type: .habitSkip)
        vc.title = resGetString("Pick a Skip Tag")
        vc.didSelectTag = { tag in
            TFImpactFeedback.feedbackWithWarningStyle()
            habit.skip(withTag: tag, for: task, on: date)
        }
        
        let navController = UINavigationController(rootViewController: vc)
        navController.show(fromSourceView: sourceView,
                            preferredPosition: .bottomLeft,
                            animated: true,
                            completion: nil)
        */
    }
    
    // MARK: - 取消跳过
    func cancelSkip(for task: HabitTask, on date: Date) {
        habit.cancelSkip(for: task, on: date)
    }

    func cancelFail(for task: HabitTask, on date: Date) {
        habit.cancelFail(for: task, on: date)
    }
    
    // MARK: - 标记未失败
    func markAsFail(for task: HabitTask, on date: Date, from sourceView: UIView?) {
//        let vc =  ReasonTagSelectViewController(style: .grouped, type: .habitFail)
//        vc.didSelectTag = { tag in
//            TFImpactFeedback.feedbackWithErrorStyle()
//            habit.markAsFail(withTag: tag, for: task, on: date)
//        }
//
//        let navController = UINavigationController(rootViewController: vc)
//        if sourceView == nil {
//            navController.showWithAlertStyle()
//        } else {
//            navController.show(fromSourceView: sourceView,
//                                preferredPosition: .bottomLeft,
//                                animated: true,
//                                completion: nil)
//        }
    }

    // MARK: - 重置数据
    func resetToday(of date: Date, for task: HabitTask) {
        let cancelAction = TPAlertAction.cancel
        let resetAction = TPAlertAction(type: .destructive, title: resGetString("Reset")) { action in
            habit.resetToday(of: date, for: task)
        }
    
        let title = resGetString("Reset Today")
        let message = resGetString("All records will be removed for today. Are you sure to reset the habit?")
        let vc = TPAlertController(title: title, message: message)
        vc.actions = [cancelAction, resetAction]
        vc.show()
    }
    
    // MARK: - 添加日志
    func editLog(_ logInfo: HabitRecordLogInfo?, for task: HabitTask, on date: Date) {
        let logInfo = logInfo ?? HabitRecordLogInfo()
        let vc = HabitRecordLogEditViewController(logInfo: logInfo, date: date)
        vc.didEndEditing = { logInfo in
            habit.addLog(logInfo, for: task, on: date)
        }
        
        vc.showAsNavigationRoot()
    }
    
    func deleteLog(for task: HabitTask, on date: Date) {
        habit.addLog(nil, for: task, on: date)
    }
}
