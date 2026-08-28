//
//  GanttEventProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/16.
//

import Foundation

protocol GanttEventProvider {
    
    /// 获取特定日期范围的事项
    func fetchGanttEvents(in range: DateInterval, completion: @escaping([GanttTask]?) -> Void)
}

class GanttTodoEventProvider: GanttEventProvider {
    func fetchGanttEvents(in range: DateInterval, completion: @escaping ([GanttTask]?) -> Void) {
        guard MyDaySetting.shared.showTodo else {
            completion(nil)
            return
        }
        
        TodoRepository.fetchGanttEventTasks(in: range,
                                            showCompleted: true) { tasks in
            completion(tasks?.toGanttEvents())
        }
    }
}
