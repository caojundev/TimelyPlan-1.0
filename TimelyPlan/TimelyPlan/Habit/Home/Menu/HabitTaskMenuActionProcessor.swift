//
//  HabitTaskMenuActionProcessor.swift
//  iTimeFlow
//
//  Created by caojun on 2023/10/17.
//

import Foundation

class HabitTaskMenuActionProcessor {
    
    /// 任务操作管理器
    private let taskController = HabitTaskController()
    
    /// 记录操作控制器
    private let recordController = HabitRecordController()

    /// 创建新任务
    func createNewTask() {
        taskController.createNewTask()
    }
    
    /// 点击记录按钮
    func clickRecrod(for task: HabitTask, on date: Date) {
        recordController.clickRecrod(for: task, on: date)
    }
    
    /// 执行菜单操作
    func performMenuAction(_ type: HabitTaskMenuActionType,
                           for task: HabitTask,
                           on date: Date,
                           with record: HabitRecord?,
                           from sourceView: UIView? = nil) {
        switch type {
        case .resetToday:
            recordController.resetToday(of: date, for: task)
        case .checkin:
            recordController.completeAll(for: task, on: date)
        case .cancelSkip:
            recordController.cancelSkip(for: task, on: date)
        case .completeAll:
            recordController.completeAll(for: task, on: date)
        case .addRecord:
            recordController.recordManually(for: task, on: date)
        case .markAsFail:
            recordController.markAsFail(for: task, on: date, from: sourceView)
        case .cancelFail:
            recordController.cancelFail(for: task, on: date)
        case .skipToday:
            recordController.skipToday(for: task, on: date, from: sourceView)
        case .editLog:
            recordController.editLog(record?.logInfo, for: task, on: date)
        case .edit:
            taskController.editTask(task)
        case .delete:
            taskController.deleteTask(task)
        case .archive:
            taskController.archiveTask(task)
        case .unarchive:
            taskController.unarchiveTask(task)
        }
    }
}
