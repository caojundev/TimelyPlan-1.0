//
//  MyDayEvent+DisplayInfo.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit
import EventKit

// MARK: - 事项展示文案

extension MyDayEvent {
    
    /// 展示标题：与 `MyDayTimelineView` 中对应事项单元格的名称一致
    var displayTitle: String? {
        switch source {
        case .calendar:
            return title
        case .todo:
            return (sourceItem as? TodoTask)?.displayName
        case .focus:
            return (sourceItem as? FocusTimer)?.displayName
        case .habit:
            return (sourceItem as? HabitTask)?.displayName
        case .goal:
            return (sourceItem as? GoalTask)?.name
        case .countdown:
            return title ?? (sourceItem as? CountdownEvent)?.displayName
        }
    }
    
    /// 展示副标题：与 `MyDayTimelineView` 中对应事项单元格的详情一致
    var displaySubtitle: TextRepresentable? {
        switch source {
        case .calendar:
            guard let ekEvent = sourceItem as? EKEvent else {
                return nil
            }
            
            var components: [ASAttributedString] = [ekEvent.calendar.title.attributedString]
            if ekEvent.hasRecurrenceRules, let image = resGetImage("myDay_repeat_24") {
                components.append(.string(image: image, imageSize: .size(4), imageColor: .secondaryLabel))
            }
            
            return components.joined(separator: " • ")
        case .todo:
            guard let task = sourceItem as? TodoTask else {
                return nil
            }
            
            let option: TodoTaskDetailOption = [.schedule, .step, .progress, .tag, .list, .note]
            return TodoTaskDetailProvider(task: task, option: option).attributedInfo()
        case .focus:
            return (sourceItem as? FocusTimer)?.timerDescription
        case .habit:
            guard let task = sourceItem as? HabitTask else {
                return nil
            }
            
            return task.goal.targetDescription.attributedString
        case .goal:
            guard let task = sourceItem as? GoalTask else {
                return nil
            }
            
            return GoalTaskDetailProvider(task: task, option: .allExceptMyDay).attributedInfo()
        case .countdown:
            guard let countdownEvent = sourceItem as? CountdownEvent else {
                return nil
            }
            
            return countdownEvent.myDayDetail(on: startDate)
        }
    }
}
