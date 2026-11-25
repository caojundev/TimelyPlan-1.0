//
//  WSCalendarMonthEventBarView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/9.
//

import Foundation
import UIKit

// MARK: - 数据条目

/// 月事项条组件的数据：月份与事项。
struct WSCalendarMonthEventBarDataItem: WSPluginDataItem {

    /// 显示的月份（当月 1 号）
    let monthDate: Date

    /// 事项。可跨越显示范围，超出范围的会被截断
    let events: [CalendarEvent]

    init(monthDate: Date = Date(), events: [CalendarEvent] = []) {
        self.monthDate = monthDate.startOfMonth()
        self.events = events
    }
}

// MARK: - 月事项条视图

/// 日历月事项条组件：按当月网格展示 5~6 周的事项条。
///
/// 顶部一行绘制 7 个周符号，其下每周为「当月日期 + 事项条」，当月之外的日期不展示；
/// 显示月份由 `monthDate` 决定，更新 `events` 即刷新事项条。
class WSCalendarMonthEventBarView: WSPluginContentView, UIGestureRecognizerDelegate {

    /// 布局尺寸
    private enum Metrics {

        /// 月份标题高度
        static let monthHeaderHeight: CGFloat = 18.0

        /// 月份标题字号
        static let monthFont = UIFont.boldSystemFont(ofSize: 11.0)

        /// 周符号行高度
        static let weekdayHeight: CGFloat = 14.0

        /// 日期头高度
        static let dayHeaderHeight: CGFloat = 16.0
    }

    // MARK: - 显示范围

    /// 显示的月份（当月 1 号）
    private(set) var monthDate: Date?

    /// 当月网格
    private(set) var grid: WSCalendarMonthGrid?

    /// 日期头高度
    var dayHeaderHeight: CGFloat = Metrics.dayHeaderHeight {
        didSet {
            guard dayHeaderHeight != oldValue else {
                return
            }

            weekRows.forEach { $0.dayHeaderHeight = dayHeaderHeight }
            setNeedsLayout()
        }
    }

    // MARK: - 数据

    /// 事项。更新后立即刷新事项条
    var events: [CalendarEvent]? {
        didSet {
            guard events != oldValue else {
                return
            }

            reloadWeeks()
        }
    }

    // MARK: - 交互

    /// 点击事项
    var didSelectEventHandler: ((CalendarEvent) -> Void)?

    /// 点击「更多」
    var didSelectMoreHandler: ((Date) -> Void)?

    /// 点击某一天的区域（日期或事项条空白处）
    var didSelectDateHandler: ((Date) -> Void)?

    // MARK: - 子视图

    /// 月份标题（年 + 月）
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.monthFont
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()

    /// 周符号行
    private let weekdayView = WSCalendarWeekEventBarWeekdayView(frame: .zero)

    /// 每周一行
    private var weekRows: [WSCalendarMonthEventBarRowView] = []

    convenience init(monthDate: Date = Date()) {
        self.init(frame: .zero)
        configure(monthDate: monthDate)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGesture()
        addSubview(monthLabel)
        addSubview(weekdayView)
        apply(monthDate: Date(), force: true)
        reloadWeeks()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 显示范围

    /// 设置显示的月份
    func configure(monthDate: Date) {
        apply(monthDate: monthDate)
        reloadWeeks()
    }

    /// 显示指定日期所在的月份
    func showMonth(containing date: Date = Date()) {
        configure(monthDate: date)
    }

    /// 显示下个月
    func showNextMonth() {
        guard let monthDate = monthDate,
              let nextMonth = monthDate.dateByAddingMonths(1) else {
            return
        }

        configure(monthDate: nextMonth)
    }

    /// 显示上个月
    func showPreviousMonth() {
        guard let monthDate = monthDate,
              let previousMonth = monthDate.dateByAddingMonths(-1) else {
            return
        }

        configure(monthDate: previousMonth)
    }

    // MARK: - 数据

    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)

        guard let dataItem = dataItem as? WSCalendarMonthEventBarDataItem else {
            events = nil
            return
        }

