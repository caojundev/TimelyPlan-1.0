//
//  WSCalendarLargeUpcomingContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation
import UIKit

/// 日历·大·最近事项：按天分组的最近事项列表，行详情展示时间与来源。
class WSCalendarLargeUpcomingContentView: WSCalendarUpcomingContentView {

    /// 布局尺寸
    private enum Metrics {

        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 10.0)

        /// 日期头高度
        static let sectionHeaderHeight: CGFloat = 22.0

        /// 日期头与首行的间距
        static let headerRowSpacing: CGFloat = 6.0

        /// 事项行高度，容纳名称与详情两行
        static let rowHeight: CGFloat = 44.0

        /// 事项行间距
        static let rowSpacing: CGFloat = 4.0

        /// 相邻两天的间距
        static let sectionSpacing: CGFloat = 10.0

        /// 「更多」入口高度
        static let moreEntryHeight: CGFloat = 18.0

        /// 「更多」入口的左缩进，与行内名称对齐
        static let moreLeadingInset: CGFloat = 10.0

        /// 行内容的内边距
        static let rowContentInsets = UIEdgeInsets(horizontal: 8.0, vertical: 4.0)

        /// 行详情展示时间与来源
        static let detailOption: CalendarEventDetailOption = .all
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
