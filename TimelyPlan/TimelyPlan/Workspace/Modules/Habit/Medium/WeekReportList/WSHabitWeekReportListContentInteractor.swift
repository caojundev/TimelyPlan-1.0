//
//  WSHabitWeekReportListContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation

// MARK: - 内容交互器

/// 习惯周报告列表的内容交互器。
///
/// 读取今日排期习惯的整周记录，每个习惯一行下发给内容视图；
/// 任务与记录变化时重新取数，跨天刷新由基类的零点监听统一处理。
class WSHabitWeekReportListContentInteractor: WSHabitPluginContentInteractor {
    
    /// 最多展示的习惯数目
    private let maximumItemCount: Int
    
    init(plugin: WSPlugin, context: WSPluginContext, maximumItemCount: Int) {
        self.maximumItemCount = maximumItemCount
        super.init(plugin: plugin, context: context)
    }
    
    // MARK: - 取数
    /// 读取本周时间段的记录，只保留今日仍有排期的习惯
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let date = Date()
        let period = HabitDatePeriod(date: date,
                                     mode: .week,
                                     firstWeekday: HabitSetting.shared.firstWeekday)
        HabitRepository.fetchScheduledPeriodItems(in: period, includeSamples: false) { [weak self] periodItems in
            guard let self = self else {
                completion(nil)
                return
            }
            
            let periodItems = self.sortedPeriodItems(periodItems.filter { $0.isScheduledDate(date) }, on: date)
            guard !periodItems.isEmpty else {
                /// 没有可展示的任务时交给空白内容视图
                completion(nil)
                return
            }
            
            let dates = period.weekDaysPeriods().map { $0.date }
            let items = periodItems.prefix(self.maximumItemCount).map { periodItem in
                return WSHabitPeriodDataItem(periodItem: periodItem,
                                             days: WSHabitDayDataItem.items(from: periodItem, dates: dates))
            }
            completion(WSHabitPeriodsDataItem(items: items))
        }
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：固定展示几个示例习惯的一周进度，行数与真实展示一致
    override func previewDataItem() -> WSPluginDataItem? {
        let examples: [WSHabitWeekReportPreview] = [
            WSHabitWeekReportPreview(title: resGetString("Workout"),
                                     emoji: "🏃",
                                     colorHex: 0xFF375F),
            WSHabitWeekReportPreview(title: resGetString("Meditation"),
                                     emoji: "🧘",
                                     colorHex: 0xAF52DE),
            WSHabitWeekReportPreview(title: resGetString("Study"),
                                     emoji: "📚",
                                     colorHex: 0x0A84FF),
            WSHabitWeekReportPreview(title: resGetString("Deep Work"),
                                     emoji: "🧠",
                                     colorHex: 0x5E5CE6),
            WSHabitWeekReportPreview(title: resGetString("Reading"),
                                     emoji: "📖",
                                     colorHex: 0xFF9F0A),
            WSHabitWeekReportPreview(title: resGetString("Planning"),
                                     emoji: "🗓",
                                     colorHex: 0xFF9500)
        ]
        
        /// 每天的示例按行错开，避免所有行看起来完全一样
        let samples: [WSHabitPeriodPreviewSample] = [
            WSHabitPeriodPreviewSample(status: .completed, progress: 1.0),
            WSHabitPeriodPreviewSample(status: .inProgress, progress: 0.6),
            WSHabitPeriodPreviewSample(status: .notStarted),
            WSHabitPeriodPreviewSample(status: .completed, progress: 1.0),
            WSHabitPeriodPreviewSample(status: .inProgress, progress: 0.3),
            WSHabitPeriodPreviewSample(status: .skipped("😴"), reasonEmoji: "😴"),
            WSHabitPeriodPreviewSample(status: .notStarted, isScheduled: false)
        ]
        
        let dates = Date().thisWeekDays(firstWeekday: HabitSetting.shared.firstWeekday.rawValue)
        let items = examples.prefix(maximumItemCount).enumerated().map { index, example -> WSHabitPeriodDataItem in
            let color = Color(example.colorHex)
            let days = dates.enumerated().map { dayIndex, date -> WSHabitDayDataItem in
                let sample = samples[(dayIndex + index) % samples.count]
                return WSHabitDayDataItem(date: date,
                                          isScheduled: sample.isScheduled,
                                          status: sample.status,
                                          progress: sample.progress,
                                          color: color,
                                          reasonEmoji: sample.reasonEmoji)
            }
            
            return WSHabitPeriodDataItem(taskIdentifier: "preview.\(example.title)",
                                         title: example.title,
                                         subtitle: nil,
                                         icon: TPIcon(text: example.emoji),
                                         color: color,
                                         days: days)
        }
        
        return WSHabitPeriodsDataItem(items: items)
    }
}

// MARK: - 预览示例

/// 画廊预览使用的示例习惯。
private struct WSHabitWeekReportPreview {
    
    /// 示例名称
    let title: String
    
    /// 示例图标
    let emoji: String
    
    /// 示例颜色
    let colorHex: UInt64
}
