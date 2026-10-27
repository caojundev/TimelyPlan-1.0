//
//  WSHabitSmallMonthReportPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 习惯·小·月报告。展示所选习惯本月的完成情况。
class WSHabitSmallMonthReportPluginProvider: WSHabitPeriodPluginProvider {
    
    init() {
        super.init(type: .habitSmallMonthReport, itemCount: 1)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSHabitSmallMonthReportContentView()
    }
    
    override func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSHabitMonthReportContentInteractor(plugin: plugin, context: context)
    }
}

// MARK: - 内容交互器

/// 习惯·小·月报告的内容交互器。按月取一次记录，由内容视图绘制本月热力图。
class WSHabitMonthReportContentInteractor: WSHabitPeriodContentInteractor {
    
    /// 记录使用本月的时间段，跨月刷新由基类的零点监听统一处理
    override func fetchPeriods(containing date: Date) -> [HabitDatePeriod] {
        return [HabitDatePeriod(date: date,
                                mode: .month,
                                firstWeekday: HabitSetting.shared.firstWeekday)]
    }
    
    /// 展示当月每一天
    override func displayDates(containing date: Date) -> [Date] {
        return date.datesInMonth()
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：按日循环示例，画出有层次的热力分布
    override func previewDataItem() -> WSPluginDataItem? {
        let color = Color(0x5E5CE6)
        let samples: [WSHabitPeriodPreviewSample] = [
            WSHabitPeriodPreviewSample(status: .completed, progress: 1.0),
            WSHabitPeriodPreviewSample(status: .inProgress, progress: 0.6),
            WSHabitPeriodPreviewSample(status: .completed, progress: 1.0),
            WSHabitPeriodPreviewSample(status: .notStarted),
            WSHabitPeriodPreviewSample(status: .inProgress, progress: 0.4),
            WSHabitPeriodPreviewSample(status: .skipped("😴"), reasonEmoji: "😴"),
            WSHabitPeriodPreviewSample(status: .completed, progress: 1.0),
            WSHabitPeriodPreviewSample(status: .notStarted, isScheduled: false)
        ]
        
        let days = displayDates(containing: Date()).enumerated().map { index, date -> WSHabitDayDataItem in
            let sample = samples[index % samples.count]
            return WSHabitDayDataItem(date: date,
                                      isScheduled: sample.isScheduled,
                                      status: sample.status,
                                      progress: sample.progress,
                                      color: color,
                                      reasonEmoji: sample.reasonEmoji)
        }
        
        return WSHabitPeriodDataItem(taskIdentifier: "preview.habit",
                                     title: resGetString("Reading"),
                                     subtitle: nil,
                                     icon: TPIcon(text: "📖"),
                                     color: color,
                                     days: days)
    }
}
