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
        HabitRepository.completeAll(for: task, on: date)
    }

    // 手动输入记录
    func recordManually(for task: HabitTask, on date: Date) {
        let vc = HabitRecordInputAlertController()
        vc.completion = { number, type in
            HabitRepository.updateRecord(amount: number.int64Value, inputType: type, for: task, on: date)
        }

        vc.popoverShow()
    }

    // 自动输入
    func recordAutomatically(for task: HabitTask, on date: Date) {
        let amount = task.goal.validatedRecordAmount
        HabitRepository.updateRecord(amount: amount,
                           inputType: .byIncrement,
                           for: task,
                           on: date)
    }

    // MARK: - 跳过今日
    func skipToday(for task: HabitTask, on date: Date) {
        let vc = HabitReasonTagSelectViewController()
        vc.didSelectTag = { tag in
            TPImpactFeedback.feedbackWithWarningStyle()
            HabitRepository.skip(with: tag, for: task, on: date)
        }
        
        vc.popoverShowAsNavigationRoot()
    }
    
    // MARK: - 取消跳过
    func cancelSkip(for task: HabitTask, on date: Date) {
        HabitRepository.cancelSkip(for: task, on: date)
    }

    func cancelFail(for task: HabitTask, on date: Date) {
        HabitRepository.cancelFail(for: task, on: date)
    }
    
    // MARK: - 标记未失败
    func markAsFail(for task: HabitTask, on date: Date) {
        let vc = HabitReasonTagSelectViewController()
        vc.didSelectTag = { tag in
            TPImpactFeedback.feedbackWithErrorStyle()
            HabitRepository.markAsFail(with: tag, for: task, on: date)
        }
        
        vc.popoverShowAsNavigationRoot()
    }

    // MARK: - 重置数据
    func resetToday(of date: Date, for task: HabitTask) {
        let cancelAction = TPAlertAction.cancel
        let resetAction = TPAlertAction(type: .destructive, title: resGetString("Reset")) { action in
            HabitRepository.resetToday(of: date, for: task)
        }
    
        let title = resGetString("Reset Today")
        let message = resGetString("All records will be removed for today. Are you sure to reset the habit?")
        let vc = TPAlertController(title: title, message: message)
        vc.actions = [cancelAction, resetAction]
        vc.show()
    }
    
    // MARK: - 添加日志
    func editLog(for task: HabitTask, with record: HabitRecord?, on date: Date) {
        let vc = HabitRecordLogEditViewController(task: task, record: record, date: date)
        vc.didEndEditing = { logInfo in
            HabitRepository.addLog(logInfo, for: task, on: date)
        }
        
        vc.showAsNavigationRoot()
    }
    
    
    func deleteLog(for task: HabitTask, on date: Date) {
        HabitRepository.addLog(nil, for: task, on: date)
    }
}
