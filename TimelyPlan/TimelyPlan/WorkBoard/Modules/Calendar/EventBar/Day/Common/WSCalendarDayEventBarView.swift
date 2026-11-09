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
/// 显示范围由 `startDate` 与 `dayCount` 决定（如今天开始的若干天、整周），
/// 外部更新 `events` 即刷新事项条；顶部为每列对应的日期头，可关闭。
class WSCalendarDayEventBarView: WSPluginContentView, CalendarStripViewDelegate {

    /// 布局尺寸
    private enum Metrics {

        /// 日期头高度
        static let headerHeight: CGFloat = 18.0
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

    /// 是否显示日期头
    var showsDayHeader: Bool = true {
        didSet {
            guard showsDayHeader != oldValue else {
                return
            }

            updateDayHeader()
            setNeedsLayout()
        }
    }

    /// 日期头高度。日期头关闭时不占高度
    var dayHeaderHeight: CGFloat = Metrics.headerHeight {
        didSet {
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

    /// 日期头。所有日期一次绘制，避免每天一个标签
    private let headerView = WSCalendarDayEventBarHeaderView()

    convenience init(startDate: Date = Date(), dayCount: Int = DAYS_PER_WEEK) {
        self.init(frame: .zero)
        configure(startDate: startDate, dayCount: dayCount)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(headerView)
        setupStripView()
        updateDayHeader()
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
            setupStripView()
        }

        stripView?.startDate = startDate
        stripView?.reset()
        updateDayHeader()
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

    // MARK: - 日期头

    /// 同步日期头的显隐与日期
    private func updateDayHeader() {
        headerView.isHidden = !showsDayHeader
        headerView.days = days
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()

        let frame = layoutFrame()
        guard frame.width > 0.0, frame.height > 0.0 else {
            return
        }

        let headerHeight = showsDayHeader ? min(max(dayHeaderHeight, 0.0), frame.height) : 0.0
        let headerFrame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: headerHeight)
        if headerView.frame != headerFrame {
            headerView.frame = headerFrame
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

// MARK: - 日期头

/// 事项条的日期头：所有日期在一次绘制中完成，替代「每天一个标签」，减少图层与子视图。
///
/// 只在一层内绘制文字，宽度变化、日期变化与深浅色切换时重绘。
class WSCalendarDayEventBarHeaderView: UIView {

    /// 布局尺寸
    private enum Metrics {

        /// 日期字号
        static let font = UIFont.systemFont(ofSize: 10.0, weight: .medium)

        /// 列宽放不下时的最小缩放比例
        static let minimumScale: CGFloat = 0.6

        /// 今天的文字颜色：日历红
        static let todayTextColor = Color(0xE8362C)
    }

    /// 显示的日期
    var days: [Date] = [] {
        didSet {
            guard days != oldValue else {
                return
            }

            setNeedsDisplay()
        }
    }

    /// 文字居中的段落样式
    private let paragraphStyle: NSParagraphStyle = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byClipping
        return paragraphStyle
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        isUserInteractionEnabled = false
        /// 宽度变化后需要按新的列宽重新绘制
        contentMode = .redraw
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard !days.isEmpty, bounds.width > 0.0, bounds.height > 0.0 else {
            return
        }

        let itemWidth = bounds.width / CGFloat(days.count)
        guard itemWidth > 0.0 else {
            return
        }

        let today = Date.startOfToday
        for (index, date) in days.enumerated() {
            let title = "\(date.shortWeekdaySymbol()) \(Calendar.current.component(.day, from: date))"
            let color: UIColor = date.isInSameDayAs(today) ? Metrics.todayTextColor : .secondaryLabel
            let font = fittedFont(for: title, maximumWidth: itemWidth)
            let attributes: [NSAttributedString.Key: Any] = [.font: font,
                                                             .foregroundColor: color,
                                                             .paragraphStyle: paragraphStyle]
            let textHeight = ceil(font.lineHeight)
            let textRect = CGRect(x: CGFloat(index) * itemWidth,
                                  y: (bounds.height - textHeight) / 2.0,
                                  width: itemWidth,
                                  height: textHeight)
            (title as NSString).draw(in: textRect, withAttributes: attributes)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        /// 深浅色模式下文字颜色不同，需要重绘
        setNeedsDisplay()
    }

    /// 列宽放不下时等比缩小字号，避免文字超出所属的列
    private func fittedFont(for title: String, maximumWidth: CGFloat) -> UIFont {
        let font = Metrics.font
        let width = (title as NSString).size(withAttributes: [.font: font]).width
        guard width > maximumWidth else {
            return font
        }

        let scale = max(maximumWidth / width, Metrics.minimumScale)
        return font.withSize(font.pointSize * scale)
    }
}
