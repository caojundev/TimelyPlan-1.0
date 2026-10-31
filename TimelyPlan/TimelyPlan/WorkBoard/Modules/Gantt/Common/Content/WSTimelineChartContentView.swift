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
/// 上方为时间刻度，下方为固定行数的事项区域。组件内不提供日期切换、回到今天与滚动，
/// 展示的内容相当于某个时间段的快照。
final class WSTimelineChartContentView: WSPluginContentView {

    private let headerView = WSTimelineChartHeaderView()
    private let chartView = WSTimelineChartView()

    init(scale: GanttTimeScale.Scale) {
        super.init(frame: .zero)

        /// 数据下发前先按今天铺好刻度，避免首帧空白
        let timeRange = WSTimelineChartTimeRange(scale: scale, date: Date())
        headerView.timeRange = timeRange
        chartView.configure(timeRange: timeRange, events: [])

        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 视图设置

    private func setupViews() {
        addSubview(headerView)
        addSubview(chartView)

        chartView.onEventTap = { [weak self] event in
            (self?.interactor as? WSTimelineChartContentInteractor)?.openEvent(event)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let headerTop = WSTimelineChartConfig.headerTopInset
        let headerHeight = WSTimelineChartConfig.headerHeight

        headerView.frame = CGRect(x: 0.0, y: headerTop, width: width, height: headerHeight)
        chartView.frame = CGRect(x: 0.0,
                                 y: headerTop + headerHeight,
                                 width: width,
                                 height: max(height - headerTop - headerHeight, 0.0))
    }

    // MARK: - 渲染

    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)

        guard let dataItem = dataItem as? WSTimelineChartDataItem else { return }

        headerView.timeRange = dataItem.timeRange
        chartView.configure(timeRange: dataItem.timeRange, events: dataItem.events)

        setNeedsLayout()
    }
}
