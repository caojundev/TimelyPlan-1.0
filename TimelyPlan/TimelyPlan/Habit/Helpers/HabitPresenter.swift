//
//  HabitPresenter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/28.
//

import Foundation

class HabitPresenter {
    /// 显示记录
    static func showRecords() {
        let vc = HabitRecordsViewController()
        vc.showAsNavigationRoot()
    }
    
    /// 显示报告
    static func showReport() {
        let vc = HabitReportMainViewController()
        vc.showAsNavigationRoot()
    }
    
    /// 显示统计
    static func showStats(for task: HabitTask, date: Date = .now) {
        let vc = HabitStatsMainViewController(task: task, type: .month, date: date)
        vc.showAsNavigationRoot()
    }
    
    /// 显示习惯管理视图控制器
    static func manageHabits(menuType: HabitManageListType = .active) {
        let vc = HabitManageMainViewController(menuType: menuType)
        vc.showAsNavigationRoot()
    }
    
    /// 创建新习惯
    static func createNewHabitTask() {
        let vc = HabitTaskEditViewController(task: nil)
        vc.didEndEditing = { editingTask in
            HabitRepository.createTask(with: editingTask)
        }
        
        vc.showAsNavigationRoot()
    }
    
    /// 编辑习惯
    static func editHabitTask(_ task: HabitTask) {
        let vc = HabitTaskEditViewController(task: task.editingTask)
        vc.didEndEditing = { editingTask in
            HabitRepository.updateTask(task, with: editingTask)
        }
        
        vc.showAsNavigationRoot()
    }
    
    /// 显示设置视图控制器
    static func showSettings() {
        let vc = HabitSettingViewController()
        vc.showAsNavigationRoot()
    }
    
    static func showNotScheduledDayMessage(for date: Date) {
        let dateString = date.yearMonthDayString(omitYear: true)
        let format = resGetString("%@ is not a scheduled day")
        let message = String(format: format, dateString)
        TPFeedbackQueue.common.postFeedback(text: message,
                                            onView: nil,
                                            position: .top,
                                            isOmission: false)
    }
    
    // MARK: - 记录相关操作
    /// 确认删除记录
    static func confirmRecordDeletion(completion: @escaping(Bool) -> Void) {
        let title = resGetString("Delete Record")
        let message = resGetString("Sure to delete this habit record?")
        confirmDeletion(title: title, message: message, completion: completion)
    }

    /// 确认删除某天记录
    static func confirmDayRecordsDeletion(on date: Date,
                                          completion: @escaping(Bool) -> Void) {
        let title = resGetString("Delete Day Records")
        let messageFormat = resGetString("All records will be removed for %@. Are you sure to delete records?")
        let message = String(format: messageFormat, date.yearMonthDayString(omitYear: true))
        confirmDeletion(title: title, message: message, completion: completion)
    }
    
    /// 确认删除周记录
    static func confirmWeekRecordsDeletion(contains date: Date,
                                           firstWeekday: Weekday,
                                           completion: @escaping(Bool) -> Void) {
        let dateRange = date.rangeOfThisWeek(firstWeekday: firstWeekday)
        guard let startDate = dateRange.startDate, let endDate = dateRange.endDate else {
            completion(false)
            return
        }

        let title = resGetString("Delete Week Records")
        let messageFormat = resGetString("All records will be removed from %@ to %@. Are you sure to delete records?")
        let startDateString = startDate.yearMonthDayString(omitYear: true, showRelativeDate: false)
        let endDateString = endDate.yearMonthDayString(omitYear: true, showRelativeDate: false)
        let message = String(format: messageFormat, startDateString, endDateString)
        confirmDeletion(title: title, message: message, completion: completion)
    }
    
    /// 确认删除月记录
    static func confirmMonthRecordsDeletion(contains date: Date,
                                            completion: @escaping(Bool) -> Void) {
        let dateRange = date.rangeOfThisMonth()
        guard let startDate = dateRange.startDate, let endDate = dateRange.endDate else {
            completion(false)
            return
        }

        let title = resGetString("Delete Month Records")
        let messageFormat = resGetString("All records will be removed from %@ to %@. Are you sure to delete records?")
        let startDateString = startDate.yearMonthDayString(omitYear: true, showRelativeDate: false)
        let endDateString = endDate.yearMonthDayString(omitYear: true, showRelativeDate: false)
        let message = String(format: messageFormat, startDateString, endDateString)
        confirmDeletion(title: title, message: message, completion: completion)
    }
    
    /// 确认删除记录
    private static func confirmDeletion(title: String?,
                                        message: String?,
                                        completion: @escaping(Bool) -> Void) {
        let deleteAction = TPAlertAction(type: .destructive, title: resGetString("Delete")) { action in
            completion(true)
        }
        
        /// 在 dismiss 后处理回调
        deleteAction.handleBeforeDismiss = false
        
        let cancelAction = TPAlertAction(type: .cancel, title: resGetString("Cancel")) { action in
            completion(false)
        }
        
        let alertController = TPAlertController(title: title,
                                                message: message,
                                                actions: [cancelAction, deleteAction])
        alertController.show()
    }
}
