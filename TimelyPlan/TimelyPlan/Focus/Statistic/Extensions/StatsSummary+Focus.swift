//
//  StatsSummary+Focus.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/10.
//

import Foundation
import UIKit

extension StatsSummary {
    
    /// 符号文本颜色
    static var symbolTextColor: UIColor {
        return .primary.withAlphaComponent(0.6)
    }
    
    static func focusSummaries(type: StatsType, dataItem: FocusStatsDataItem) -> [StatsSummary] {
        let durationSummary = durationSummary(with: dataItem.duration)
        let focusTimesSummary = focusTimesSummary(with: dataItem.count)
        let averageScoreSummary = averageScoreSummary(with: dataItem.averageScore)
        /// 暂停次数
        let pauseTimesSummary = pauseTimesSummary(with: dataItem.pauseCount)
        let summaries = [durationSummary,
                         focusTimesSummary,
                         averageScoreSummary,
                         pauseTimesSummary]
        return summaries
    }
    
    /// 专注时长
    static func durationSummary(with duration: Duration?) -> Self {
        var summary = StatsSummary()
        summary.title = resGetString("Focus Duration")
        if let duration = duration, duration > 0 {
            summary.attributedValue = duration.attributedTitle(symbolColor: symbolTextColor)
        }
        
        return summary
    }
    
    /// 专注次数
    static func focusTimesSummary(with count: Int?) -> Self {
        var summary = StatsSummary()
        summary.title = resGetString("Focus Times")
        summary.attributedValue = timesAttributedTitle(with: count)
        return summary
    }
    
    static func pauseTimesSummary(with count: Int?) -> Self {
        var summary = StatsSummary()
        summary.title = resGetString("Pause Times")
        summary.attributedValue = timesAttributedTitle(with: count)
        return summary
    }
    
    /// 平均得分
    static func averageScoreSummary(with score: Int?) -> Self {
        var summary = StatsSummary()
        summary.title = resGetString("Average Score")
        if let score = score, score > 0 {
            summary.value = "\(score)"
        }
        
        return summary
    }
    
    // MARK: - Helpers
    /// 获取次数富文本
    static func timesAttributedTitle(with count: Int?) -> ASAttributedString? {
        guard let count = count, count > 0 else {
            return nil
        }
        
        let badge: String = count > 1 ? resGetString("Times(count)") : resGetString("Time(count)")
        return attributedValue(text: "\(count)", badge: badge, badgeColor: symbolTextColor)
    }
}

