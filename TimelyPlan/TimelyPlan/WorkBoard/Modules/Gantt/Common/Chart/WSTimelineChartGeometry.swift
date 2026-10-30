//
//  WSTimelineChartGeometry.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

/// 组件内时间轴的几何计算，单位宽度取自 `WSTimelineChartConfig`
enum WSTimelineChartGeometry {

    /// 刻度单元数量（含末尾边界）
    static func unitCount(timeScale: GanttTimeScale) -> Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: timeScale.startDate, to: timeScale.endDate).day ?? 30

        switch timeScale.scale {
        case .day:
            return days + 1
        case .week:
            return Int(ceil(Double(days + 1) / 7.0))
        case .month:
            let months = calendar.dateComponents([.month], from: timeScale.startDate, to: timeScale.endDate).month ?? 1
            return months + 1
        }
    }

    /// 时间轴内容总宽度
    static func contentWidth(timeScale: GanttTimeScale) -> CGFloat {
        let unitWidth = WSTimelineChartConfig.pixelsPerUnit(for: timeScale.scale)
        return CGFloat(unitCount(timeScale: timeScale)) * unitWidth
    }

    /// 指定日期在时间轴上的 X 坐标
    ///
    /// 在整天的基础上叠加当天已过去时间的比例，使同一天内的事项也能有可见宽度。
    static func xPosition(for date: Date, timeScale: GanttTimeScale) -> CGFloat {
        let calendar = Calendar.current
        let unitWidth = WSTimelineChartConfig.pixelsPerUnit(for: timeScale.scale)
        let days = calendar.dateComponents([.day], from: timeScale.startDate, to: date).day ?? 0

        let dayStart = calendar.startOfDay(for: date)
        let dayDuration = calendar.dateInterval(of: .day, for: date)?.duration ?? 86400
        let dayFraction = dayDuration > 0 ? date.timeIntervalSince(dayStart) / dayDuration : 0

        switch timeScale.scale {
        case .day:
            return (CGFloat(days) + CGFloat(dayFraction)) * unitWidth
        case .week:
            return (CGFloat(days) + CGFloat(dayFraction)) / 7.0 * unitWidth
        case .month:
            let months = calendar.dateComponents([.month], from: timeScale.startDate, to: date).month ?? 0
            let dayInMonth = calendar.component(.day, from: date) - 1
            let daysInMonth = calendar.range(of: .day, in: .month, for: date)?.count ?? 30
            let monthFraction = (CGFloat(dayInMonth) + CGFloat(dayFraction)) / CGFloat(daysInMonth)
            return (CGFloat(months) + monthFraction) * unitWidth
        }
    }

    /// 根据 X 坐标反推对应日期
    static func date(forX x: CGFloat, timeScale: GanttTimeScale) -> Date {
        let calendar = Calendar.current
        let unitWidth = WSTimelineChartConfig.pixelsPerUnit(for: timeScale.scale)
        guard unitWidth > 0 else { return timeScale.startDate }

        let clampedX = max(0, x)

        switch timeScale.scale {
        case .day:
            let days = Int(round(clampedX / unitWidth))
            return calendar.date(byAdding: .day, value: days, to: timeScale.startDate) ?? timeScale.startDate
        case .week:
            let weeks = clampedX / unitWidth
            let days = Int(round(weeks * 7.0))
            return calendar.date(byAdding: .day, value: days, to: timeScale.startDate) ?? timeScale.startDate
        case .month:
            let totalMonths = calendar.dateComponents([.month], from: timeScale.startDate, to: timeScale.endDate).month ?? 1
            guard totalMonths > 0 else { return timeScale.startDate }

            let unitIndex = clampedX / unitWidth
            let monthIndex = Int(floor(unitIndex))
            let clampedMonth = max(0, min(monthIndex, totalMonths))
            let fraction = unitIndex - CGFloat(clampedMonth)

            let monthStart = calendar.date(byAdding: .month, value: clampedMonth, to: timeScale.startDate) ?? timeScale.startDate
            let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30
            let dayInMonth = Int(round(fraction * CGFloat(daysInMonth)))
            return calendar.date(byAdding: .day, value: dayInMonth, to: monthStart) ?? monthStart
        }
    }

    /// 第 index 个刻度的起始日期
    static func unitStartDate(at index: Int, timeScale: GanttTimeScale) -> Date {
        let calendar = Calendar.current

        switch timeScale.scale {
        case .day:
            return calendar.date(byAdding: .day, value: index, to: timeScale.startDate) ?? timeScale.startDate
        case .week:
            return calendar.date(byAdding: .day, value: index * 7, to: timeScale.startDate) ?? timeScale.startDate
        case .month:
            return calendar.date(byAdding: .month, value: index, to: timeScale.startDate) ?? timeScale.startDate
        }
    }
}
