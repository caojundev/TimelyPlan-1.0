//
//  GanttEventProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/16.
//

import Foundation

protocol GanttEventProvider {
    
    /// 获取特定日期范围的事项
    func fetchGanttEvents(in range: DateInterval, completion: @escaping([GanttEvent]?) -> Void)
}

class GanttTodoEventProvider: GanttEventProvider {
    func fetchGanttEvents(in range: DateInterval, completion: @escaping ([GanttEvent]?) -> Void) {
        guard GanttSetting.shared.showTodo else {
            completion(nil)
            return
        }
        
        let showCompleted = GanttSetting.shared.showCompleted
        TodoRepository.fetchGanttEventTasks(in: range, showCompleted: showCompleted) { tasks in
            completion(tasks?.toGanttEvents())
        }
    }
}
