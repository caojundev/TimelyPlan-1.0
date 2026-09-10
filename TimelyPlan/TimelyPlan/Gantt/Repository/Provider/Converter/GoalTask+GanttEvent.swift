//
//  GoalTask+GanttEvent.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/10.
//

import Foundation

extension GoalTask {
    
    func toGanttEvent() -> GanttEvent? {
        guard let startDate = startDate else {
            return nil
        }
        
        /// 无结束日期时按单日展示
        let endDate = endDate ?? startDate.endOfDay()
        guard endDate >= startDate else {
            return nil
        }
        
        let event = GanttEvent(id: identifier,
                               name: displayName,
                               startDate: startDate,
                               endDate: endDate,
                               progress: CGFloat(progressFraction),
                               color: color ?? Self.defaultColor,
                               source: .goal,
                               sourceItem: self)
        return event
    }
}

// MARK: - Array 扩展
extension Array where Element == GoalTask {
    
    func toGanttEvents() -> [GanttEvent] {
        return compactMap { $0.toGanttEvent() }
    }
}
