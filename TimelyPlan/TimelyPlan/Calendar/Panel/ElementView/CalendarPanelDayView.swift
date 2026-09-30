//
//  CalendarPanelDayView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/29.
//

import Foundation
import UIKit

/// 面板天视图：单行靠左显示，依次为日标签、周几标签（调休标签在其右上角），最右侧为农历标签
class CalendarPanelDayView: UIView {
    
    // 日期标签
    let dayLabel: UILabel = {
        let label = TPLabel()
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        label.edgeInsets = UIEdgeInsets(right: 4.0)
        return label
    }()
    
    // 周几标签
    let weekdayLabel: UILabel = {
        let label = TPLabel()
        label.textColor = .secondaryLabel
        label.adjustsFontSizeToFitWidth = true
        label.edgeInsets = UIEdgeInsets(horizontal: 4.0)
        return label
    }()
    
    /// 调休状态标签（周几标签右上角）
    let workStatusLabel: UILabel = {
        let label = TPLabel()
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.adjustsFontSizeToFitWidth = true
        label.edgeInsets = UIEdgeInsets(horizontal: 2.0)
        return label
    }()
    
    // 农历/节假日标签
    let lunarLabel: TPLabel = {
        let label = TPLabel()
        label.edgeInsets = UIEdgeInsets(horizontal: 4.0)
        label.textAlignment = .right
        label.textColor = .gray
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    /// 尺寸信息
    private struct Metric {
        
        /// 内容内边距
        static let padding = UIEdgeInsets(left: 8.0, right: 20.0)
        
        /// 标签之间的间距
        static let labelSpacing = 2.0
        /// 调休标签尺寸（16 x 16）
        static let workStatusSize = CGSize.size(4)
        /// 调休标签相对周几标签顶部下移的距离
        static let workStatusOffset = 2.0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    func setupViews() {
        padding = Metric.padding
        clipsToBounds = true
        addSubview(dayLabel)
        addSubview(weekdayLabel)
        addSubview(lunarLabel)
        addSubview(workStatusLabel)
        configLabels()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutLabels()
    }
    
    func configLabels() {
        dayLabel.font = .boldSystemFont(ofSize: 18.0)
        weekdayLabel.font = .boldSystemFont(ofSize: 12.0)
        lunarLabel.font = .systemFont(ofSize: 12.0, weight: .medium)
        workStatusLabel.font = .boldSystemFont(ofSize: 10.0)
    }
    
    /// 单行排列：日标签、周几标签靠左，农历标签靠右
    func layoutLabels() {
        let layoutFrame = layoutFrame()
        let centerY = layoutFrame.midY
        
        dayLabel.sizeToFit()
        dayLabel.left = layoutFrame.minX
        dayLabel.centerY = centerY
        
        weekdayLabel.sizeToFit()
        weekdayLabel.left = dayLabel.right + Metric.labelSpacing
        weekdayLabel.centerY = centerY
        
        lunarLabel.sizeToFit()
        lunarLabel.left = weekdayLabel.right + Metric.labelSpacing
        lunarLabel.width = max(0.0, layoutFrame.maxX - lunarLabel.left)
        lunarLabel.centerY = centerY
        
        workStatusLabel.size = Metric.workStatusSize
        workStatusLabel.left = layoutFrame.maxX - Metric.workStatusOffset
        workStatusLabel.top = layoutFrame.minY + Metric.workStatusOffset
    }
    
    /// 重置标签数据
    func reset() {
        dayLabel.text = nil
        weekdayLabel.text = nil
        workStatusLabel.text = nil
        lunarLabel.text = nil
    }
    
    /// 更新数据
    func update(with config: CalendarMonthDayConfig) {
        dayLabel.text = config.dayLabelText
        weekdayLabel.text = config.date.shortWeekdaySymbol()
        lunarLabel.text = config.lunarLabelText
        
        if config.date.isToday {
            dayLabel.textColor = .primary
            weekdayLabel.textColor = .primary
            lunarLabel.textColor = .primary
        } else {
            dayLabel.textColor = .label
            weekdayLabel.textColor = .gray
            lunarLabel.textColor = .gray
        }
        
        if config.workStatus == .inWorking {
            workStatusLabel.textColor = Color(0xFF3B30)
        } else if config.workStatus == .onHoliday {
            workStatusLabel.textColor = Color(0x34C759)
        } else {
            workStatusLabel.textColor = .gray
        }
        
        workStatusLabel.text = config.workStatusLabelText
        setNeedsLayout()
    }
}
