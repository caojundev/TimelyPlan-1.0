//
//  WSCalendarMonthEventBarRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/9.
//

import Foundation
import UIKit

/// 月事项条中的一周：日期头只绘制当月的「日」，下方为该周的事项条。
///
/// 月视图每周高度有限，日期头默认只占 18pt；当月之外的日期不展示，
/// 因此首行日期靠右（前面是上月）、末行日期靠左、其余行按列对齐。
class WSCalendarMonthEventBarRowView: UIView, CalendarStripViewDelegate {

    /// 布局尺寸
    private enum Metrics {

        /// 日字号
        static let font = UIFont.systemFont(ofSize: 12.0, weight: .medium)

        /// 列宽放不下时的最小缩放比例
        static let minimumScale: CGFloat = 0.6
    }

    /// 日期头高度
    var dayHeaderHeight: CGFloat = 18.0 {
        didSet {
            guard dayHeaderHeight != oldValue else {
                return
            }

            setNeedsLayout()
            setNeedsDisplay()
        }
    }

    /// 事项条至少保留的高度，行高不足时压缩日期头
    var minimumStripHeight: CGFloat = 16.0 {
        didSet {
            guard minimumStripHeight != oldValue else {
                return
            }

            setNeedsLayout()
            setNeedsDisplay()
        }
    }

    /// 该周的第一天（当天零点）
    private(set) var weekStartDate: Date?

    /// 该周需要展示的当月日期
    private var visibleDays: [Date] = []

    /// 当月第一天在本周中的列
    private var columnOffset: Int = 0

    /// 事项条
    private let stripView = CalendarStripView(days: DAYS_PER_WEEK)

    /// 点击事项
    var didSelectEventHandler: ((CalendarEvent) -> Void)?

    /// 点击「更多」
    var didSelectMoreHandler: ((Date) -> Void)?

    /// 文字居中的段落样式
    private let paragraphStyle: NSParagraphStyle = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byClipping
        return paragraphStyle
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        /// 行高被压缩时裁掉事项条超出的部分
        clipsToBounds = true
        backgroundColor = .clear
        isOpaque = false
        /// 宽度变化后需要按新的列宽重绘日期
        contentMode = .redraw
        stripView.delegate = self
        addSubview(stripView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 数据

    /// 更新该周：周首日、需要展示的当月日期与事项
    func update(weekStartDate: Date?, days: [Date], events: [CalendarEvent]) {
        let weekStartDate = weekStartDate?.startOfDay()
        if self.weekStartDate != weekStartDate || self.visibleDays != days {
            self.weekStartDate = weekStartDate
            self.visibleDays = days
            self.columnOffset = Self.columnOffset(weekStartDate: weekStartDate, firstDay: days.first)

            stripView.startDate = weekStartDate
            stripView.reset()
            setNeedsDisplay()
        }

        stripView.startDate = weekStartDate
        stripView.events = events
        stripView.reloadData()
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()

        guard width > 0.0, height > 0.0 else {
            return
        }

        let headerHeight = self.headerHeight
        stripView.origin = CGPoint(x: 0.0, y: headerHeight)
        stripView.size = CGSize(width: width, height: max(height - headerHeight, 0.0))
    }

    // MARK: - 绘制

    override func draw(_ rect: CGRect) {
        let headerHeight = self.headerHeight
        guard !visibleDays.isEmpty, width > 0.0, headerHeight > 0.0 else {
            return
        }

        let itemWidth = width / CGFloat(DAYS_PER_WEEK)
        guard itemWidth > 0.0 else {
            return
        }

        for (index, date) in visibleDays.enumerated() {
            let column = columnOffset + index
            guard column < DAYS_PER_WEEK else {
                break
            }

            let title = "\(Calendar.current.component(.day, from: date))" as NSString
            let font = fittedFont(for: title, maximumWidth: itemWidth)
            let textHeight = ceil(font.lineHeight)
            let textRect = CGRect(x: CGFloat(column) * itemWidth,
                                  y: (headerHeight - textHeight) / 2.0,
                                  width: itemWidth,
                                  height: textHeight)
            let color: UIColor = date.isToday ? .primary : .label
            title.draw(in: textRect,
                       withAttributes: [.font: font,
                                        .foregroundColor: color,
                                        .paragraphStyle: paragraphStyle])
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        /// 深浅色模式下文字颜色不同，需要重绘
        setNeedsDisplay()
    }

    // MARK: - 辅助

    /// 当前可用的日期头高度
    private var headerHeight: CGFloat {
        return min(max(dayHeaderHeight, 0.0), max(height - minimumStripHeight, 0.0))
    }

    /// 当月第一天在本周中的列
    private static func columnOffset(weekStartDate: Date?, firstDay: Date?) -> Int {
        guard let weekStartDate = weekStartDate, let firstDay = firstDay else {
            return 0
        }

        return min(max(Date.days(fromDate: weekStartDate, toDate: firstDay), 0), DAYS_PER_WEEK - 1)
    }

    /// 列宽放不下时等比缩小字号
    private func fittedFont(for title: NSString, maximumWidth: CGFloat) -> UIFont {
        let font = Metrics.font
        let width = title.size(withAttributes: [.font: font]).width
        guard width > maximumWidth else {
            return font
        }

        let scale = max(maximumWidth / width, Metrics.minimumScale)
        return font.withSize(font.pointSize * scale)
    }

    // MARK: - CalendarStripViewDelegate

    func calendarStripView(_ view: CalendarStripView, didTapEvent event: CalendarEvent) {
        didSelectEventHandler?(event)
    }

    func calendarStripView(_ view: CalendarStripView, didTapMoreOnDate date: Date) {
        didSelectMoreHandler?(date)
    }
}
