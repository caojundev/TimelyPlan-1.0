//
//  CalendarQuarterDayView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/5.
//

import Foundation
import UIKit

class CalendarQuarterDayView: UIView {
    
    static let headerHeight = 20.0
    
    var headerHeight: CGFloat = 20.0 {
        didSet {
            if headerHeight != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    // 阳历日期标签
    let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 13.0)
        label.textAlignment = .center
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
     
    /// 调休状态
    let workStatusIndicator = UIView()
    let workStatusIndicatorSize = CGSize(width: 4.0, height: 4.0)
    
    let headerView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    func setupViews() {
        headerView.padding = UIEdgeInsets(left:16.0, right: 16.0)
        headerView.clipsToBounds = true
        addSubview(headerView)
        headerView.addSubview(dayLabel)
        headerView.addSubview(workStatusIndicator)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        headerView.frame = CGRect(x: 0.0, y: 0.0, width: width, height: headerHeight)
        
        let layoutFrame = headerView.layoutFrame()
        dayLabel.frame = layoutFrame
        
        workStatusIndicator.size = workStatusIndicatorSize
        workStatusIndicator.centerX = layoutFrame.maxX
        workStatusIndicator.top = workStatusIndicatorSize.height
        workStatusIndicator.layer.cornerRadius = workStatusIndicatorSize.halfHeight
    }

    /// 重置标签数据
    func reset() {
        dayLabel.text = nil
    }
    
    /// 更新数据
    func update(with config: CalendarMonthDayConfig) {
        dayLabel.text = config.dayLabelText

        if config.date.isToday {
            dayLabel.textColor = .primary
        } else {
            dayLabel.textColor = .label
        }
     
        if config.workStatus == .inWorking {
            workStatusIndicator.backgroundColor = Color(0xFF3B30)
        } else if config.workStatus == .onHoliday {
            workStatusIndicator.backgroundColor = Color(0x34C759)
        } else {
            workStatusIndicator.isHidden = true
        }
        
        workStatusIndicator.isHidden = config.workStatus == .inNormal
        setNeedsLayout()
    }
}
