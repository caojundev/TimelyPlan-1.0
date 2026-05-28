//
//  CalendarEventProcessor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/23.
//

import Foundation

class CalendarEventProcessor {
    
    private let repository = CalendarRepository()
    
    /// 编辑事项
    func editEvent(_ event: CalendarEvent) {
        guard event.source == .local, let task = event.sourceItem as? TodoTask else {
            return
        }
        
        let taskController = TodoTaskController()
        taskController.editTask(task)
    }
    
    /// 更新事项日期
    func updateEvent(_ event: CalendarEvent, with dateRange: DateInterval) {
        repository.updateEvent(event, with: dateRange)
    }

}
