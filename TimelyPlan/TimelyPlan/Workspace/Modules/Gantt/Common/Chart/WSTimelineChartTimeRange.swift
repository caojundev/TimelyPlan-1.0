//
//  WSTimelineChartTimeRange.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

/// 甘特图组件展示的时间范围
///
/// 组件不能滚动，展示的刻度数量固定：
/// - 按天：前 2 天 + 今天 + 后 2 天，共 5 个天刻度
/// - 按周：前 1 周 + 本周 + 下 1 周，共 3 个周刻度
/// - 按月：上个月的一半 + 本月 + 下个月的一半，共 2 个月刻度
///
/// 刻度宽度按可视宽度等分，日期与坐标的换算、顶部刻度需要绘制的位置都由该类型统一计算，
/// 保证刻度与事项甘特条使用同一套坐标。
struct WSTimelineChartTimeRange {

    // MARK: - 刻度

    /// 顶部需要绘制的刻度
    struct Unit {

        /// 刻度起始日期
        let date: Date

        /// 刻度左边界
        let minX: CGFloat

        /// 刻度宽度
        let width: CGFloat

        /// 刻度是否包含今天。用于高亮
        let containsToday: Bool
    }

    /// 按天模式的刻度数量
    static let dayUnitCount = 5

    /// 按周模式的刻度数量
    static let weekUnitCount = 3

    /// 按月模式的刻度数量
    static let monthUnitCount = 2

    // MARK: - 属性

    /// 时间刻度
    let scale: GanttTimeScale.Scale

    /// 展示起始日期（含）
    let startDate: Date

    /// 展示结束日期（含）
    let endDate: Date

    /// 刻度数量，即可视宽度等分的数量
    let unitCount: Int

    /// 按月模式下第一个月的起始日期，用于月份索引换算；其它模式等于 `startDate`
    private let monthUnitStartDate: Date

    // MARK: - 初始化

    /// 按时间刻度与参考日期生成展示范围
    /// - Parameters:
    ///   - scale: 时间刻度
    ///   - date: 参考日期，按天/按周以该日期为中心，按月以该日期所在月份为中心
    init(scale: GanttTimeScale.Scale, date: Date = Date()) {
        self.scale = scale

        switch scale {
        case .day:
            let today = date.startOfDay()
            self.startDate = today.dateByAddingDays(-2) ?? today
            self.endDate = (today.dateByAddingDays(2) ?? today).endOfDay()
            self.unitCount = Self.dayUnitCount
            self.monthUnitStartDate = self.startDate

        case .week:
            let weekStart = date.startOfWeek(firstWeekday: GanttSetting.shared.firstWeekday)
            self.startDate = weekStart.dateByAddingDays(-7) ?? weekStart
            self.endDate = (weekStart.dateByAddingDays(13) ?? weekStart).endOfDay()
            self.unitCount = Self.weekUnitCount
            self.monthUnitStartDate = self.startDate

        case .month:
            let monthStart = date.startOfMonth()
            let previousMonthStart = monthStart.dateByAddingMonths(-1) ?? monthStart
            let nextMonthStart = monthStart.dateByAddingMonths(1) ?? monthStart
            self.startDate = Self.middle(ofMonthStartingAt: previousMonthStart)
            self.endDate = Self.middle(ofMonthStartingAt: nextMonthStart).endOfDay()
            self.unitCount = Self.monthUnitCount
            self.monthUnitStartDate = previousMonthStart
        }
    }

    /// 月份的中点（取整到天）。按月模式下展示范围从上个月的中点到下个月的中点
    private static func middle(ofMonthStartingAt date: Date) -> Date {
        let days = Calendar.current.range(of: .day, in: .month, for: date)?.count ?? 30
        return date.dateByAddingDays(days / 2) ?? date
    }

    // MARK: - 范围

    /// 取数使用的日期范围
    var dateInterval: DateInterval {
        return DateInterval(start: startDate, end: max(endDate, startDate))
    }

    /// 指定日期区间是否与展示范围相交
    func intersects(start: Date, end: Date) -> Bool {
        return start <= endDate && end >= startDate
    }

    // MARK: - 坐标换算

    /// 单个刻度的宽度
    func unitWidth(for totalWidth: CGFloat) -> CGFloat {
        return max(totalWidth, 0.0) / CGFloat(max(unitCount, 1))
    }

    /// 指定日期在时间轴上的 X 坐标
    ///
    /// 在整天的基础上叠加当天已过去时间的比例，使同一天内的事项也能有可见宽度。
    func xPosition(for date: Date, in totalWidth: CGFloat) -> CGFloat {
        let width = self.unitWidth(for: totalWidth)
        guard width > 0.0 else { return 0.0 }

        let calendar = Calendar.current
        let fraction = dayFraction(of: date)

        switch scale {
        case .day:
            let days = calendar.dateComponents([.day], from: startDate, to: date.startOfDay()).day ?? 0
            return (CGFloat(days) + fraction) * width

        case .week:
            let days = calendar.dateComponents([.day], from: startDate, to: date.startOfDay()).day ?? 0
            return (CGFloat(days) + fraction) / 7.0 * width

        case .month:
            let months = calendar.dateComponents([.month], from: monthUnitStartDate, to: date.startOfMonth()).month ?? 0
            let daysInMonth = calendar.range(of: .day, in: .month, for: date)?.count ?? 30
            let dayInMonth = calendar.component(.day, from: date) - 1
            let monthFraction = (CGFloat(dayInMonth) + fraction) / CGFloat(daysInMonth)
            /// 展示范围从上个月的一半开始，因此整体左移半个刻度
            return (CGFloat(months) + monthFraction - 0.5) * width
        }
    }

    /// 当天已过去时间的比例（0 ~ 1）
    private func dayFraction(of date: Date) -> CGFloat {
        let start = date.startOfDay()
        let duration = Calendar.current.dateInterval(of: .day, for: date)?.duration ?? 86400
        guard duration > 0 else { return 0.0 }

        return min(max(CGFloat(date.timeIntervalSince(start) / duration), 0.0), 1.0)
    }

    // MARK: - 顶部刻度

    /// 顶部需要从左向右绘制的刻度
    func headerUnits(width totalWidth: CGFloat) -> [Unit] {
        let width = self.unitWidth(for: totalWidth)
        guard width > 0.0 else { return [] }

        switch scale {
        case .day:
            return (0..<unitCount).compactMap { index in
                guard let date = startDate.dateByAddingDays(index) else { return nil }
                return Unit(date: date,
                            minX: CGFloat(index) * width,
                            width: width,
                            containsToday: date.isToday)
            }

        case .week:
            return (0..<unitCount).compactMap { index in
                guard let date = startDate.dateByAddingDays(index * 7),
                      let weekEnd = date.dateByAddingDays(6) else {
                    return nil
                }

                return Unit(date: date,
                            minX: CGFloat(index) * width,
                            width: width,
                            containsToday: Self.containsToday(from: date, to: weekEnd.endOfDay()))
            }

        case .month:
            /// 按月模式只绘制本月，上个月与下个月仅保留半格展示范围
            guard let monthStart = monthUnitStartDate.dateByAddingMonths(1) else { return [] }
            return [Unit(date: monthStart,
                         minX: xPosition(for: monthStart, in: totalWidth),
                         width: width,
                         containsToday: Self.containsToday(from: monthStart, to: monthStart.endOfMonth()))]
        }
    }

    /// 给定区间是否包含今天
    private static func containsToday(from startDate: Date, to endDate: Date) -> Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }
}
