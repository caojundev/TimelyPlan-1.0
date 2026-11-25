//
//  WSCalendarMonthSectionView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

/// 单个月份的展示单元：月历视图 + 事项指示层。
///
/// 两者同尺寸叠放，事项只由指示层绘制，日期绘制不感知事项；
/// 月历组件按月份数量并排使用该单元，月历 + 事项列表组件复用同一个月历。
class WSCalendarMonthSectionView: UIView {

    private let monthView: WSCalendarMonthView
    private let indicatorView: WSCalendarMonthEventIndicatorView

    /// 展示的月份，取该月 1 号
    var monthDate: Date? {
        get {
            return monthView.monthDate
        }

        set {
            monthView.monthDate = newValue
        }
    }

    /// 今天，用于高亮当天
    var today: Date {
        get {
            return monthView.today
        }

        set {
            monthView.today = newValue
        }
    }

    /// 每天的事项指示颜色，key 为日
    var dayEventColors: [Int: [UIColor]] {
        get {
            return indicatorView.dayEventColors
        }

        set {
            indicatorView.dayEventColors = newValue
        }
    }

    /// 是否绘制上月与下月的日期
    var showsAdjacentDays: Bool {
        get {
            return monthView.showsAdjacentDays
        }

        set {
            monthView.showsAdjacentDays = newValue
        }
    }

    /// 最小行数。多个月份并排时统一行数，日期才能左右对齐
    var minimumRowCount: Int {
        get {
            return monthView.minimumRowCount
        }

        set {
            monthView.minimumRowCount = newValue
            /// 行数变化会改变单元格位置，事项指示需要按新网格重绘
            indicatorView.setNeedsDisplay()
        }
    }

    /// 当月占用的周数
    var requiredRowCount: Int {
        return monthView.requiredRowCount
    }

    /// 周开始日，1 = 周日
    var firstWeekday: Int {
        get {
            return monthView.firstWeekday
        }

        set {
            monthView.firstWeekday = newValue
        }
    }

    /// 点击某天
    var didSelectDate: ((Date) -> Void)? {
        get {
            return monthView.didSelectDate
        }

        set {
            monthView.didSelectDate = newValue
        }
    }

    init() {
        let monthView = WSCalendarMonthView()
        self.monthView = monthView
        self.indicatorView = WSCalendarMonthEventIndicatorView(monthView: monthView)

        super.init(frame: .zero)

        monthView.firstWeekday = CalendarSetting.shared.firstWeekday.rawValue

        addSubview(monthView)
        addSubview(indicatorView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        monthView.size = size
        monthView.origin = .zero

        indicatorView.size = monthView.size
        indicatorView.origin = .zero
    }
}
