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
            FocusRepository.createTimer(with: editingTimer, in: timers)
        }

        vc.showAsNavigationRoot()
    }
    
    func createTimer() {
        let vc = FocusTimerEditViewController(timer: nil)
        vc.didEndEditing = { editingTimer in
            FocusRepository.createTimer(with: editingTimer)
        }

        vc.showAsNavigationRoot()
    }

    /// 编辑计时器
    func editTimer(_ timer: FocusTimer){
        let vc = FocusTimerEditViewController(timer: timer.editingTimer)
        vc.didEndEditing = { editingTimer in
            FocusRepository.updateTimer(timer, with: editingTimer)
        }

        let navController = UINavigationController(rootViewController: vc)
        navController.show()
    }
    
    /// 归档计时器
    func archiveTimer(_ timer: FocusTimer){
        FocusRepository.setArchived(true, for: timer)
    }
     
    func unarchiveTimer(_ timer: FocusTimer){
        FocusRepository.setArchived(false, for: timer)
    }

    /// 弹窗确认删除计时器
    func deleteTimer(_ timer: FocusTimer){
        let deleteAction = TPAlertAction(type: .destructive,
                                         title: resGetString("Delete")) { action in
            FocusRepository.deleteTimer(timer)
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

    func moveTimerToTop(_ timer: FocusTimer) {
        FocusRepository.moveTimer(timer, toTop: true)
    }
    
    func moveTimerToBottom(_ timer: FocusTimer) {
        FocusRepository.moveTimer(timer, toTop: false)
    }
    
    func addTimerToMyDay(_ timer: FocusTimer) {
        var editingTimer = timer.editingTimer
        editingTimer.isAddedToMyDay = true
        var shouldUpdateDate = false
        if editingTimer.startDate == nil {
            shouldUpdateDate = true
        }

        let now = Date()
        if !shouldUpdateDate, let endDate = editingTimer.endDate, endDate < now {
            shouldUpdateDate = true
        }
       
        if shouldUpdateDate {
            editingTimer.startDate = now
            editingTimer.endDate = nil
        }
        
        if editingTimer.timePlan == nil {
            editingTimer.timePlan = HabitTimePlan()
        }
        
        FocusRepository.updateTimer(timer, with: editingTimer)
    }

    func removeTimerFromMyDay(_ timer: FocusTimer) {
        var editingTimer = timer.editingTimer
        editingTimer.isAddedToMyDay = false
        FocusRepository.updateTimer(timer, with: editingTimer)
    }
    
    
    // MARK: - 任务记录操作
    func addRecordManually(forTimer timer: FocusTimerRepresentable? = nil, task: TaskRepresentable? = nil) {
        FocusPresenter.addRecordManually(forTimer: timer, task: task)
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
