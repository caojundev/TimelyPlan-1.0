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
    func updateEvent(_ event: CalendarEvent, with dateRange: DateInterval) {
        repository.updateEvent(event, with: dateRange)
    }
    
    func clickEvent(_ event: CalendarEvent) {
        switch event.source {
        case .local:
            editLocalEvent(event)
        case .system:
            previewSystemEvent(event)
        }
    }
    
    /// 编辑本地事项
    private func editLocalEvent(_ event: CalendarEvent) {
        guard let task = event.sourceItem as? TodoTask else {
            return
        }
        
                   let taskController = TodoTaskController()
        taskController.editTask(task)
    }
    
    /// 预览系统事项
    private func previewSystemEvent(_ event: CalendarEvent) {
        guard let _ = event.sourceItem as? EKEvent else {
            return
        }
        
        CalendarPresenter.previewEvent(event)
    }
    
}
