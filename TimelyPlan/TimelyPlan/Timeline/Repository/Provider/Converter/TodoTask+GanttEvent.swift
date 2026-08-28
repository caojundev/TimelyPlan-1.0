//
//  TodoTask+GanttEvent.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/16.
//

import Foundation

extension TodoTask {
    
    func toGanttEvent() -> GanttTask? {
        guard let dateInfo = schedule?.dateInfo else {
            return nil
        }

        let color = priority.color
        let event = GanttTask(id: identifier,
                              name: displayName,
                              startDate: dateInfo.startDate,
                              endDate: dateInfo.endDate,
                              progress: completionProgress,
                              color: color)
        return event
    }
}

// MARK: - Array 扩展
extension Array where Element == TodoTask {
    
    func toGanttEvents() -> [GanttTask] {
        return compactMap { $0.toGanttEvent() }
    }
}
