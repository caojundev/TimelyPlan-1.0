//
//  WSTodoTaskNextTrendsActivityView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 七天负载柱状图与说明

/// 待办接下来七天组件的负载柱状图与说明，各尺寸共用。
///
/// 柱条下方展示日期；底部展示最忙的一天与当天的任务数目。
/// 柱状图高度受限，超出部分留白，保证不同尺寸下的观感一致。
class WSTodoTaskNextTrendsActivityView: UIView {

    /// 样式尺寸
    private enum Metrics {

        /// 柱条颜色与间距
        static let barColor: UIColor = .primary
        static let barSpacing: CGFloat = 8.0

        /// 柱条下方日期字体
        static let labelFont = UIFont.systemFont(ofSize: 10.0)

        /// 柱状图的最大高度
        static let maximumChartHeight: CGFloat = 86.0

        /// 说明文字字体及其与柱状图的间距
        static let summaryFont = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        static let summarySpacing: CGFloat = 4.0
    }

    /// 七天负载柱状图
    private let chartView: WSWeekActivityView = {
        let view = WSWeekActivityView()
        view.progressColor = Metrics.barColor
        view.barSpacing = Metrics.barSpacing
        view.labelFont = Metrics.labelFont
        // 柱条下方展示日期
        view.labelText = { "\($0.day)" }
        return view
    }()

    /// 最忙一天与任务数目的说明
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.summaryFont
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.numberOfLines = 2
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(chartView)
        addSubview(summaryLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 数据
    /// 更新负载与说明。传 nil 时清空
    func update(with dataItem: WSTodoTaskNextTrendsDataItem?) {
        chartView.startDate = dataItem?.startDate
        chartView.dailyActivity = dataItem?.dailyActivity
        summaryLabel.text = dataItem.map { summaryText(for: $0) }
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
    override func layoutSubviews() {
        super.layoutSubviews()

        let contentFrame = layoutFrame()
        guard contentFrame.width > 0.0, contentFrame.height > 0.0 else {
            return
        }

        let summaryHeight = ceil(Metrics.summaryFont.lineHeight) * 2.0
        let availableHeight = max(contentFrame.height - summaryHeight - Metrics.summarySpacing, 0.0)
        let chartHeight = min(availableHeight, Metrics.maximumChartHeight)
        let summaryY = contentFrame.maxY - summaryHeight

        summaryLabel.frame = CGRect(x: contentFrame.minX,
                                    y: summaryY,
                                    width: contentFrame.width,
                                    height: summaryHeight)
        chartView.frame = CGRect(x: contentFrame.minX,
                                 y: summaryY - Metrics.summarySpacing - chartHeight,
                                 width: contentFrame.width,
                                 height: chartHeight)
    }
}
