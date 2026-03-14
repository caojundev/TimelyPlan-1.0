//
//  HabitRecordResultPopupController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/13.
//

import Foundation
import UIKit

class HabitRecordResultPopupController: HabitRecordProcessorDelegate {
    
    private let recordController = HabitRecordController()
    
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
        
        let infoView = HabitRecordResultInfoView(task: task, record: record, date: date)
        infoView.didClickLog = { [weak self] in
            guard let self = self else { return }
            self.recordController.editLog(for: task, with: record, on: date)
        }
        
        TPCustomPopupQueue.common.showCustomView(infoView,
                                                 onView: nil,
                                                 position: .bottom,
                                                 duration: 4.0)
    }
}
