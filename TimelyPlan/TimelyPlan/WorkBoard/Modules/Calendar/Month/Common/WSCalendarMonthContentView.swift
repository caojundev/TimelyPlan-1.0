//
//  WSCalendarMonthContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

/// 月历组件的内容视图。
///
/// 横向等分排列若干个月历视图：小尺寸展示一个月，中尺寸左右双月复用同一套排布，
/// 差异只体现在月份数量、间距与内边距上。
class WSCalendarMonthContentView: WSPluginContentView {

    /// 展示的月份数量
    let monthCount: Int

    /// 内容与组件边缘的间距
    var contentInsets = UIEdgeInsets(value: 10.0) {
        didSet {
            padding = contentInsets
            setNeedsLayout()
        }
    }

    /// 月份之间的间距。单月时不生效
    var monthSpacing: CGFloat = 8.0 {
        didSet {
            setNeedsLayout()
        }
    }

    /// 月历视图，顺序与数据条目的月份顺序一致
    private(set) var monthViews: [WSCalendarMonthView] = []

    init(monthCount: Int) {
        self.monthCount = max(monthCount, 1)
        super.init(frame: .zero)

        backgroundColor = WSCalendarMonthAppearance.backColor
        isOpaque = true
        padding = contentInsets

        monthViews = (0..<self.monthCount).map { _ in
            let monthView = WSCalendarMonthView()
            monthView.firstWeekday = CalendarSetting.shared.firstWeekday.rawValue
            /// 点击某天：打开该天的事项列表
            monthView.didSelectDate = { [weak self] date in
                (self?.interactor as? WSCalendarEventContentInteractor)?.openEventList(on: date)
            }

            addSubview(monthView)
            return monthView
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 数据

    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)

        let monthDataItem = dataItem as? WSCalendarMonthDataItem
        for (index, monthView) in monthViews.enumerated() {
            let month = monthDataItem?.months[safe: index]
            monthView.monthDate = month?.monthDate
            monthView.dayEventColors = month?.dayEventColors ?? [:]
            monthView.today = monthDataItem?.today ?? Date()
            monthView.isHidden = month == nil
        }
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()

        let frame = layoutFrame()
        guard frame.width > 0.0, frame.height > 0.0, !monthViews.isEmpty else {
            return
        }

        let count = CGFloat(monthViews.count)
        let spacing = monthSpacing * (count - 1.0)
        let monthWidth = max((frame.width - spacing) / count, 0.0)

        var left = frame.minX
        for monthView in monthViews {
            monthView.size = CGSize(width: monthWidth, height: frame.height)
            monthView.left = left
            monthView.top = frame.minY
            left = monthView.right + monthSpacing
        }
    }
}
