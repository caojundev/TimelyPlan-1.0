//
//  WSCalendarDayEventBarView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

// MARK: - 数据条目

/// 事项条组件的数据：显示范围与事项。
struct WSCalendarDayEventBarDataItem: WSPluginDataItem {

    /// 显示的第一天
    let startDate: Date

    /// 显示的天数
    let dayCount: Int

    /// 事项。可跨越显示范围，超出范围的会被截断
    let events: [CalendarEvent]

    init(startDate: Date = Date(), dayCount: Int = DAYS_PER_WEEK, events: [CalendarEvent] = []) {
        self.startDate = startDate.startOfDay()
        self.dayCount = max(1, dayCount)
        self.events = events
    }
}

// MARK: - 事项条视图

/// 日历事项条组件：把一段时间内的事项按天排成条状展示。
///
/// 显示范围由 `startDate` 与 `dayCount` 决定（如今天开始的若干天、整周）；
/// 顶部每天一列「周符号 + 天视图（日、阴历、调休）」，下方为事项条，
/// 外部更新 `events` 即刷新事项条。
class WSCalendarDayEventBarView: WSPluginContentView, CalendarStripViewDelegate {

    /// 布局尺寸
    private enum Metrics {

        /// 周符号行高
        static let weekdayHeight: CGFloat = 14.0

        /// 天视图行高
        static let dayViewHeight: CGFloat = 36.0
    }

    // MARK: - 显示范围

    /// 显示的第一天（当天零点）
    private(set) var startDate: Date? = Date.startOfToday

    /// 显示的天数
    private(set) var dayCount: Int = DAYS_PER_WEEK

    /// 显示的日期
    var days: [Date] {
        guard let startDate = startDate else {
            return []
        }

        return (0..<dayCount).compactMap { startDate.dateByAddingDays($0) }
    }

    /// 是否显示日期头。关闭时不展示周符号与天视图，事项条占满高度
    var showsDayHeader: Bool = true {
        didSet {
            guard showsDayHeader != oldValue else {
                return
            }

            setupDayColumns()
            reloadDayConfigs()
            setNeedsLayout()
        }
    }

    /// 周符号行高
    var weekdayHeight: CGFloat = Metrics.weekdayHeight {
        didSet {
            setNeedsLayout()
        }
    }

    /// 天视图行高
    var dayViewHeight: CGFloat = Metrics.dayViewHeight {
        didSet {
            setNeedsLayout()
        }
    }

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

    /// 事项条，横跨天数在创建时固定，天数变化时重建
    private var stripView: CalendarStripView?

    /// 每天一列：周符号 + 天视图
    private var dayColumns: [WSCalendarDayEventBarColumnView] = []

    convenience init(startDate: Date = Date(), dayCount: Int = DAYS_PER_WEEK) {
        self.init(frame: .zero)
        configure(startDate: startDate, dayCount: dayCount)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDayColumns()
        setupStripView()
        reloadDayConfigs()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 显示范围

    /// 设置显示范围：从 `startDate` 当天开始显示 `dayCount` 天
    func configure(startDate: Date, dayCount: Int) {
        applyDisplayRange(startDate: startDate, dayCount: dayCount)
        reloadEvents()
    }

    /// 从指定日期开始显示若干天。默认今天开始的一周
    func showDays(startingAt date: Date = Date(), count: Int = DAYS_PER_WEEK) {
        configure(startDate: date, dayCount: count)
    }

    /// 显示指定日期所在的那一周
    func showWeek(containing date: Date = Date(),
                  firstWeekday: Weekday = CalendarSetting.shared.firstWeekday) {
        configure(startDate: date.firstDayOfWeek(firstWeekday: firstWeekday),
                  dayCount: DAYS_PER_WEEK)
    }

    // MARK: - 数据

    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)

        guard let dataItem = dataItem as? WSCalendarDayEventBarDataItem else {
            events = nil
            return
        }

