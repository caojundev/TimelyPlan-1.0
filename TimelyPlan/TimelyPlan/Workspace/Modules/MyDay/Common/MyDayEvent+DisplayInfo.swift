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
            return (sourceItem as? TodoTask)?.displayName ?? title
        case .focus:
            return (sourceItem as? FocusTimer)?.displayName ?? title
        case .habit:
            return (sourceItem as? HabitTask)?.displayName ?? title
        case .goal:
            return (sourceItem as? GoalTask)?.name ?? title
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
    
    /// 预览用的来源对象。仅倒数日需要真实对象提供表情，其余来源使用占位，
    /// 由 `sourceIcon` 与 `displayTitle` 按来源回退到类型图标与事项名称
    static func previewSourceItem(for source: MyDayEventSource,
                                  title: String,
                                  color: UIColor,
                                  date: Date) -> Any {
        guard source == .countdown else {
            return NSNull()
        }
        
        return CountdownEvent(type: .anniversary,
                              name: title,
                              emoji: "💍",
                              colorHex: color.hexString,
                              date: CountdownDate(targetDate: date),
                              timeUnit: .days)
    }
}
