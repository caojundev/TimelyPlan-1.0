//
//  FocusDurationChartContainerView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/14.
//

import Foundation
import UIKit

/// 专注时长图表容器视图
///
class FocusDurationChartContainerView: UIView, TPPreviousNextDateViewDelegate {
    
    enum Metrics {
        static let dateViewHeight = 40.0
    }
    
    /// 周开始日
    private(set) var firstWeekday: Weekday = .firstWeekday

    /// 统计类型
    private(set) var type: StatsType = .week

    /// 当前选中日期
    private(set) var date: Date
    
    /// 当前日期范围
    private(set) var dateRange: DateRange
    
    /// 前后日期视图
    private(set) var dateView: TPPreviousNextDateView
    
    /// 数据提供者
    weak var provider: FocusDurationDataProvider? {
        didSet {
            guard provider !== oldValue else {
                return
            }
            
            /// 监听专注会话变化
            oldValue?.onSessionChanged = nil
            provider?.onSessionChanged = { [weak self] intervals in
                self?.sessionDidChange(intervals)
            }
            
            /// 数据源变化后重新获取数据
            reloadChartItem()
        }
    }
    
    /// 柱状图视图
    lazy var barChartWrapperView = FocusDurationBarChartWrapperView(type: type,
                                                            date: date,
                                                            firstWeekday: firstWeekday)
    
    init(type: StatsType, date: Date = .now, firstWeekday: Weekday = .firstWeekday) {
        self.type = type
        self.date = date
        self.firstWeekday = firstWeekday
        switch type {
        case .day:
            self.dateView = TPPreviousNextDayView()
        case .week:
            self.dateView = TPPreviousNextWeekView(firstWeekday: firstWeekday)
        case .month:
            self.dateView = TPPreviousNextMonthView()
        case .year:
            self.dateView = TPPreviousNextYearView()
        }
        
        self.dateView.date = date
        self.dateRange = self.dateView.dateRange
        super.init(frame: .zero)
        self.dateView.delegate = self
        
        addSubview(dateView)
        addSubview(barChartWrapperView)
        reloadChartItem()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0.0 else {
            return
        }
        
        /// 日期视图
        dateView.width = width
        dateView.height = Metrics.dateViewHeight
        dateView.top = 0.0
        
        /// 柱状图视图
        barChartWrapperView.frame = CGRect(x: 0.0,
                                           y: dateView.bottom,
                                           width: width,
                                           height: max(height - dateView.bottom, 0.0))
    }
    
    // MARK: - 绘制图表
    
    /// 重新绘制柱状图：切换到新的柱状图后异步获取并绘制数据
    /// - Parameter animateStyle: 切换柱状图的动画样式，`.none` 表示直接替换不播放动画
    func reloadChart(animateStyle: SlideStyle = .none) {
        barChartWrapperView.changeBarChartView(with: animateStyle)
        reloadChartItem()
    }
    
    /// 异步获取并绘制当前日期范围对应的柱状图数据
    func reloadChartItem() {
        let dateRange = self.dateRange
        fetchBarChartItem { [weak self] chartItem in
            guard let self = self,
                  dateRange == self.dateRange,
                  let chartItem = chartItem else {
                /// 日期范围已变化或暂无数据，保留占位图表
                return
            }
            
            self.barChartWrapperView.strokeChart(with: chartItem)
        }
    }
    
    /// 专注会话发生变化：与当前统计范围有交集时重新加载数据
    private func sessionDidChange(_ intervals: [DateInterval]) {
        guard intervals.count > 0 else {
            return
        }
        
        let range = dateRange.interval
        let intersects = intervals.contains { interval in
            return interval.intersects(range)
        }
        guard intersects else {
            return
        }
        
        reloadChartItem()
    }
    
    /// 通过数据提供者异步获取柱状图数据，无数据时返回 `nil` 以保留占位图表
    func fetchBarChartItem(completion: @escaping (BarChartItem?) -> Void) {
        guard let provider = provider else {
            completion(nil)
            return
        }
        
        provider.fetchFocusStatsDataItem(dateRange: dateRange) { [weak self] dataItem in
            guard let self = self else {
                completion(nil)
                return
            }
            
            completion(self.barChartItem(with: dataItem))
        }
    }
    
    /// 将统计数据解析为时长柱状图数据
    func barChartItem(with dataItem: FocusStatsDataItem) -> BarChartItem {
        let chartItem = BarChartItem()
        let barMarks: [ChartMark]
        switch type {
        case .day, .week:
            /// 日暂无时长图表，暂与周保持一致
            barMarks = dataItem.durationChartMarks(xValueForDate: { date in
                return CGFloat(date.weekIndex(firstWeekday: self.firstWeekday))
            })
            chartItem.xAxis = .weekDaysAxis(date: date, firstWeekday: firstWeekday)
        case .month:
            barMarks = dataItem.durationChartMarks(xValueForDate: { date in
                return CGFloat(date.day)
            })
            chartItem.xAxis = .monthDaysAxis(date: date)
            chartItem.xAxis.guideline?.style = .solid
        case .year:
            barMarks = dataItem.monthDurationChartMarks()
            chartItem.minimumBarMargin = 8.0
            chartItem.xAxis = .monthsAxis()
        }
        
        chartItem.barMarks = barMarks
        if barMarks.count > 0 {
            chartItem.yAxis = .yAxisWithGuideline(chartMarks: barMarks) { value in
                return Duration(value).title
            }
        } else {
            chartItem.yAxis = .defaultDurationYAxis
        }
        
        return chartItem
    }
    
    // MARK: - TPPreviousNextDateViewDelegate
    func prviousNextDateView(_ view: TPPreviousNextDateView, didSelectDate date: Date) {
        self.selectDate(date, from: self.date)
    }
    
    private func selectDate(_ date: Date, from oldDate: Date) {
        self.date = date
        let newDateRange = Self.dateRange(of: self.type,
                                          date: date,
                                          firstWeekday: self.firstWeekday)
        guard newDateRange != self.dateRange else {
            /// 范围相同不更新数据
            return
        }
        
        self.dateRange = newDateRange
        /// 同步日期，保证新柱状图的坐标轴与当前周期一致
        barChartWrapperView.date = date
        let animateStyle: SlideStyle = .horizontalStyle(fromValue: oldDate, toValue: date)
        self.reloadChart(animateStyle: animateStyle)
    }

    // MARK: - helpers
    static func dateRange(of type: StatsType, date: Date, firstWeekday: Weekday)-> DateRange {
        switch type {
        case .day:
            return date.rangeOfThisDay()
        case .week:
            return date.rangeOfThisWeek(firstWeekday: firstWeekday)
        case .month:
            return date.rangeOfThisMonth()
        case .year:
            return date.rangeOfThisYear()
        }
    }
    
}
