//
//  HabitRecordPopupManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/13.
//

import Foundation
import UIKit

class HabitRecordPopupManager: HabitRecordProcessorDelegate {

    enum PopupType {
        case progress /// 进度
        case result   /// 结果
    }
    
    static let shared = HabitRecordPopupManager()
    
    private let recordController = HabitRecordController()
    
    func startObserving() {
        HabitRepository.addUpdater(self, for: [.record])
    }
    
    func didUpdateHabitRecord(_ record: HabitRecord, for task: HabitTask, on date: Date, with change: HabitRecordChange) {
        var popupType: PopupType?
        switch change {
        case .amountChanged(_, let newValue):
            if newValue >= task.goal.validatedTargetAmount {
                popupType = .result
            } else {
                popupType = .progress
            }
        case .failChanged(_, let newValue):
            popupType = newValue ? .result : nil
        case .skipChanged(_, let newValue):
            popupType = newValue ? .result : nil
        default:
            break
        }
        
        guard let popupType = popupType else {
            return
        }

        switch popupType {
        case .progress:
            popupProgress(task: task, record: record, change: change, date: date)
        case .result:
            popupResult(task: task, record: record, date: date)
        }
    }
    
    /// 显示习惯记录结果
    private func popupProgress(task: HabitTask,
                               record: HabitRecord,
                               change: HabitRecordChange,
                               date: Date) {
        let infoView = HabitRecordProgressInfoView(task: task, record: record, change: change, date: date)
        TPCustomPopupQueue.common.showCustomView(infoView,
                                                 onView: nil,
                                                 position: .bottom,
                                                 duration: 2.0)
    }
    
    /// 显示习惯记录结果
    private func popupResult(task: HabitTask, record: HabitRecord, date: Date) {
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
