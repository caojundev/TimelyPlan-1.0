//
//  CalendarWeekSingleDayView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/11.
//

import Foundation
import UIKit

class CalendarWeekSingleDayView: UIView {

    private let weekSymbolLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12.0)
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    // 阳历日期标签
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20.0)
        label.textAlignment = .left
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
     
    // 阴历/节假日标签
    private let lunarLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10.0)
        label.textAlignment = .left
        label.textColor = .gray
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    /// 调休状态
    private let workStatusLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.boldSystemFont(ofSize: 8.0)
        label.textAlignment = .left
        label.textColor = .tertiaryLabel
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        self.padding = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 5.0)
        addSubview(weekSymbolLabel)
        addSubview(dayLabel)
        addSubview(lunarLabel)
        addSubview(workStatusLabel)
    }
           
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = layoutFrame()
        weekSymbolLabel.width = layoutFrame.width
        weekSymbolLabel.height = 20.0
        weekSymbolLabel.origin = layoutFrame.origin
        
        dayLabel.width = layoutFrame.width
        dayLabel.sizeToFit()
        dayLabel.height = 30.0
        dayLabel.top = weekSymbolLabel.bottom
        dayLabel.left = layoutFrame.minX
        
        workStatusLabel.size = .size(6)
        workStatusLabel.left = dayLabel.right + 5.0
        workStatusLabel.bottom = dayLabel.bottom
        
        lunarLabel.width = layoutFrame.width
        lunarLabel.height = 20.0
        lunarLabel.top = dayLabel.bottom
        lunarLabel.left = layoutFrame.minX
    }
    
    /// 重置标签数据
    func reset() {
        weekSymbolLabel.text = nil
        dayLabel.text = nil
        lunarLabel.text = nil
        workStatusLabel.text = nil
    }
    
    /// 更新数据
    func update(with config: CalendarMonthDayConfig) {
        weekSymbolLabel.text = config.date.weekdaySymbol(style: .short)
        dayLabel.text = config.dayLabelText
        lunarLabel.text = config.lunarLabelText

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
