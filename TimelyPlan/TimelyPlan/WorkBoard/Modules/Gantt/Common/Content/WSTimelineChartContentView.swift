//
//  WSTimelineChartContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

/// 甘特图组件的内容视图
///
/// 顶部为当前年月，中间为时间刻度，下方为固定行数的事项区域。
/// 组件内不提供日期切换、回到今天与滚动，展示的内容相当于某个时间段的快照。
final class WSTimelineChartContentView: WSPluginContentView {

    /// 年月标签字体
    private static let dateFont = UIFont.systemFont(ofSize: 13.0, weight: .semibold)

    /// 年月标签
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = Self.dateFont
        label.textColor = .label
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()

    private let headerView = WSTimelineChartHeaderView()
    private let chartView = WSTimelineChartView()

    init(scale: GanttTimeScale.Scale) {
        super.init(frame: .zero)

        /// 数据下发前先按今天铺好刻度，避免首帧空白
        let timeRange = WSTimelineChartTimeRange(scale: scale, date: Date())
        headerView.timeRange = timeRange
        chartView.configure(timeRange: timeRange, events: [])

        setupViews()
        updateDateLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 视图设置

    private func setupViews() {
        addSubview(dateLabel)
        addSubview(headerView)
        addSubview(chartView)

        chartView.onEventTap = { [weak self] event in
            (self?.interactor as? WSTimelineChartContentInteractor)?.openEvent(event)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let dateHeight = WSTimelineChartConfig.dateHeight
        let headerHeight = WSTimelineChartConfig.headerHeight

        dateLabel.frame = CGRect(x: 0.0, y: 0.0, width: width, height: dateHeight)
        headerView.frame = CGRect(x: 0.0, y: dateHeight, width: width, height: headerHeight)
        chartView.frame = CGRect(x: 0.0,
                                 y: dateHeight + headerHeight,
                                 width: width,
                                 height: max(height - dateHeight - headerHeight, 0.0))
    }

    // MARK: - 渲染

    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)

        /// 跨天刷新时年月也要跟着更新
        updateDateLabel()

        guard let dataItem = dataItem as? WSTimelineChartDataItem else { return }

        headerView.timeRange = dataItem.timeRange
        chartView.configure(timeRange: dataItem.timeRange, events: dataItem.events)

        setNeedsLayout()
    }

    /// 刷新年月标签
    private func updateDateLabel() {
        dateLabel.text = Date().yearMonthString
    }
}
