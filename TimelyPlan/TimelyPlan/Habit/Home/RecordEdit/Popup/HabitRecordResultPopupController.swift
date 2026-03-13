//
//  HabitRecordResultPopupController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/13.
//

import Foundation
import UIKit

class HabitRecordResultPopupController: HabitRecordProcessorDelegate {
    
    func didUpdateHabitRecord(_ record: HabitRecord, for task: HabitTask, on date: Date, with change: HabitRecordChange) {
        var shouldShow: Bool = false
        switch change {
        case .amountChanged(_, let newValue):
            shouldShow = newValue >= task.goal.validatedTargetAmount
        case .failChanged(_, let newValue):
            shouldShow = newValue
        case .skipChanged(_, let newValue):
            shouldShow = newValue
        default:
            break
        }
        
        guard shouldShow else {
            return
        }
        
        let infoView = HabitRecordResultInfoView()
        TPCustomPopupQueue.common.showCustomView(infoView,
                                                 onView: nil,
                                                 position: .bottom,
                                                 duration: 2.0)
        
//        let vc = HabitRecordLogEditViewController(logInfo: record.logInfo, date: date)
//        vc.didEndEditing = { logInfo in
//            habit.addLog(logInfo, for: task, on: date)
//        }
//
//        self.logViewController = vc
//        vc.showAsNavigationRoot()
    }
}
