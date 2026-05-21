//
//  FocusTimelineTimeUtils.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/22.
//

import Foundation
import UIKit

/// 时间线时间转换工具类
class FocusTimelineTimeUtils {
    
    /// 默认时间对齐粒度（分钟）
    static let defaultAlignmentMinutes = 10
    
    /// 默认专注时长（秒）
    static let defaultFocusDuration: TimeInterval = 25 * 60 // 25分钟
    
    /// 将视图坐标Y值转换为对应的时间
    /// - Parameters:
    ///   - y: 视图中的Y坐标
    ///   - dateRange: 时间线日期范围
    ///   - viewHeight: 视图总高度
    /// - Returns: 对应的时间
    static func time(fromY y: CGFloat, 
                     dateRange: DateInterval,
                     viewHeight: CGFloat) -> Date {
        let adjustedY = max(0, y)
        let totalHeight = viewHeight
        let progress = totalHeight > 0 ? adjustedY / totalHeight : 0
        let timeInterval = dateRange.duration * Double(progress)
        var date = dateRange.start.addingTimeInterval(timeInterval)
        if date > dateRange.end {
            date = dateRange.end
        }
        
        return date
    }
    
    /// 将时间转换为视图中的Y坐标
    /// - Parameters:
    ///   - time: 要转换的时间
    ///   - dateRange: 时间线日期范围
    ///   - viewHeight: 视图总高度
    ///   - topPadding: 顶部内边距
    /// - Returns: 对应的Y坐标
    static func y(fromTime time: Date,
                  dateRange: DateInterval,
                  viewHeight: CGFloat,
                  topPadding: CGFloat = 0) -> CGFloat {
        let timeIntervalSinceStart = time.timeIntervalSince(dateRange.start)
        let progress = dateRange.duration > 0 ? timeIntervalSinceStart / dateRange.duration : 0
        let totalHeight = viewHeight - topPadding
        return topPadding + CGFloat(progress) * totalHeight
    }
    
    /// 将时间对齐到指定的分钟粒度
    /// - Parameters:
    ///   - time: 原始时间
    ///   - alignmentMinutes: 对齐粒度（分钟）
    /// - Returns: 对齐后的时间
    static func alignTime(_ time: Date, toMinutes alignmentMinutes: Int = defaultAlignmentMinutes) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: time)
        
        guard let _ = components.hour, let minute = components.minute else {
            return time
        }
        
        // 计算对齐后的分钟
        let alignedMinute = (minute / alignmentMinutes) * alignmentMinutes
        var alignedComponents = components
        alignedComponents.minute = alignedMinute
        alignedComponents.second = 0
        alignedComponents.nanosecond = 0
        
        return calendar.date(from: alignedComponents) ?? time
    }
    
    /// 计算专注记录的结束时间
    /// - Parameters:
    ///   - startTime: 开始时间
    ///   - duration: 持续时长
    /// - Returns: 结束时间
    static func endTime(from startTime: Date, duration: TimeInterval = defaultFocusDuration) -> Date {
        return startTime.addingTimeInterval(duration)
    }
    
    /// 计算指示视图的高度基于持续时长
    /// - Parameters:
    ///   - duration: 持续时长
    ///   - dateRange: 时间线日期范围
    ///   - viewHeight: 视图总高度
    /// - Returns: 对应的高度
    static func heightForDuration(_ duration: TimeInterval,
                                  dateRange: DateInterval,
                                  viewHeight: CGFloat) -> CGFloat {
        let durationRatio = dateRange.duration > 0 ? duration / dateRange.duration : 0
        return CGFloat(durationRatio) * viewHeight
    }
    
    /// 检查触摸点是否在已有的事件视图上
    /// - Parameters:
    ///   - point: 触摸点坐标
    ///   - eventViews: 已有的事件视图数组
    /// - Returns: 如果在事件视图上返回true
    static func isPointOnEventView(_ point: CGPoint, 
                                   eventViews: [FocusTimelineEventView]) -> Bool {
        for eventView in eventViews {
            if eventView.frame.contains(point) {
                return true
            }
        }
        return false
    }
}
