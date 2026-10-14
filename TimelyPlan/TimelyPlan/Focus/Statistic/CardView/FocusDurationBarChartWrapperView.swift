//
//  FocusDurationBarChartWrapperView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/14.
//

import Foundation
import UIKit

/// 专注时长柱状图容器
class FocusDurationBarChartWrapperView: UIView, TPAnimatedContainerViewDelegate {

    // MARK: - 数据

    /// 统计类型
    let type: StatsType

    /// 当前日期
    var date: Date

    /// 周开始日
    let firstWeekday: Weekday

    // MARK: - 子视图

    /// 动画容器
    private let containerView = TPAnimatedContainerView()

    /// 当前显示的柱状图
    private(set) var barChartView: BarChartView!

    // MARK: - 初始化

    init(type: StatsType, date: Date = .now, firstWeekday: Weekday = .firstWeekday) {
        self.type = type
        self.date = date
        self.firstWeekday = firstWeekday
        super.init(frame: .zero)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupSubviews() {
        containerView.delegate = self
        containerView.clipsToBounds = false
        addSubview(containerView)

        let chartView = makeBarChartView()
        barChartView = chartView
        containerView.setContentView(chartView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = bounds
    }

    // MARK: - 创建柱状图

    /// 创建柱状图，并使用占位数据先行绘制
    func makeBarChartView() -> BarChartView {
        let chartView = BarChartView()
        chartView.placeholderView.titleFont = .boldSystemFont(ofSize: 16.0)
        chartView.strokeChart(with: placeholderBarChartItem())
        return chartView
    }

    /// 占位柱状图数据：仅设置坐标轴，不包含实际柱数据
    func placeholderBarChartItem() -> BarChartItem {
        let chartItem = BarChartItem()
        switch type {
        case .day, .week:
            /// 日暂无时长图表，暂与周保持一致
            chartItem.xAxis = .weekDaysAxis(date: date, firstWeekday: firstWeekday)
        case .month:
            chartItem.xAxis = .monthDaysAxis(date: date)
            chartItem.xAxis.guideline?.style = .solid
        case .year:
            chartItem.minimumBarMargin = 8.0
            chartItem.xAxis = .monthsAxis()
        }

        /// 无实际数据时使用默认时长y轴
        chartItem.yAxis = .defaultDurationYAxis
        return chartItem
    }

    // MARK: - 切换柱状图

    /// 切换到新的柱状图视图
    /// - Parameter animateStyle: 切换动画样式，`.none` 表示直接替换不播放动画
    func changeBarChartView(with animateStyle: SlideStyle) {
        let chartView = makeBarChartView()
        barChartView = chartView
        containerView.setContentView(chartView, animateStyle: animateStyle)
    }

    /// 绘制当前显示的柱状图
    func strokeChart(with chartItem: ChartItem) {
        barChartView.strokeChart(with: chartItem)
    }

    // MARK: - TPAnimatedContainerViewDelegate

    func animatedContainerView(_ containerView: TPAnimatedContainerView, frameForContentView contentView: UIView) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 12.0))
    }
}
