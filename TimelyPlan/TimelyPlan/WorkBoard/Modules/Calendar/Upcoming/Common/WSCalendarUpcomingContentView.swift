//
//  WSCalendarUpcomingContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation
import UIKit

/// 日历·最近事项的内容视图基类，各尺寸共用。
///
/// 按天分组列出最近的事项，可用高度不足时紧接在最后一行之后折叠为「更多」入口；
/// 尺寸参数、行内容边距与行详情展示项由子类指定。
class WSCalendarUpcomingContentView: WSCalendarEventListView {

    /// 行内容的内边距。行视图首次创建时生效
    var rowContentInsets: UIEdgeInsets = UIEdgeInsets(value: 4.0)

    /// 行详情展示项，默认时间与来源都展示
    var detailOption: CalendarEventDetailOption = .all

    /// 当前展示的列表数据
    private var dayEvents: WSCalendarDayEventsDataItem?

    override init(frame: CGRect) {
        super.init(frame: frame)

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
        return events(at: section)?.count ?? 0
    }

    override func headerTitle(at section: Int) -> String? {
        guard let date = dayEvents?.days[safe: section]?.date else {
            return nil
        }

        return headerText(for: date)
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
        rowView.contentInsets = rowContentInsets
        return rowView
    }

    override func didAddRowView(_ rowView: WSRowView, at indexPath: IndexPath) {
        (rowView as? WSCalendarEventRowView)?.didSelectEventHandler = { [weak self] dataItem in
            self?.interactor?.performAction(with: dataItem)
        }
    }

    override func updateRowView(_ rowView: WSRowView, at indexPath: IndexPath) {
        guard let rowView = rowView as? WSCalendarEventRowView,
              let item = rowItem(at: indexPath) else {
            return
        }

        rowView.update(with: item)
    }

    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        dayEvents = dataItem as? WSCalendarDayEventsDataItem
        super.update(with: dataItem)
    }

    // MARK: - 辅助
    private func events(at section: Int) -> [CalendarEvent]? {
        return dayEvents?.days[safe: section]?.events
    }

    /// 行数据在绑定时生成，详情由详情供应工具按展示日期实时计算
    private func rowItem(at indexPath: IndexPath) -> WSCalendarEventRowItem? {
        guard let day = dayEvents?.days[safe: indexPath.section],
              let event = day.events[safe: indexPath.row] else {
            return nil
        }

        return WSCalendarEventRowItem(event: event,
                                      date: day.date,
                                      detailOption: detailOption)
    }

    /// 日期头文案：今天与明天用相对日期，其余展示月日与星期
    private func headerText(for date: Date) -> String {
        if date.isToday {
            return resGetString("Today")
        }

        if date.isTomorrow {
            return resGetString("Tomorrow")
        }

        return date.monthDayShortWeekdaySymbolString
    }
}
