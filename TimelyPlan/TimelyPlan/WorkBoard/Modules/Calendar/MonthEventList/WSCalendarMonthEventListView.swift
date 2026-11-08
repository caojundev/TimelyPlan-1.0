//
//  WSCalendarMonthEventListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

/// 月历 + 事项列表组件右侧的事项列表。
///
/// 按天分组列出本月的事项，行内容只展示时间，尺寸按单列宽度收紧。
class WSCalendarMonthEventListView: WSCalendarUpcomingContentView {

    /// 布局尺寸
    private enum Metrics {

        /// 日期头高度
        static let sectionHeaderHeight: CGFloat = 16.0

        /// 日期头与首行的间距
        static let headerRowSpacing: CGFloat = 4.0

        /// 事项行高度。容纳名称与时间两行（14pt + 12pt）及其间距
        static let rowHeight: CGFloat = 40.0

        /// 事项行间距
        static let rowSpacing: CGFloat = 2.0

        /// 相邻两天的间距
        static let sectionSpacing: CGFloat = 8.0

        /// 「更多」入口高度
        static let moreEntryHeight: CGFloat = 16.0

        /// 行内容的内边距
        static let rowContentInsets = UIEdgeInsets(horizontal: 4.0, vertical: 2.0)

        /// 单列宽度有限，行详情只展示时间
        static let detailOption: CalendarEventDetailOption = .time
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        sectionHeaderHeight = Metrics.sectionHeaderHeight
        headerRowSpacing = Metrics.headerRowSpacing
        rowHeight = Metrics.rowHeight
        rowSpacing = Metrics.rowSpacing
        sectionSpacing = Metrics.sectionSpacing
        moreEntryHeight = Metrics.moreEntryHeight
        rowContentInsets = Metrics.rowContentInsets
        detailOption = Metrics.detailOption
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 空白视图
    /// 本月没有事项时展示空白提示
    override func makeEmptyView() -> WSPluginEmptyPlaceholderView {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.iconName = "calendar"
        configuration.title = resGetString("No Events")
        return WSPluginDefaultEmptyPlaceholderView(configuration: configuration)
    }
}
