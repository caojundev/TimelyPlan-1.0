//
//  WSHabitTaskDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/26.
//

import Foundation
import UIKit

// MARK: - 数据条目

/// 习惯任务组件中的单个习惯任务数据。
///
/// 展示字段与习惯列表一致：图标、名称、完成详情、进度与状态。
/// 只持有任务标识与日期，交互时再据此读取最新的任务，避免持有过期快照。
class WSHabitTaskDataItem: NSObject, WSPluginDataItem {
    
    /// 习惯任务唯一标识
    let taskIdentifier: String
    
    /// 展示日期
    let date: Date
    
    /// 任务名称
    let title: String
    
    /// 任务详情，与习惯列表一致：完成量 / 目标量
    let subtitle: TextRepresentable?
    
    /// 任务颜色
    let color: UIColor
    
    /// 任务图标
    let icon: TPIcon
    
    /// 当日完成进度
    let progress: CGFloat
    
    /// 当日任务状态
    let status: HabitTaskStatus
    
    init(taskIdentifier: String,
         date: Date,
         title: String,
         subtitle: TextRepresentable?,
         color: UIColor,
         icon: TPIcon,
         progress: CGFloat,
         status: HabitTaskStatus) {
        self.taskIdentifier = taskIdentifier
        self.date = date
        self.title = title
        self.subtitle = subtitle
        self.color = color
        self.icon = icon
        self.progress = progress
        self.status = status
        super.init()
    }
    
    /// 由习惯时间段的条目生成展示数据
    convenience init(periodItem: HabitPeriodItem) {
        let task = periodItem.habitTask
        let date = periodItem.period.date
        let record = periodItem.record(on: date)
        
        self.init(taskIdentifier: task.identifier,
                  date: date,
                  title: task.displayName,
                  subtitle: WSHabitTaskDataItem.detail(for: task, on: date, with: record),
                  color: task.color,
                  icon: task.icon,
                  progress: periodItem.progress(on: date),
                  status: periodItem.status(on: date))
    }
    
    /// 详情文本，与习惯列表的副标题保持一致
    private static func detail(for task: HabitTask,
                               on date: Date,
                               with record: HabitRecord?) -> TextRepresentable {
        guard task.isScheduled(on: date) else {
            /// 非计划日：优先提示下一计划日，日期换行展示
            if let nextDate = task.nextPlanDate(from: date) {
                let nextDateString = nextDate.yearMonthDayString(omitYear: true)
                return String(format: resGetString("Next Planned Date %@"), nextDateString)
            }
            
            return resGetString("Not a Scheduled Day")
        }
        
        /// 返回进度
        let provider = HabitTaskDetailProvider(option: [.progress])
        return provider.detail(for: task, on: date, with: record, color: .secondaryLabel)
    }
}

// MARK: - 列表数据条目

/// 习惯任务组件的列表数据。
class WSHabitTasksDataItem: NSObject, WSPluginDataItem {
    
    /// 待展示的习惯任务，按展示顺序排列
    let items: [WSHabitTaskDataItem]
    
    init(items: [WSHabitTaskDataItem]) {
        self.items = items
        super.init()
    }
}
