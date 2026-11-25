//
//  MyDayEvent+SourceIcon.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation

// MARK: - 事项来源图标

extension MyDayEvent {
    
    /// 事项来源图标，与 `MyDayTimelineView` 中各来源节点的图标一致
    var sourceIcon: TPIcon? {
        switch source {
        case .calendar:
            return TPIcon(name: "myDay_calendar_24")
        case .todo:
            return TPIcon(name: isCompleted ? "todo_circle_completed_24" : "todo_circle_normal_24")
        case .habit:
            guard let task = sourceItem as? HabitTask else {
                return TPIcon(name: "task_type_habit_24")
            }
            
            return task.icon
        case .goal:
            return TPIcon(name: "goal_24")
        case .focus:
            guard let timer = sourceItem as? FocusTimer,
                  let iconName = timer.timerType.iconName else {
                return TPIcon(name: "focus_24")
            }
            
            return TPIcon(name: iconName)
        case .countdown:
            guard let event = sourceItem as? CountdownEvent else {
                return nil
            }
            
            return TPIcon(text: event.emoji ?? event.type.emoji)
        }
    }
}
