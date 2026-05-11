//
//  CalendarMonthDayView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/22.
//

import Foundation
import UIKit

class CalendarMonthDayView: UIView {

    var headerHeight: CGFloat = 36.0 {
        didSet {
            if headerHeight != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    // 阳历日期标签
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.textAlignment = .center
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
     
    // 阴历/节假日标签
    private let lunarLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 8.0)
        label.textAlignment = .center
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
    
    private let headerView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        headerView.padding = UIEdgeInsets(top: 4.0)
        headerView.clipsToBounds = true
        addSubview(headerView)
        headerView.addSubview(dayLabel)
        headerView.addSubview(lunarLabel)
        headerView.addSubview(workStatusLabel)
    }
    
    private let dayLabelHeight = 20.0
    
    private let lunarLabelHeight = 12.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        headerView.frame = CGRect(x: 0.0, y: 0.0, width: width, height: headerHeight)
    
        let layoutFrame = headerView.layoutFrame()
        dayLabel.width = layoutFrame.width
        dayLabel.height = dayLabelHeight
        dayLabel.origin = layoutFrame.origin
        
        lunarLabel.width = layoutFrame.width
        lunarLabel.height = lunarLabelHeight
        lunarLabel.left = layoutFrame.minX
        lunarLabel.top = dayLabel.bottom
        
        workStatusLabel.size = .size(4)
        workStatusLabel.right = layoutFrame.maxX
        workStatusLabel.top = layoutFrame.minY
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
        
        if config.date.isToday {
            dayLabel.textColor = .primary
            lunarLabel.textColor = .primary
        } else {
            dayLabel.textColor = .label
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
