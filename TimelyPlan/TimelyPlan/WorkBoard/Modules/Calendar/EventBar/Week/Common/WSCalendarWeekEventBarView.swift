//
//  WSCalendarWeekEventBarView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/9.
//

import Foundation
import UIKit

// MARK: - 数据条目

/// 周事项条组件的数据：从某一周开始显示若干周的事项。
struct WSCalendarWeekEventBarDataItem: WSPluginDataItem {

    /// 首周的第一天
    let startDate: Date

    /// 显示周数
    let weekCount: Int

    /// 事项。可跨越显示范围，超出范围的会被截断
    let events: [CalendarEvent]

    init(startDate: Date = Date(), weekCount: Int = 1, events: [CalendarEvent] = []) {
        self.startDate = startDate.startOfDay()
        self.weekCount = max(1, weekCount)
        self.events = events
    }
}

// MARK: - 周事项条视图

/// 日历周事项条组件：按周展示日期与事项条。
///
/// 顶部一行绘制 7 个周符号，其下每一周为「7 个天视图（日、阴历、调休）+ 事项条」；
/// 显示范围由 `startDate` 所在周与 `weekCount` 决定，外部更新 `events` 即刷新事项条。
class WSCalendarWeekEventBarView: WSPluginContentView {

    /// 布局尺寸
    private enum Metrics {

        /// 周符号行高度
        static let weekdayHeight: CGFloat = 16.0

        /// 最多显示的周数
        static let maximumWeekCount = 4
    }

    // MARK: - 显示范围

    /// 首周的第一天（当天零点）
    private(set) var startDate: Date? = Date()
        .firstDayOfWeek(firstWeekday: CalendarSetting.shared.firstWeekday)
        .startOfDay()

    /// 显示周数
    private(set) var weekCount: Int = 1

    /// 是否显示农历
    var showLunar: Bool = true {
        didSet {
            guard showLunar != oldValue else {
                return
            }

            reloadDayConfigs()
        }
    }

    /// 是否显示中国节假日与调休
    var showChineseHolidays: Bool = true {
        didSet {
            guard showChineseHolidays != oldValue else {
                return
            }

            reloadDayConfigs()
        }
    }

    // MARK: - 数据

    /// 事项。更新后立即刷新事项条
    var events: [CalendarEvent]? {
        didSet {
            guard events != oldValue else {
                return
            }

            reloadEvents()
        }
    }

    // MARK: - 交互

    /// 点击事项
    var didSelectEventHandler: ((CalendarEvent) -> Void)?

    /// 点击「更多」
    var didSelectMoreHandler: ((Date) -> Void)?

    // MARK: - 子视图

    /// 周符号行
    private let weekdayView = WSCalendarWeekEventBarWeekdayView(frame: .zero)

    /// 每周一行
    private var weekRows: [WSCalendarWeekEventBarRowView] = []

    convenience init(startDate: Date = Date(), weekCount: Int = 1) {
        self.init(frame: .zero)
        configure(startDate: startDate, weekCount: weekCount)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(weekdayView)
        setupWeekRows()
        reloadDayConfigs()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 显示范围

    /// 设置显示范围：从 `startDate` 所在周开始显示 `weekCount` 周
    func configure(startDate: Date, weekCount: Int) {
        apply(startDate: startDate, weekCount: weekCount)
        reloadEvents()
    }

    /// 显示本周开始的若干周
    func showThisWeek(weekCount: Int = 1,
                      firstWeekday: Weekday = CalendarSetting.shared.firstWeekday) {
        configure(startDate: Date().firstDayOfWeek(firstWeekday: firstWeekday),
                  weekCount: weekCount)
    }

    // MARK: - 数据

    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)

        guard let dataItem = dataItem as? WSCalendarWeekEventBarDataItem else {
            events = nil
            return
        }

