//
//  WSCalendarWeekEventBarRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/9.
//

import Foundation
import UIKit

/// 周事项条中的一周：顶部 7 个天视图（日、阴历、调休），下方为该周的事项条。
class WSCalendarWeekEventBarRowView: UIView, CalendarStripViewDelegate {

    /// 天视图行高
    var headerHeight: CGFloat = 36.0 {
        didSet {
            guard headerHeight != oldValue else {
                return
            }

            setNeedsLayout()
        }
    }

    /// 事项条至少保留的高度，行高不足时压缩天视图行
    var minimumStripHeight: CGFloat = 24.0 {
        didSet {
            guard minimumStripHeight != oldValue else {
                return
            }

            setNeedsLayout()
        }
    }

    /// 该周的第一天（当天零点）
    private(set) var startDate: Date?

    /// 天视图
    private var dayViews: [CalendarMonthDayView] = []

    /// 事项条
    private let stripView = CalendarStripView(days: DAYS_PER_WEEK)

    /// 点击事项
    var didSelectEventHandler: ((CalendarEvent) -> Void)?

    /// 点击「更多」
    var didSelectMoreHandler: ((Date) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        /// 行高被压缩时裁掉事项条超出的部分，避免压到下一行
        clipsToBounds = true
        stripView.delegate = self
        addSubview(stripView)
        setupDayViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupDayViews() {
        for _ in 0..<DAYS_PER_WEEK {
            let dayView = CalendarMonthDayView()
            addSubview(dayView)
            dayViews.append(dayView)
        }
    }

    // MARK: - 数据

    /// 更新该周的第一天与事项
    func update(startDate: Date?, events: [CalendarEvent]) {
        let startDate = startDate?.startOfDay()
        if self.startDate != startDate {
            self.startDate = startDate
            dayViews.forEach { $0.reset() }
            stripView.startDate = startDate
            stripView.reset()
        }

        stripView.startDate = startDate
        stripView.events = events
        stripView.reloadData()
    }

    /// 更新天视图的日、阴历与调休状态
    func update(configs: [CalendarMonthDayConfig]) {
        for (index, dayView) in dayViews.enumerated() {
            guard let config = configs[safe: index] else {
                dayView.reset()
                continue
            }

            dayView.update(with: config)
        }
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()

        guard width > 0.0, height > 0.0 else {
            return
        }

        /// 行高不足时让出事项条的空间，避免日期行占满整行
        let headerHeight = min(max(self.headerHeight, 0.0), max(height - minimumStripHeight, 0.0))
        let itemWidth = width / CGFloat(DAYS_PER_WEEK)
        for (index, dayView) in dayViews.enumerated() {
            dayView.headerHeight = headerHeight
            dayView.size = CGSize(width: itemWidth, height: headerHeight)
            dayView.left = CGFloat(index) * itemWidth
            dayView.top = 0.0
        }

        stripView.origin = CGPoint(x: 0.0, y: headerHeight)
        stripView.size = CGSize(width: width, height: max(height - headerHeight, 0.0))
    }

    // MARK: - CalendarStripViewDelegate

    func calendarStripView(_ view: CalendarStripView, didTapEvent event: CalendarEvent) {
        didSelectEventHandler?(event)
    }

    func calendarStripView(_ view: CalendarStripView, didTapMoreOnDate date: Date) {
        didSelectMoreHandler?(date)
    }
}