        apply(monthDate: dataItem.monthDate)
        /// 月份变化时事项条已被重置，事项未变也需要重新加载
        if events == dataItem.events {
            reloadWeeks()
        } else {
            events = dataItem.events
        }
    }

    /// 更新月份与网格。月份未变化时不做处理
    private func apply(monthDate: Date, force: Bool = false) {
        let monthDate = monthDate.startOfMonth()
        guard force || monthDate != self.monthDate else {
            return
        }

        self.monthDate = monthDate
        self.grid = WSCalendarMonthGrid(monthDate: monthDate)
        self.monthLabel.text = monthDate.yearMonthString

        setupWeekRows()
        setNeedsLayout()
    }

    // MARK: - 子视图

    /// 按网格行数创建 / 复用每周的行
    private func setupWeekRows() {
        let weekCount = grid?.weekCount ?? 0
        if weekRows.count > weekCount {
            weekRows[weekCount...].forEach { $0.removeFromSuperview() }
            weekRows.removeLast(weekRows.count - weekCount)
        }

        while weekRows.count < weekCount {
            let row = WSCalendarMonthEventBarRowView(frame: .zero)
            row.dayHeaderHeight = dayHeaderHeight
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

    /// 按周分发当月日期与事项
    private func reloadWeeks() {
        guard let grid = grid else {
            weekRows.forEach { $0.update(weekStartDate: nil, days: [], events: []) }
            return
        }

        /// 只展示与当月有交集的事项，避免事项条落在不显示的日期列上
        let monthEvents = (events ?? []).filter {
            return $0.startDate < grid.monthEnd && $0.endDate > grid.monthStart
        }

        for (index, row) in weekRows.enumerated() {
            row.update(weekStartDate: grid.weekStartDate(at: index),
                       days: grid.days(inWeek: index),
                       events: monthEvents)
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

    // MARK: - 手势

    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let date = date(at: gesture.location(in: self)) else {
            return
        }

        guard let didSelectDateHandler = didSelectDateHandler else {
            (interactor as? WSCalendarEventContentInteractor)?.openEventList(on: date)
            return
        }

        didSelectDateHandler(date)
    }

    /// 位置对应的日期（行按周数均分高度，列按 7 天均分宽度）
    private func date(at location: CGPoint) -> Date? {
        guard let grid = grid else {
            return nil
        }

        let frame = layoutFrame()
        let headerHeight = Metrics.monthHeaderHeight + Metrics.weekdayHeight
        let rowsTop = frame.minY + headerHeight
        guard frame.width > 0.0, location.y >= rowsTop else {
            return nil
        }

        let itemWidth = frame.width / CGFloat(DAYS_PER_WEEK)
        let rowHeight = max(frame.height - headerHeight, 0.0) / CGFloat(max(grid.weekCount, 1))
        guard itemWidth > 0.0, rowHeight > 0.0 else {
            return nil
        }

        let rowIndex = min(max(Int((location.y - rowsTop) / rowHeight), 0), grid.weekCount - 1)
        let column = min(max(Int((location.x - frame.minX) / itemWidth), 0), DAYS_PER_WEEK - 1)
        guard let weekStartDate = grid.weekStartDate(at: rowIndex),
              let date = weekStartDate.dateByAddingDays(column),
              date >= grid.monthStart, date < grid.monthEnd else {
            return nil
        }

        return date
    }

    /// 事项条上的点击交给事项条自己处理，其余区域按天打开事项列表
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var hitView = touch.view
        while let view = hitView, view !== self {
            if view is CalendarStripEventView {
                return false
            }

            hitView = view.superview
        }

        /// 只接管能落到具体日期的区域，其余交给面板处理
        return date(at: touch.location(in: self)) != nil
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()

        let frame = layoutFrame()
        guard frame.width > 0.0, frame.height > 0.0 else {
            return
        }

        monthLabel.size = CGSize(width: frame.width, height: Metrics.monthHeaderHeight)
        monthLabel.origin = frame.origin

        weekdayView.size = CGSize(width: frame.width, height: Metrics.weekdayHeight)
        weekdayView.left = frame.minX
        weekdayView.top = frame.minY + Metrics.monthHeaderHeight

        let headerHeight = Metrics.monthHeaderHeight + Metrics.weekdayHeight
        let rowsTop = frame.minY + headerHeight
        let rowsHeight = max(frame.height - headerHeight, 0.0)
        let rowHeight = rowsHeight / CGFloat(max(weekRows.count, 1))
        for (index, row) in weekRows.enumerated() {
            row.size = CGSize(width: frame.width, height: rowHeight)
            row.left = frame.minX
            row.top = rowsTop + CGFloat(index) * rowHeight
        }
    }
}
