//
//  FocusUserTimerController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/27.
//

import Foundation

class FocusUserTimerController {
    
    /// 创建新计时器
    func createTimer(in timers: [FocusTimer]?) {
        let vc = FocusTimerEditViewController(timer: nil)
        vc.didEndEditing = { editingTimer in
            focus.createTimer(with: editingTimer, in: timers)
        }

        let navController = UINavigationController(rootViewController: vc)
//        navController.modalPresentationStyle = .formSheet
        navController.show()
    }

    /// 编辑计时器
    func editTimer(_ timer: FocusTimer){
        let vc = FocusTimerEditViewController(timer: timer.editingTimer)
        vc.didEndEditing = { editingTimer in
            focus.updateTimer(timer, with: editingTimer)
        }

        let navController = UINavigationController(rootViewController: vc)
//        navController.modalPresentationStyle = .formSheet
        navController.show()
    }
    
    /// 归档计时器
    func archiveTimer(_ timer: FocusTimer){
        focus.setArchived(true, for: timer)
    }
     
    func unarchiveTimer(_ timer: FocusTimer){
        focus.setArchived(false, for: timer)
    }

    /// 弹窗确认删除计时器
    func deleteTimer(_ timer: FocusTimer){
        let deleteAction = TPAlertAction(type: .destructive,
                                         title: resGetString("Delete")) { action in
            focus.deleteTimer(timer)
        }
        
        let cancelAction = TPAlertAction(type: .cancel,
                                         title: resGetString("Cancel"))
        
        let format: String = resGetString("\"%@\" will be permanently deleted.")
        let message = String(format: format, timer.name ?? "Untitled")
        let alertController = TPAlertController(title: resGetString("Delete Timer"),
                                                message: message,
                                                actions: [cancelAction, deleteAction])
        alertController.show()
    }

    func moveTimerToTop(_ timer: FocusTimer, in timers: [FocusTimer]) {
        focus.moveTimer(timer, in: timers, toTop: true)
    }
    
    func moveTimerToBottom(_ timer: FocusTimer, in timers: [FocusTimer]) {
        focus.moveTimer(timer, in: timers, toTop: false)
    }
    
    // MARK: - 任务记录操作
    func addRecordManually(forTimer timer: FocusTimerRepresentable? = nil, task: TaskRepresentable? = nil) {
        let timer = timer ?? focus.defaultTimer()
        let record = FocusRecord(timer: timer, task: task)
        let vc = FocusRecordEditViewController(record: record)
        vc.didEndEditing = { record in
            focus.addSession(with: record, isManual: true)
        }
        
        let navController = UINavigationController(rootViewController: vc)
        navController.show()
    }
    
    /// 显示记录
    func showRecords(forTimer timer: FocusTimer? = nil,
                     type: StatsType = .week,
                     date: Date = .now) {
        FocusPresenter.showRecords(forTask: nil, timer: timer, type: type, date: date)
    }
    
    func showStatistics(forTimer timer: FocusTimer) {
        FocusPresenter.showStatistics(for: timer)
    }
    
    
}
