//
//  GanttTimelineScaleUnit.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/24.
//

import Foundation
import UIKit

// MARK: - 时间轴刻度模型

/// 时间轴刻度单元（一个 cell 对应的时间段）
struct GanttTimelineScaleUnit {
    /// 该单元在时间轴上的起始日期
    let startDate: Date
    
    /// 该单元在时间轴上的结束日期
    let endDate: Date
    
    /// 是否为「月」边界（day 模式下的每月第一天 / month 模式的每月）
    let isMajorBoundary: Bool
}

/// 时间轴刻度的计算器，负责根据不同 scale 生成 header 所需的刻度单元数组
struct GanttTimelineScaleCalculator {
    let scale: GanttTimeScale.Scale
    let startDate: Date
    let endDate: Date

    init(timeScale: GanttTimeScale) {
        self.scale = timeScale.scale
        self.startDate = timeScale.startDate
        self.endDate = timeScale.endDate
    }
    
    /// 生成所有刻度单元
    func makeUnits() -> [GanttTimelineScaleUnit] {
        switch scale {
        case .day: return makeDayUnits()
        case .week: return makeWeekUnits()
        case .month: return makeMonthUnits()
        }
    }

    // MARK: - 日刻度

    private func makeDayUnits() -> [GanttTimelineScaleUnit] {
        let calendar = Calendar.current
        let totalDays = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 30
        var units: [GanttTimelineScaleUnit] = []
        var currentDate = startDate

        for day in 0...totalDays {
            let isMonthStart = calendar.component(.day, from: currentDate) == 1 || day == 0
            let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate

            units.append(GanttTimelineScaleUnit(
                startDate: currentDate,
                endDate: nextDate,
                isMajorBoundary: isMonthStart
            ))

            currentDate = nextDate
        }

        return units
    }

    // MARK: - 周刻度    
    private func makeWeekUnits(firstWeekday: Int = 1) -> [GanttTimelineScaleUnit] {
        let calendar = Calendar.current
        var units: [GanttTimelineScaleUnit] = []
        var currentStart = startDate
        while currentStart < endDate {
            let currentEnd = calendar.date(byAdding: .day, value: 7, to: currentStart) ?? currentStart
            units.append(GanttTimelineScaleUnit(
                startDate: currentStart,
                endDate: currentEnd,
                isMajorBoundary: true
            ))
            currentStart = currentEnd
        }

        return units
    }

    // MARK: - 月刻度

    private func makeMonthUnits() -> [GanttTimelineScaleUnit] {
        let calendar = Calendar.current
        let totalMonths = (calendar.dateComponents([.month], from: startDate, to: endDate).month ?? 1) + 1
        var units: [GanttTimelineScaleUnit] = []
        for month in 0...totalMonths {
            guard let monthDate = calendar.date(byAdding: .month, value: month, to: startDate) else { continue }
            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthDate) ?? monthDate
            units.append(GanttTimelineScaleUnit(
                startDate: monthDate,
                endDate: monthEnd,
                isMajorBoundary: true
            ))
        }

        return units
    }

    /// 计算某个日期在时间轴上的 X 坐标（与 GanttTimelineLayout 保持一致）
    func xPosition(for date: Date) -> CGFloat {
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
