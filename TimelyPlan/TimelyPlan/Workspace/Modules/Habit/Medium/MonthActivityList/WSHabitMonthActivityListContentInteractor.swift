//
//  WSHabitMonthActivityListContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation

// MARK: - 内容交互器

/// 习惯月度活动列表的内容交互器。
///
/// 读取今日排期习惯的整月记录，每个习惯一行下发给内容视图；
/// 任务与记录变化时重新取数，跨天刷新由基类的零点监听统一处理。
class WSHabitMonthActivityListContentInteractor: WSHabitPluginContentInteractor {
    
    /// 最多展示的习惯数目
    private let maximumItemCount: Int
    
    init(plugin: WSPlugin, context: WSPluginContext, maximumItemCount: Int) {
        self.maximumItemCount = maximumItemCount
        super.init(plugin: plugin, context: context)
    }
    
    // MARK: - 取数
    /// 读取本月时间段的记录，只保留今日仍有排期的习惯
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let date = Date()
        let period = HabitDatePeriod(date: date,
                                     mode: .month,
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
            
            let dates = date.datesInMonth()
            let items = periodItems.prefix(self.maximumItemCount).map { periodItem -> WSHabitPeriodDataItem in
                let task = periodItem.habitTask
                return WSHabitPeriodDataItem(taskIdentifier: task.identifier,
                                             title: task.displayName,
                                             subtitle: Self.goalDescription(for: task),
                                             icon: task.icon,
                                             color: task.color,
                                             days: WSHabitDayDataItem.items(from: periodItem, dates: dates))
            }
            completion(WSHabitPeriodsDataItem(items: items))
        }
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：固定展示几个示例习惯的当月活动，行数与真实展示一致
    override func previewDataItem() -> WSPluginDataItem? {
        let examples: [WSHabitMonthActivityPreview] = [
            WSHabitMonthActivityPreview(title: resGetString("Workout"),
                                        emoji: "🏃",
                                        colorHex: 0xFF375F),
            WSHabitMonthActivityPreview(title: resGetString("Meditation"),
                                        emoji: "🧘",
                                        colorHex: 0xAF52DE),
            WSHabitMonthActivityPreview(title: resGetString("Study"),
                                        emoji: "📚",
                                        colorHex: 0x0A84FF),
            WSHabitMonthActivityPreview(title: resGetString("Deep Work"),
                                        emoji: "🧠",
                                        colorHex: 0x5E5CE6),
            WSHabitMonthActivityPreview(title: resGetString("Reading"),
                                        emoji: "📖",
                                        colorHex: 0xFF9F0A),
            WSHabitMonthActivityPreview(title: resGetString("Planning"),
                                        emoji: "🗓",
                                        colorHex: 0xFF9500)
        ]
        
        /// 每天的示例按行错开，避免所有行看起来完全一样
        let samples: [WSHabitPeriodPreviewSample] = [
            WSHabitPeriodPreviewSample(status: .completed, progress: 1.0),
            WSHabitPeriodPreviewSample(status: .completed, progress: 1.0),
            WSHabitPeriodPreviewSample(status: .inProgress, progress: 0.6),
            WSHabitPeriodPreviewSample(status: .notStarted),
            WSHabitPeriodPreviewSample(status: .completed, progress: 1.0),
            WSHabitPeriodPreviewSample(status: .skipped("😴"), reasonEmoji: "😴"),
            WSHabitPeriodPreviewSample(status: .notStarted, isScheduled: false)
        ]
        
        let subtitle = resGetString("Check-in one time per day")
        let dates = Date().datesInMonth()
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
                                         subtitle: subtitle,
                                         icon: TPIcon(text: example.emoji),
                                         color: color,
                                         days: days)
        }
        
        return WSHabitPeriodsDataItem(items: items)
    }
    
    // MARK: - 数据
    /// 行的副标题：目标描述
    private static func goalDescription(for task: HabitTask) -> String {
        return task.goal.targetDescription
    }
}

// MARK: - 预览示例

/// 画廊预览使用的示例习惯。
private struct WSHabitMonthActivityPreview {
    
    /// 示例名称
    let title: String
    
    /// 示例图标
    let emoji: String
    
    /// 示例颜色
    let colorHex: UInt64
}
