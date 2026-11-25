//
//  WSCalendarDayEventBarColumnView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/9.
//

import Foundation
import UIKit

/// 事项条中的一天：上方为周符号，下方为天视图（日、阴历、调休状态）。
///
/// 采用组合而不是继承：`CalendarMonthDayView` 已完成日期渲染，这里只负责在它上方加一行周符号。
class WSCalendarDayEventBarColumnView: UIView {

    /// 布局尺寸
    private enum Metrics {

        /// 周符号字号
        static let weekdayFont = UIFont.systemFont(ofSize: 10.0, weight: .medium)
    }

    /// 周符号行高
    var weekdayHeight: CGFloat = 14.0 {
        didSet {
            guard weekdayHeight != oldValue else {
                return
            }

            setNeedsLayout()
        }
    }

    /// 周符号
    private let weekdayLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.weekdayFont
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        return label
    }()

    /// 天视图：日、阴历、调休状态
    private let dayView = CalendarMonthDayView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(weekdayLabel)
        addSubview(dayView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 数据

    /// 更新周符号与天视图
    func update(with config: CalendarMonthDayConfig) {
        weekdayLabel.text = config.date.shortWeekdaySymbol()
        weekdayLabel.textColor = config.date.isToday ? .primary : .secondaryLabel
        dayView.update(with: config)
    }

    /// 清空展示内容
    func reset() {
        weekdayLabel.text = nil
        dayView.reset()
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()

        guard width > 0.0, height > 0.0 else {
            return
        }

        let weekdayHeight = min(max(self.weekdayHeight, 0.0), height)
        weekdayLabel.size = CGSize(width: width, height: weekdayHeight)
        weekdayLabel.origin = .zero

        /// 天视图占用周符号行以外的全部高度
        let dayViewHeight = max(height - weekdayHeight, 0.0)
        dayView.headerHeight = dayViewHeight
        dayView.size = CGSize(width: width, height: dayViewHeight)
        dayView.left = 0.0
        dayView.top = weekdayHeight
    }
}
