//
//  CalendarEventDetailProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation

// MARK: - 详情选项

/// 日历事项详情的展示项
struct CalendarEventDetailOption: OptionSet {

    let rawValue: Int

    /// 时间
    static let time = CalendarEventDetailOption(rawValue: 1 << 0)

    /// 来源
    static let source = CalendarEventDetailOption(rawValue: 1 << 1)

    /// 所有选项
    static let all: CalendarEventDetailOption = [time, source]
}

// MARK: - 详情供应

/// 日历事项详情的供应工具。
///
/// 跨天事项按展示日期截取当天的时段，并可拼接来源说明；
/// 各部分以 ` • ` 分隔，没有任何内容时返回 nil。
class CalendarEventDetailProvider {

    /// 事项
    let event: CalendarEvent

    /// 展示日期，跨天事项据此截取当天部分。为空时按开始日期计算
    let date: Date?

    /// 展示项
    var option: CalendarEventDetailOption = .all

    init(event: CalendarEvent, date: Date? = nil, option: CalendarEventDetailOption = .all) {
        self.event = event
        self.date = date
        self.option = option
    }

    /// 详情文案
    func info() -> String? {
        var infos = [String]()
        if option.contains(.time), let info = timeInfo() {
            infos.append(info)
        }

        if option.contains(.source), let info = event.sourceDescription {
            infos.append(info)
        }

        guard infos.count > 0 else {
            return nil
        }

        return infos.joined(separator: " • ")
    }

    // MARK: - 时间
    /// 时间文案。跨天事项按展示日期给出时段，并附带第几天 / 共几天
    private func timeInfo() -> String? {
        let day = date ?? event.startDate
        let allDayString = resGetString("All day")

        guard event.spansMultipleDays else {
            guard !event.isAllDay else {
                return allDayString
            }

            return "\(event.startDate.timeString) - \(event.endDate.timeString)"
        }

        var infos = [String]()
        if day.isInSameDayAs(event.startDate) {
            /// 开始日：全天事项或开始时间
            infos.append(event.startDate.isStartOfDay ? allDayString : event.startDate.timeString)
        } else if day.isInSameDayAs(event.endDate) {
            /// 结束日：全天结束或截止时间
            if event.endDate.isEndOfDay {
                infos.append(allDayString)
            } else {
                let format = resGetString("Until %@")
                infos.append(String(format: format, event.endDate.timeString))
            }
        } else {
            /// 非开始与结束日，按全天展示
            infos.append(allDayString)
        }

        let index = event.getDayIndex(targetDate: day) + 1
        let spanDays = event.spanDays
        if index > 0, spanDays > 0 {
            let format = resGetString("Day %ld/%ld")
            infos.append(String(format: format, index, spanDays))
        }

        return infos.joined(separator: " • ")
    }
}