        apply(startDate: dataItem.startDate, weekCount: dataItem.weekCount)
        /// 显示范围变化时事项条已被重置，事项未变也需要重新加载
        if events == dataItem.events {
            reloadEvents()
        } else {
            events = dataItem.events
        }
    }

    /// 更新显示范围。范围未变化时不做处理
    private func apply(startDate: Date, weekCount: Int) {
        let startDate = startDate.firstDayOfWeek(firstWeekday: CalendarSetting.shared.firstWeekday).startOfDay()
        let weekCount = min(max(1, weekCount), Metrics.maximumWeekCount)
        let needsRebuild = weekCount != self.weekCount
        guard startDate != self.startDate || needsRebuild else {
            return
        }

        self.startDate = startDate
        self.weekCount = weekCount

        if needsRebuild {
            setupWeekRows()
        }

        reloadDayConfigs()
        setNeedsLayout()
    }

    // MARK: - 子视图

    /// 按显示周数创建 / 复用时序行
    private func setupWeekRows() {
        if weekRows.count > weekCount {
            weekRows[weekCount...].forEach { $0.removeFromSuperview() }
            weekRows.removeLast(weekRows.count - weekCount)
        }

        while weekRows.count < weekCount {
            let row = WSCalendarWeekEventBarRowView(frame: .zero)
            row.didSelectEventHandler = { [weak self] event in
                self?.handleSelectEvent(event)
            }
            row.didSelectMoreHandler = { [weak self] date in
                self?.handleSelectMore(date)
            }
            addSubview(row)
            weekRows.append(row)
        }
    }

    /// 首周之后的第 `index` 周
    private func weekStartDate(at index: Int) -> Date? {
        return startDate?.dateByAddingDays(index * DAYS_PER_WEEK)
    }

    private func reloadEvents() {
        let events = self.events ?? []
        for (index, row) in weekRows.enumerated() {
            row.update(startDate: weekStartDate(at: index), events: events)
        }
    }

    private func reloadDayConfigs() {
        guard let startDate = startDate else {
            weekRows.forEach { $0.update(configs: []) }
            return
        }

        let weekCount = self.weekCount
        let showLunar = self.showLunar
        let showChineseHolidays = self.showChineseHolidays

        DispatchQueue.global(qos: .userInitiated).async {
            var weekConfigs = [[CalendarMonthDayConfig]]()
            for week in 0..<weekCount {
                var configs = [CalendarMonthDayConfig]()
                for day in 0..<DAYS_PER_WEEK {
                    guard let date = startDate.dateByAddingDays(week * DAYS_PER_WEEK + day) else {
                        continue
                    }

                    configs.append(CalendarMonthDayConfig(date: date,
                                                          showLunar: showLunar,
                                                          showChineseHolidays: showChineseHolidays))
                }

                weekConfigs.append(configs)
            }

            DispatchQueue.main.async { [weak self] in
                guard let self = self,
                      self.startDate == startDate,
                      self.weekCount == weekCount else {
                    return
                }

                for (index, row) in self.weekRows.enumerated() where index < weekConfigs.count {
                    row.update(configs: weekConfigs[index])
                }
            }
        }
    }

    // MARK: - 交互

    private func handleSelectEvent(_ event: CalendarEvent) {
        guard let didSelectEventHandler = didSelectEventHandler else {
            interactor?.performAction(with: WSCalendarEventRowItem(event: event))
            return
        }

        didSelectEventHandler(event)
    }

    private func handleSelectMore(_ date: Date) {
        guard let didSelectMoreHandler = didSelectMoreHandler else {
            (interactor as? WSCalendarEventContentInteractor)?.openEventList(on: date)
            return
        }

        didSelectMoreHandler(date)
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()

        let frame = layoutFrame()
        guard frame.width > 0.0, frame.height > 0.0 else {
            return
        }

        weekdayView.size = CGSize(width: frame.width, height: Metrics.weekdayHeight)
        weekdayView.origin = frame.origin

        let rowsTop = frame.minY + Metrics.weekdayHeight
        let rowsHeight = max(frame.height - Metrics.weekdayHeight, 0.0)
        let rowHeight = rowsHeight / CGFloat(max(weekCount, 1))
        for (index, row) in weekRows.enumerated() {
            row.size = CGSize(width: frame.width, height: rowHeight)
            row.left = frame.minX
            row.top = rowsTop + CGFloat(index) * rowHeight
        }
    }
}
