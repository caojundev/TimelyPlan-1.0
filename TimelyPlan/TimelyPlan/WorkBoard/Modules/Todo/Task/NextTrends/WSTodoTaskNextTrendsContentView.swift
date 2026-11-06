//
//  WSTodoTaskNextTrendsContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 待办接下来七天组件的内容视图。
///
/// 顶部为图标标题与七天任务总数，下方为从今天开始的七天负载柱状图，
/// 底部展示最忙的一天与当天的任务数目。
class WSTodoTaskNextTrendsContentView: WSIconInfoTextValueContentView {

    /// 布局尺寸
    private enum Metrics {

        /// 标题图标与标题颜色
        static let titleIcon = TPIcon(name: "todo_smartlist_upcoming_24")
        static let titleColor = Color(0x00A6A6)

        /// 柱条颜色
        static let barColor: UIColor = .primary
        static let barSpacing: CGFloat = 8.0

        /// 柱状图的最大高度，含底部的日期
        static let maximumActivityHeight: CGFloat = 72.0

        /// 柱条下方日期字体
        static let labelFont = UIFont.systemFont(ofSize: 10.0)

        /// 说明文字字体及其与柱状图的间距
        static let summaryFont = UIFont.systemFont(ofSize: 11.0, weight: .medium)
        static let summarySpacing: CGFloat = 4.0
    }

    /// 七天负载柱状图
    private let activityView = WSWeekActivityView()

    /// 最忙一天与任务数目的说明
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.summaryFont
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        activityView.progressColor = Metrics.barColor
        activityView.barSpacing = Metrics.barSpacing
        activityView.labelFont = Metrics.labelFont
        // 柱条下方展示日期
        activityView.labelText = { "\($0.day)" }
        // 第一根柱条即今天
        activityView.highlightIndex = 0

        addSubview(activityView)
        addSubview(summaryLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 数据
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)

        guard let dataItem = dataItem as? WSTodoTaskNextTrendsDataItem else {
            updateHeader(title: resGetString("Upcoming"),
                         icon: Metrics.titleIcon,
                         iconBackColor: Metrics.titleColor,
                         count: 0)
            activityView.startDate = nil
            activityView.dailyActivity = nil
            summaryLabel.text = nil
            return
        }

        updateHeader(title: resGetString("Upcoming"),
                     icon: Metrics.titleIcon,
                     iconBackColor: Metrics.titleColor,
                     count: dataItem.totalCount)
        activityView.startDate = dataItem.startDate
        activityView.dailyActivity = dataItem.dailyActivity
        summaryLabel.text = summaryText(for: dataItem)
    }

    /// 说明文字：最忙的星期 + 当天任务数目
    private func summaryText(for dataItem: WSTodoTaskNextTrendsDataItem) -> String {
        guard let busiestDay = dataItem.busiestDay else {
            return resGetString("No Task")
        }

        let busiestTitle = String(format: resGetString("%@ busiest"), busiestDay.date.shortWeekdaySymbol())
        let countUnit = resGetString(busiestDay.count == 1 ? "Item(count)" : "Items(count)")
        return "\(busiestTitle) · \(busiestDay.count) \(countUnit)"
    }

    // MARK: - 布局
    override func layoutContent(in frame: CGRect) {
        guard frame.width > 0.0, frame.height > 0.0 else {
            return
        }

        let summaryHeight = ceil(Metrics.summaryFont.lineHeight)
        let availableHeight = max(frame.height - summaryHeight - Metrics.summarySpacing, 0.0)
        let activityHeight = min(availableHeight, Metrics.maximumActivityHeight)
        let summaryY = frame.maxY - summaryHeight

        summaryLabel.frame = CGRect(x: frame.minX,
                                    y: summaryY,
                                    width: frame.width,
                                    height: summaryHeight)
        activityView.frame = CGRect(x: frame.minX,
                                    y: summaryY - Metrics.summarySpacing - activityHeight,
                                    width: frame.width,
                                    height: activityHeight)
    }
}
