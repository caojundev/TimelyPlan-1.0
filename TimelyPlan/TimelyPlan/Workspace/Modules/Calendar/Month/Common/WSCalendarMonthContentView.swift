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
/// 横向等分排列若干个月份展示单元：小尺寸展示一个月，中尺寸左右双月复用同一套排布，
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

    /// 是否绘制上月与下月的日期
    var showsAdjacentDays: Bool = true {
        didSet {
            for monthSection in monthSections {
                monthSection.showsAdjacentDays = showsAdjacentDays
            }
        }
    }

    /// 月份展示单元，顺序与数据条目的月份顺序一致
    private(set) var monthSections: [WSCalendarMonthSectionView] = []

    init(monthCount: Int) {
        self.monthCount = max(monthCount, 1)
        super.init(frame: .zero)

        backgroundColor = WSCalendarMonthAppearance.backColor
        isOpaque = true
        padding = contentInsets

        monthSections = (0..<self.monthCount).map { _ in
            let monthSection = WSCalendarMonthSectionView()
            monthSection.showsAdjacentDays = showsAdjacentDays
            /// 点击某天：打开该天的事项列表
            monthSection.didSelectDate = { [weak self] date in
                (self?.interactor as? WSCalendarEventContentInteractor)?.openEventList(on: date)
            }

            addSubview(monthSection)
            return monthSection
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 数据

    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)

        let monthDataItem = dataItem as? WSCalendarMonthDataItem
        for (index, monthSection) in monthSections.enumerated() {
            let month = monthDataItem?.months[safe: index]
            monthSection.monthDate = month?.monthDate
            monthSection.today = monthDataItem?.today ?? Date()
            monthSection.dayEventColors = month?.dayEventColors ?? [:]
            monthSection.isHidden = month == nil
        }

        /// 多个月份并排时统一行数，左右两侧的日期行高与位置一致
        let rowCount = monthSections.map { $0.requiredRowCount }.max() ?? 0
        for monthSection in monthSections {
            monthSection.minimumRowCount = rowCount
        }
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()

        let frame = layoutFrame()
        guard frame.width > 0.0, frame.height > 0.0, !monthSections.isEmpty else {
            return
        }

        let count = CGFloat(monthSections.count)
        let spacing = monthSpacing * (count - 1.0)
        let monthWidth = max((frame.width - spacing) / count, 0.0)

        var left = frame.minX
        for monthSection in monthSections {
            monthSection.size = CGSize(width: monthWidth, height: frame.height)
            monthSection.left = left
            monthSection.top = frame.minY
            left = monthSection.right + monthSpacing
        }
    }
}
