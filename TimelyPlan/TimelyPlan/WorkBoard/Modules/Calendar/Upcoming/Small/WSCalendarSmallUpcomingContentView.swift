//
//  WSCalendarSmallUpcomingContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation
import UIKit

/// 日历·小·最近事项：按天分组列出最近的事项，可用高度不足时在底部折叠为「更多」入口。
class WSCalendarSmallUpcomingContentView: WSCalendarEventListView {

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

        /// 底部「更多」入口高度
        static let moreEntryHeight: CGFloat = 16.0
        
        static let moreLeadingInset = 8.0
        
        /// 行内容的上下间距。行高受限，收紧后名称与时间才能完整展示
        static let rowContentInsets = UIEdgeInsets(horizontal: 4.0, vertical: 1.0)
    }

    /// 当前展示的列表数据
    private var dayEvents: WSCalendarDayEventsDataItem?

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
        
        didSelectMoreHandler = { [weak self] section in
            guard let self = self,
                  let day = self.dayEvents?.days[safe: section] else {
                return
            }

            (self.interactor as? WSCalendarUpcomingContentInteractor)?.clickMoreEvents(on: day.date)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 数据
    override var numberOfSections: Int {
        return dayEvents?.days.count ?? 0
    }

    override func numberOfRows(in section: Int) -> Int {
        return rowItems(at: section)?.count ?? 0
    }

    override func headerTitle(at section: Int) -> String? {
        return dayEvents?.days[safe: section]?.title
    }

    override func updateHeaderView(_ headerView: UIView, at section: Int) {
        super.updateHeaderView(headerView, at: section)

        /// 今天的日期头高亮
        let isToday = dayEvents?.days[safe: section]?.date.isToday ?? false
        (headerView as? UILabel)?.textColor = isToday ? .primary : .secondaryLabel
    }

    // MARK: - 行视图
    override func makeRowView(at indexPath: IndexPath) -> WSRowView {
        let rowView = WSCalendarEventRowView()
        rowView.contentInsets = Metrics.rowContentInsets
        return rowView
    }

    override func didAddRowView(_ rowView: WSRowView, at indexPath: IndexPath) {
        (rowView as? WSCalendarEventRowView)?.didSelectEventHandler = { [weak self] dataItem in
            self?.interactor?.performAction(with: dataItem)
        }
    }

    override func updateRowView(_ rowView: WSRowView, at indexPath: IndexPath) {
        guard let item = rowItem(at: indexPath) else {
            return
        }

        (rowView as? WSCalendarEventRowView)?.update(with: item)
    }

    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        dayEvents = dataItem as? WSCalendarDayEventsDataItem
        super.update(with: dataItem)
    }

    // MARK: - 辅助
    private func rowItems(at section: Int) -> [WSCalendarEventRowItem]? {
        return dayEvents?.days[safe: section]?.items
    }

    private func rowItem(at indexPath: IndexPath) -> WSCalendarEventRowItem? {
        return rowItems(at: indexPath.section)?[safe: indexPath.row]
    }
}
