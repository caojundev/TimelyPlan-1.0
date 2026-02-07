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
        let vc = FocusSettingsViewController(style: .insetGrouped)
        let navController = UINavigationController(rootViewController: vc)
//        navController.modalPresentationStyle = .formSheet
        navController.show()
    }
}
