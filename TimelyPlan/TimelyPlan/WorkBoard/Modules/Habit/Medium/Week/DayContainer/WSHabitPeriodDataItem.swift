//
//  WSHabitPeriodDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation
import UIKit

// MARK: - 数据条目

/// 习惯的时间段数据条目：一个任务在若干天内的展示数据。
///
/// 天数由 `days` 决定，周进度、最近 3 天等插件都可复用。
class WSHabitPeriodDataItem: NSObject, WSPluginDataItem {
    
    /// 习惯任务唯一标识
    let taskIdentifier: String
    
    /// 任务名称
    let title: String
    
    /// 任务目标描述
    let subtitle: TextRepresentable?
    
    /// 任务图标
    let icon: TPIcon
    
    /// 任务颜色
    let color: UIColor
    
    /// 每天的展示数据
    let days: [WSHabitDayDataItem]
    
    init(taskIdentifier: String,
         title: String,
         subtitle: TextRepresentable?,
         icon: TPIcon,
         color: UIColor,
         days: [WSHabitDayDataItem]) {
        self.taskIdentifier = taskIdentifier
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
        self.days = days
        super.init()
    }
    
    /// 由习惯时间段条目与要展示的天生成展示数据
    convenience init(periodItem: HabitPeriodItem, days: [WSHabitDayDataItem]) {
        let task = periodItem.habitTask
        self.init(taskIdentifier: task.identifier,
                  title: task.displayName,
                  subtitle: task.goal.targetDescription,
                  icon: task.icon,
                  color: task.color,
                  days: days)
    }
}

// MARK: - 列表数据条目

/// 习惯时间段组件的列表数据：每个时间段代表一行。
class WSHabitPeriodsDataItem: NSObject, WSPluginDataItem {
    
    /// 待展示的时间段数据，按展示顺序排列
    let items: [WSHabitPeriodDataItem]
    
    init(items: [WSHabitPeriodDataItem]) {
        self.items = items
        super.init()
    }
}
