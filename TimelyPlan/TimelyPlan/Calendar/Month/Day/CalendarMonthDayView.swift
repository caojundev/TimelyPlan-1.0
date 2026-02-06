//
//  CalendarMonthDayView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/22.
//

import Foundation
import UIKit

class CalendarMonthDayView: UIView {

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
        label.textAlignment = .right
        label.textColor = .gray
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    /// 调休状态
    private let workStatusLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.boldSystemFont(ofSize: 8.0)
        label.textAlignment = .center
        label.textColor = .gray
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
        // 添加子视图
        addSubview(dayLabel)
        addSubview(lunarLabel)
        addSubview(workStatusLabel)
    }
           
    override func layoutSubviews() {
        super.layoutSubviews()
        var layoutFrame = CGRect(x: 0.0, y: 0.0, width: width, height: 30.0)
        layoutFrame = layoutFrame.inset(by: UIEdgeInsets(horizontal: 4.0, vertical: 2.0))
        let labelWidth = layoutFrame.width / 2.0 - 2.0
        dayLabel.frame = CGRect(x: layoutFrame.minX,
                                y: layoutFrame.minY,
                                width: labelWidth,
                                height: layoutFrame.height)
        lunarLabel.frame = CGRect(x: layoutFrame.maxX - labelWidth,
                                  y: layoutFrame.minY,
                                  width: labelWidth,
                                  height: layoutFrame.height)
    }
    
    /// 重置标签数据
    func reset() {
        dayLabel.text = nil
        lunarLabel.text = nil
        workStatusLabel.text = nil
    }
    
    /// 更新数据
    func update(with config: CalendarMonthDayConfig) {
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
    }
}
