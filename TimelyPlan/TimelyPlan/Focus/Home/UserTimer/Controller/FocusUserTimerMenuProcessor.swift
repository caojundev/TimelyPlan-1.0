//
//  FocusUserTimerMenuProcessor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/24.
//

import Foundation

class FocusUserTimerMenuProcessor {
    
    func performMenuAction(_ type: FocusUserTimerMenuType, for timer: FocusTimer) {
        let timerController = FocusUserTimerController()
        switch type {
        case .statistics:
            timerController.showStatistics(forTimer: timer)
        case .viewRecord:
            timerController.showRecords(forTimer: timer)
        case .addRecord:
            timerController.addRecordManually(forTimer: timer)
        case .moveToTop:
            timerController.moveTimerToTop(timer)
        case .moveToBottom:
            timerController.moveTimerToBottom(timer)
        case .edit:
            timerController.editTimer(timer)
        case .archive:
            timerController.archiveTimer(timer)
        case .unarchive:
            timerController.unarchiveTimer(timer)
        case .delete:
            timerController.deleteTimer(timer)
        case .addToMyDay:
            timerController.addTimerToMyDay(timer)
        case .removeFromMyDay:
            timerController.removeTimerFromMyDay(timer)
        }
    }
}
