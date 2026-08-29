//
//  GanttTimelineGeometry.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/29.
//

import Foundation
import UIKit

// MARK: - 时间轴几何计算工具

enum GanttTimelineGeometry {

    /// 计算时间轴内容总宽度（与 GanttTimelineLayout 的 calculateTimeAxisWidth 逻辑一致）
    /// - Parameter timeScale: 时间尺度
    /// - Returns: 内容宽度（pt）
    static func contentWidth(timeScale: GanttTimeScale) -> CGFloat {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: timeScale.startDate, to: timeScale.endDate).day ?? 30

        switch timeScale.scale {
        case .day:
            return CGFloat(days + 1) * timeScale.scale.pixelsPerUnit
        case .week:
            let weeks = ceil(Double(days + 1) / 7.0)
            return CGFloat(weeks) * timeScale.scale.pixelsPerUnit
        case .month:
            let months = calendar.dateComponents([.month], from: timeScale.startDate, to: timeScale.endDate).month ?? 1
            return CGFloat(months + 1) * timeScale.scale.pixelsPerUnit
        }
    }

    /// 计算指定日期在时间轴上的 X 坐标
    /// - Parameters:
    ///   - date: 目标日期
    ///   - timeScale: 时间尺度
    /// - Returns: X 坐标（pt）
    static func xPositionForDate(_ date: Date, timeScale: GanttTimeScale) -> CGFloat {
        return xPositionForDate(date, scale: timeScale.scale, startDate: timeScale.startDate)
    }

    /// 计算指定日期在时间轴上的 X 坐标（低层实现）
    /// - Parameters:
    ///   - date: 目标日期
    ///   - scale: 时间尺度类型
    ///   - startDate: 时间轴起始日期
    /// - Returns: X 坐标（pt）
    static func xPositionForDate(_ date: Date, scale: GanttTimeScale.Scale, startDate: Date) -> CGFloat {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: startDate, to: date).day ?? 0

        switch scale {
        case .day:
            return CGFloat(days) * scale.pixelsPerUnit
        case .week:
            return (CGFloat(days) / 7.0) * scale.pixelsPerUnit
        case .month:
            let months = calendar.dateComponents([.month], from: startDate, to: date).month ?? 0
            let dayInMonth = calendar.component(.day, from: date) - 1
            let daysInMonth = calendar.range(of: .day, in: .month, for: date)?.count ?? 30
            return (CGFloat(months) + CGFloat(dayInMonth) / CGFloat(daysInMonth)) * scale.pixelsPerUnit
        }
    }
}
