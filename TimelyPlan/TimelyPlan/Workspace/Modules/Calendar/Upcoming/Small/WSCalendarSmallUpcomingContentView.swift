//
//  WSCalendarSmallUpcomingContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation
import UIKit

/// 日历·小·最近事项：紧凑尺寸的最近事项列表，行详情只展示时间。
class WSCalendarSmallUpcomingContentView: WSCalendarUpcomingContentView {

    /// 布局尺寸
    private enum Metrics {

        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 4.0)

        /// 日期头高度
        static let sectionHeaderHeight: CGFloat = 20.0

        /// 日期头与首行的间距
        static let headerRowSpacing: CGFloat = 4.0

        /// 事项行高度，容纳名称与时间两行
        static let rowHeight: CGFloat = 36.0

        /// 事项行间距
        static let rowSpacing: CGFloat = 2.0

        /// 相邻两天的间距
        static let sectionSpacing: CGFloat = 6.0

        /// 「更多」入口高度
        static let moreEntryHeight: CGFloat = 16.0

        /// 「更多」入口的左缩进
        static let moreLeadingInset: CGFloat = 8.0

        /// 行内容的上下间距。行高受限，收紧后名称与时间才能完整展示
        static let rowContentInsets = UIEdgeInsets(horizontal: 4.0, vertical: 1.0)

        /// 行详情只展示时间，小尺寸不展示来源
        static let detailOption: CalendarEventDetailOption = .time
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.padding = Metrics.padding
        sectionHeaderHeight = Metrics.sectionHeaderHeight
        headerRowSpacing = Metrics.headerRowSpacing
        rowHeight = Metrics.rowHeight
        rowSpacing = Metrics.rowSpacing
        sectionSpacing = Metrics.sectionSpacing
        moreEntryHeight = Metrics.moreEntryHeight
        moreLeadingInset = Metrics.moreLeadingInset
        rowContentInsets = Metrics.rowContentInsets
        detailOption = Metrics.detailOption
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
