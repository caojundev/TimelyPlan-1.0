//
//  WSHabitDayDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation
import UIKit

// MARK: - 天数据

/// 天进度视图的展示数据。
class WSHabitDayDataItem: NSObject {
    
    /// 对应日期
    let date: Date
    
    /// 星期文案。仅在展示需要时取值，不需要展示的用途不必为此做一次格式化
    lazy var weekdayText: String = date.shortWeekdaySymbol()
    
    /// 日期数字
    lazy var dayNumberText: String = "\(date.day)"
    
    /// 是否计划日
    let isScheduled: Bool
    
    /// 是否为未来日期
    let isFuture: Bool
    
    /// 当日状态
    let status: HabitTaskStatus
    
    /// 当日进度
    let progress: CGFloat
    
    /// 进度颜色
    let color: UIColor
    
    /// 跳过或失败原因的 emoji
    let reasonEmoji: String?
    
    init(date: Date,
         isScheduled: Bool,
         status: HabitTaskStatus,
         progress: CGFloat,
         color: UIColor,
         reasonEmoji: String?) {
        self.date = date
        self.isScheduled = isScheduled
        self.isFuture = date.isFutureDay
        self.status = status
        self.progress = progress
        self.color = color
        self.reasonEmoji = reasonEmoji
        super.init()
    }
}

// MARK: - 构造

extension WSHabitDayDataItem {
    
    /// 由时间段条目生成每天的展示数据
    static func items(from periodItem: HabitPeriodItem, dates: [Date]) -> [WSHabitDayDataItem] {
        let color = periodItem.habitTask.color
        return dates.map { date in
            let status = periodItem.status(on: date)
            
            return WSHabitDayDataItem(date: date,
                                      isScheduled: periodItem.isScheduledDate(date),
                                      status: status,
                                      progress: periodItem.progress(on: date),
                                      color: color,
                                      reasonEmoji: reasonEmoji(for: status))
        }
    }
    
    /// 跳过或失败原因的 emoji
    private static func reasonEmoji(for status: HabitTaskStatus) -> String? {
        switch status {
        case .skipped(let reason), .failed(let reason):
            return reason?.first.map { String($0) }
        default:
            return nil
        }
    }
}
