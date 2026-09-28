//
//  FocusDurationLevel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/28.
//

import Foundation
import UIKit

// MARK: - 专注时长等级
/// 专注时长等级信息
struct FocusDurationLevel {
    
    /// 等级（0 表示无专注记录）
    var level: Int
    
    /// 等级颜色（由浅到深）
    var color: UIColor
    
    /// 等级时长区间描述
    var title: String?
    
    /// 背景色是否为深色
    var isDark: Bool
    
    /// 标签文本颜色：深色背景使用白色，浅色背景跟随标题色
    var textColor: UIColor {
        return isDark ? .white : resGetColor(.title)
    }
}

/// 专注时长等级工具类
class FocusDurationLevels {
    
    /// 各等级的时长上限（不含 0 级），最后一个为 nil 表示没有上限
    /// 可在此统一调整分级区间：0~2h、2~5h、5~8h、8~12h、12h 以上
    static let levelUpperDurations: [Duration?] = [
        2 * SECONDS_PER_HOUR,
        5 * SECONDS_PER_HOUR,
        8 * SECONDS_PER_HOUR,
        12 * SECONDS_PER_HOUR,
        nil
    ]
    
    /// 各等级颜色（由浅到深，不含 0 级）
    static let levelColors: [UIColor] = [
        UIColor.primary.withAlphaComponent(0.28),
        UIColor.primary.withAlphaComponent(0.44),
        UIColor.primary.withAlphaComponent(0.62),
        UIColor.primary.withAlphaComponent(0.80),
        UIColor.primary.withAlphaComponent(1.0)
    ]
    
    /// 无专注记录时的颜色
    static let noneColor = UIColor.clear
    
    /// 深色背景的起始等级：等级大于等于该值时背景色较深，标签使用白色文字
    static let darkLevelThreshold = 4
    
    /// 等级数量（不含 0 级）
    static var levelCount: Int {
        return levelUpperDurations.count
    }
    
    /// 获取时长对应的等级（0 ~ levelCount）
    static func level(for duration: Duration) -> Int {
        guard duration > 0 else {
            return 0
        }
        
        for (index, upperDuration) in levelUpperDurations.enumerated() {
            guard let upperDuration = upperDuration else {
                return index + 1 /// 最高等级无上限
            }
            
            if duration <= upperDuration {
                return index + 1
            }
        }
        
        return levelCount
    }
    
    /// 获取时长对应的等级信息
    static func levelInfo(for duration: Duration) -> FocusDurationLevel {
        return levelInfo(forLevel: level(for: duration))
    }
    
    /// 获取指定等级的信息
    static func levelInfo(forLevel level: Int) -> FocusDurationLevel {
        guard level > 0, level <= levelCount else {
            return FocusDurationLevel(level: 0, color: noneColor, title: nil, isDark: false)
        }
        
        return FocusDurationLevel(level: level,
                                  color: levelColors[level - 1],
                                  title: title(forLevel: level),
                                  isDark: level >= darkLevelThreshold)
    }
    
    /// 获取所有等级信息（含 0 级），可用于图例
    static func allLevels() -> [FocusDurationLevel] {
        return (0...levelCount).map { levelInfo(forLevel: $0) }
    }
    
    /// 获取指定等级的时长区间描述
    static func title(forLevel level: Int) -> String? {
        guard level > 0, level <= levelCount else {
            return nil
        }
        
        let lowerDuration = level > 1 ? levelUpperDurations[level - 2] : nil
        let upperDuration = levelUpperDurations[level - 1]
        let lowerTitle = Duration(lowerDuration ?? 0).title
        guard let upperDuration = upperDuration else {
            return ">" + lowerTitle /// 最高等级
        }
        
        if level == 1 {
            return "<" + upperDuration.title
        }
        
        return lowerTitle + "~" + upperDuration.title
    }
}