        applyDisplayRange(startDate: dataItem.startDate, dayCount: dataItem.dayCount)
        /// 显示范围变化时事项条已被重置，事项未变也需要重新加载
        if events == dataItem.events {
            reloadEvents()
        } else {
            events = dataItem.events
        }
    }

    /// 更新显示范围。范围未变化时不做处理
    private func applyDisplayRange(startDate: Date, dayCount: Int) {
        let startDate = startDate.startOfDay()
        let dayCount = max(1, dayCount)
        let needsRebuild = dayCount != self.dayCount
        guard startDate != self.startDate || needsRebuild else {
            return
        }

        self.startDate = startDate
        self.dayCount = dayCount

        if needsRebuild {
            setupDayColumns()
            setupStripView()
        }

        stripView?.startDate = startDate
        stripView?.reset()
        reloadDayConfigs()
        setNeedsLayout()
    }

    private func reloadEvents() {
        guard let stripView = stripView else {
            return
        }

        guard let events = events, !events.isEmpty else {
            stripView.reset()
            return
        }

        stripView.startDate = startDate
        stripView.events = events
        stripView.reloadData()
    }

    // MARK: - 子视图

    /// 事项条横跨的天数在创建时固定，天数变化时重建
    private func setupStripView() {
        stripView?.removeFromSuperview()

        let view = CalendarStripView(days: dayCount)
        view.delegate = self
        view.startDate = startDate
        addSubview(view)
        stripView = view
    }

    /// 按显示天数创建 / 复用日期列
    private func setupDayColumns() {
        let count = showsDayHeader ? dayCount : 0
        if dayColumns.count > count {
            dayColumns[count...].forEach { $0.removeFromSuperview() }
            dayColumns.removeLast(dayColumns.count - count)
        }

        while dayColumns.count < count {
            let column = WSCalendarDayEventBarColumnView(frame: .zero)
            addSubview(column)
            dayColumns.append(column)
        }
    }

    /// 后台计算日期配置后回主线程分发，避免逐列同步计算
    private func reloadDayConfigs() {
        guard startDate != nil else {
            dayColumns.forEach { $0.reset() }
            return
        }

        let dates = days
        let showLunar = self.showLunar
        let showChineseHolidays = self.showChineseHolidays

        DispatchQueue.global(qos: .userInitiated).async {
            let configs = dates.map {
                return CalendarMonthDayConfig(date: $0,
                                              showLunar: showLunar,
                                              showChineseHolidays: showChineseHolidays)
            }

            DispatchQueue.main.async { [weak self] in
                guard let self = self, self.days == dates else {
                    return
                }

                for (index, column) in self.dayColumns.enumerated() where index < configs.count {
                    column.update(with: configs[index])
                }
            }
        }
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()

        let frame = layoutFrame()
        guard frame.width > 0.0, frame.height > 0.0 else {
            return
        }

        let headerHeight = showsDayHeader
            ? min(weekdayHeight + dayViewHeight, frame.height)
            : 0.0
        let itemWidth = frame.width / CGFloat(max(dayColumns.count, 1))
        for (index, column) in dayColumns.enumerated() {
            column.weekdayHeight = weekdayHeight
            column.size = CGSize(width: itemWidth, height: headerHeight)
            column.left = frame.minX + CGFloat(index) * itemWidth
            column.top = frame.minY
        }

        stripView?.origin = CGPoint(x: frame.minX, y: frame.minY + headerHeight)
        stripView?.size = CGSize(width: frame.width, height: max(frame.height - headerHeight, 0.0))
    }

    // MARK: - CalendarStripViewDelegate

    func calendarStripView(_ view: CalendarStripView, didTapEvent event: CalendarEvent) {
        guard let didSelectEventHandler = didSelectEventHandler else {
            interactor?.performAction(with: WSCalendarEventRowItem(event: event))
            return
        }

        didSelectEventHandler(event)
    }

    func calendarStripView(_ view: CalendarStripView, didTapMoreOnDate date: Date) {
        guard let didSelectMoreHandler = didSelectMoreHandler else {
            (interactor as? WSCalendarEventContentInteractor)?.openEventList(on: date)
            return
        }

        didSelectMoreHandler(date)
    }
}
