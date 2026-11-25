//
//  WSHabitRecentContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation

// MARK: - 内容交互器

/// 习惯·小·最近三天的内容交互器。展示所选习惯最近三天的状态与进度。
class WSHabitRecentContentInteractor: WSHabitPeriodContentInteractor {
    
    /// 展示的天数
    static let dayCount = 3
    
    /// 展示的日期跨周时补取上一周，保证记录的完整
    override func fetchPeriods(containing date: Date) -> [HabitDatePeriod] {
        let currentPeriod = weekPeriod(containing: date)
        guard let earliestDate = displayDates(containing: date).first,
              !currentPeriod.contains(earliestDate) else {
            return [currentPeriod]
        }
        
        return [weekPeriod(containing: earliestDate), currentPeriod]
    }
    
    /// 截止当天的最近三天
    override func displayDates(containing date: Date) -> [Date] {
        return (0..<WSHabitRecentContentInteractor.dayCount).compactMap { offset in
            return date.dateByAddingDays(offset - WSHabitRecentContentInteractor.dayCount + 1)
        }
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：与周进度使用不同的示例习惯
    override func previewDataItem() -> WSPluginDataItem? {
        let subtitle = String(format: resGetString("%ld %@ per day"), 3, resGetString("Times"))
        return makePreviewDataItem(title: resGetString("Workout"),
                                   subtitle: subtitle,
                                   emoji: "🏃",
                                   color: Color(0xFF375F),
                                   samples: [
                                       WSHabitPeriodPreviewSample(status: .completed, progress: 1.0),
                                       WSHabitPeriodPreviewSample(status: .skipped("🤒"), reasonEmoji: "🤒"),
                                       WSHabitPeriodPreviewSample(status: .inProgress, progress: 0.7)
                                   ])
    }
}
