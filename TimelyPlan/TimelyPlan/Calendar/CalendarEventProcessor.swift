//
//  CalendarEventProcessor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/23.
//

import Foundation
import EventKit

class CalendarEventProcessor {
    
    private let repository = CalendarRepository()
    
    /// 更新事项日期
    func updateEvent(_ event: CalendarEvent, with dateRange: DateInterval, completion: @escaping ((Bool) -> Void)) {
        switch event.source {
        case .system:
            updateSystemEvent(event, with: dateRange, completion: completion)
        case .todo:
            updateTodoEvent(event, with: dateRange, completion: completion)
        case .habit:
            break
        }
    }
    
    private func updateTodoEvent(_ event: CalendarEvent, with dateRange: DateInterval, completion: @escaping ((Bool) -> Void)) {
        repository.updateTodoEvent(event, with: dateRange)
        completion(true)
    }
    
    private func updateSystemEvent(_ event: CalendarEvent, with dateRange: DateInterval, completion: @escaping ((Bool) -> Void)) {
        guard let ekEvent = event.sourceItem as? EKEvent else {
            completion(false)
            return
        }
        
        CalendarSystemManager.shared.updateEventWithConfirmation(ekEvent, with: dateRange) { result in
            switch result {
            case .success:
                debugPrint("事项更新成功")
                completion(true)
            case .failure(let error):
                debugPrint("事项更新失败: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    /// 点击事项
    func clickEvent(_ event: CalendarEvent) {
        switch event.source {
        case .system:
            previewSystemEvent(event)
        case .todo:
            clickTodoEvent(event)
        case .habit:
            clickHabitEvent(event)
        }
    }
    
    /// 预览系统事项
    private func previewSystemEvent(_ event: CalendarEvent) {
        guard let _ = event.sourceItem as? EKEvent else {
            return
        }
        
        CalendarPresenter.previewEvent(event)
    }
    
    /// 编辑待办
    private func clickTodoEvent(_ event: CalendarEvent) {
        guard let task = event.sourceItem as? TodoTask else {
            return
        }
        
        if task.isDetached {
            CalendarPresenter.previewEvent(event)
        } else {
            CalendarPresenter.editTodoEvent(event)
        }
    }
    
    /// 点击习惯
    private func clickHabitEvent(_ event: CalendarEvent) {
        if event.startDate.isToday {
            CalendarPresenter.editHabitEvent(event)
        } else {
            CalendarPresenter.previewEvent(event)
        }
    }
    
}
