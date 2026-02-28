//
//  FocusPresenter.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/21.
//

import Foundation

import UIKit

class FocusPresenter {

    static func showTrackingViewControllerIfNeeded() {
        FocusTracker.shared.showTrackingViewControllerIfNeeded()
    }

    static func startFocus(with timer: FocusTimerRepresentable) {
        FocusTracker.shared.startFocus(with: timer)
    }
    
    
    /// 显示时间线
    static func showTimeline() {
        let vc = FocusTimelineViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.show()
    }
    
    /// 手动添加记录
    static func addRecordManually() {
        let timerController = FocusUserTimerController()
        timerController.addRecordManually()
    }

    /// 显示已归档计时器
    static func showArchivedTimers() {
        let vc = FocusArchivedViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.show()
    }
    
    /// 显示记录
    static func showRecords(forTask task: TaskRepresentable? = nil,
                            timer: FocusTimer? = nil,
                            type: StatsType = .week,
                            date: Date = .now) {
        let vc = FocusRecordsViewController(task: task, timer: timer, type: type, date: date)
        let navController = UINavigationController(rootViewController: vc)
//        navController.modalPresentationStyle = .formSheet
        navController.show()
    }
    
    /// 总览视图控制器
    static func showOverallStatistics() {
        let vc = FocusStatsOverallViewController()
        let navController = UINavigationController(rootViewController: vc)
//        navController.modalPresentationStyle = .formSheet
        navController.show()
    }
    
    /// 特定计时器统计视图控制器
    static func showStatistics(for timer: FocusTimer) {
        let vc = FocusStatsTimerViewController(timer: timer)
        let navController = UINavigationController(rootViewController: vc)
//        navController.modalPresentationStyle = .formSheet
        navController.show()
    }
    
    /// 显示设置视图控制器
    static func showSettings() {
        let vc = FocusSettingViewController(style: .insetGrouped)
        let navController = UINavigationController(rootViewController: vc)
//        navController.modalPresentationStyle = .formSheet
        navController.show()
    }
    
    // MARK: - 记录相关操作
    /// 确认删除记录
    static func confirmRecordDeletion(completion: @escaping(Bool) -> Void) {
        let deleteAction = TPAlertAction(type: .destructive, title: resGetString("Delete")) { action in
            completion(true)
        }
        /// 在 dismiss 后处理回调
        deleteAction.handleBeforeDismiss = false
        
        let cancelAction = TPAlertAction(type: .cancel, title: resGetString("Cancel")) { action in
            completion(false)
        }
        
        let message = resGetString("Sure to delete this focus record?")
        let alertController = TPAlertController(title: resGetString("Delete Record"),
                                                message: message,
                                                actions: [cancelAction, deleteAction])
        alertController.show()
    }
    
    /// 编辑记录
    static func editRecord(for session: FocusSession,
                           completion: ((FocusRecord) -> Void)? = nil,
                           deletionHandler: ((FocusSession) -> Void)? = nil) {
        let record = session.editingRecord
        let vc = FocusRecordEditViewController(record: record, editType: .modify)
        vc.didEndEditing = { record in
            if let completion = completion {
                completion(record)
            } else {
                // 默认更新行为
                focus.updateSession(session, with: record)
            }
        }
        
        vc.didConfirmDeletion = {
            if let deletionHandler = deletionHandler {
                deletionHandler(session)
            } else {
                // 默认删除行为
                focus.deleteSession(session)
            }
        }
        
        let navController = UINavigationController(rootViewController: vc)
        navController.show()
    }
    
    /// 手动添加记录
    static func addRecordManually(forTimer timer: FocusTimerRepresentable? = nil,
                                  task: TaskRepresentable? = nil) {
        /// 绑定默认番茄钟
        let timer = timer ?? FocusSystemPomodoroTimer()
        let record = FocusRecord(timer: timer, task: task)
        let vc = FocusRecordEditViewController(record: record)
        vc.didEndEditing = { record in
            focus.addSession(with: record, isManual: true)
        }
        
        vc.showAsNavigationRoot()
    }
    
    /// 根据默认开始和结束时间创建记录
    static func createRecord(startTime: Date, endTime: Date) {
        let interval = endTime.timeIntervalSince(startTime)
        let recordDuration = FocusRecordDuration(type: .focus, interval: interval)
        let timeline = FocusRecordTimeline(startDate: startTime,
                                           recordDurations: [recordDuration])
        let timer = FocusSystemPomodoroTimer()
        let record = FocusRecord(timer: timer, timeline: timeline)
        let vc = FocusRecordEditViewController(record: record)
        vc.didEndEditing = { record in
            focus.addSession(with: record, isManual: true)
        }
        
        vc.showAsNavigationRoot()
    }
    
}
