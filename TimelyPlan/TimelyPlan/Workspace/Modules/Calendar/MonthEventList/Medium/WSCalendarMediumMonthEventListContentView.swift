//
//  WSCalendarMediumMonthEventListContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

/// 日历·中·月历与事项列表：左侧本月月历，右侧本月的事项列表，各占一半宽度。
class WSCalendarMediumMonthEventListContentView: WSPluginContentView {

    /// 布局尺寸
    private enum Metrics {

        /// 内容与组件边缘的间距
        static let contentInsets = UIEdgeInsets(value: 10.0)

        /// 月历与列表之间的间距
        static let spacing: CGFloat = 12.0
    }

    /// 左侧月历
    private let monthSection = WSCalendarMonthSectionView()

    /// 右侧事项列表
    private let eventListView = WSCalendarMonthEventListView(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = WSCalendarMonthAppearance.backColor
        isOpaque = true
        padding = Metrics.contentInsets

        /// 点击月历中的某天：打开该天的事项列表
        monthSection.didSelectDate = { [weak self] date in
            (self?.interactor as? WSCalendarEventContentInteractor)?.openEventList(on: date)
        }

        addSubview(monthSection)
        addSubview(eventListView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 数据

    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)

        let monthItem = dataItem as? WSCalendarMonthEventListDataItem
        monthSection.monthDate = monthItem?.monthDate
        monthSection.today = monthItem?.today ?? Date()
        monthSection.dayEventColors = monthItem?.dayEventColors ?? [:]

        /// 列表内的行点击与「更多」入口都经由交互器处理
        eventListView.interactor = interactor
        eventListView.update(with: monthItem?.dayEvents)
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()

        let frame = layoutFrame()
        guard frame.width > 0.0, frame.height > 0.0 else {
            return
        }

        let monthWidth = floor((frame.width - Metrics.spacing) / 2.0)

        monthSection.size = CGSize(width: monthWidth, height: frame.height)
        monthSection.left = frame.minX
        monthSection.top = frame.minY

        eventListView.size = CGSize(width: frame.width - monthWidth - Metrics.spacing,
                                    height: frame.height)
        eventListView.left = monthSection.right + Metrics.spacing
        eventListView.top = frame.minY
    }
}
