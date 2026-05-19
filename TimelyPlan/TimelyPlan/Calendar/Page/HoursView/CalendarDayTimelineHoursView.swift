//
//  CalendarDayTimelineHoursView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/1.
//

import Foundation
import UIKit

class CalendarDayTimelineHoursView: UIView {
    
    var contentOffset: CGPoint {
        get {
            return contentView.contentOffset
        }
        
        set {
            contentView.contentOffset = newValue
        }
    }
    
    let contentView = UIScrollView()
    
    private var hourLabels = [UILabel]()

    var layout = CalendarAxisLayout()
    
    let labelHeight = 15.0
    
    // 添加字体属性
    private let hourLabelFont = UIFont.systemFont(ofSize: 10, weight: .regular)
    private let hourLabelTextColor = UIColor.darkGray
    
    // 添加高亮视图
    private var highlightView: CalendarTimelineHourHighlightView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentView()
        setupHourLabels()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupContentView() {
        backgroundColor = .systemBackground
        contentView.contentInsetAdjustmentBehavior = .never
        contentView.scrollsToTop = false
        contentView.showsVerticalScrollIndicator = false
        contentView.showsHorizontalScrollIndicator = false
        addSubview(contentView)
        contentView.contentSize = CGSize(width: bounds.width, height: layout.contentHeight)
    }
    
    private func setupHourLabels() {
        for hour in 0...24 { // 修改为 0...24 以包含结尾的 00:00
            let label = UILabel()
            label.text = String(format: "%02d:00", hour % 24) // 使用模运算确保显示 00:00
            label.textAlignment = .center
            label.font = hourLabelFont // 设置字体
            label.textColor = hourLabelTextColor // 设置文字颜色
            contentView.addSubview(label)
            hourLabels.append(label)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        contentView.contentSize = CGSize(width: bounds.width, height: layout.contentHeight)
        
        for (hour, label) in hourLabels.enumerated() {
            let position = layout.position(of: hour)
            label.frame = CGRect(x: 0,
                                 y: position.y - labelHeight / 2.0,
                                 width: bounds.width,
                                 height: labelHeight)
        }
    
        layoutHighlightView()
        updateHourLabelVisibility()
    }
    
    func updateHourLabelVisibility() {
        guard let highlightView = highlightView else {
            hourLabels.forEach { label in
                label.isHidden = false
            }
            
            return
        }

        for hourLabel in hourLabels {
            hourLabel.isHidden = highlightView.shouldHideHourLabel(hourLabel)
        }
    }
    
    private func layoutHighlightView() {
        guard let highlightView = highlightView else {
            return
        }
        
        highlightView.frame = CGRect(x: 0.0,
                                     y: 0.0,
                                     width: bounds.width,
                                     height: layout.contentHeight)
    }
    
    
    // 高亮日期范围
    func highlightDateRange(_ dateRange: CalendarTimelineDateRange) {
        if highlightView == nil {
            let highlightView = CalendarTimelineHourHighlightView(layout: layout)
            contentView.addSubview(highlightView)
            self.highlightView = highlightView
            layoutHighlightView()
        }
        
        if highlightView?.dateRange != dateRange {
            highlightView?.highlightDateRange(dateRange)
            updateHourLabelVisibility()
        }
    }
    
    // 清除高亮
    func clearHighlight() {
        highlightView?.removeFromSuperview()
        highlightView = nil
        updateHourLabelVisibility()
    }
}

// 高亮视图类
private class CalendarTimelineHourHighlightView: UIView {

    private(set) var dateRange: CalendarTimelineDateRange?
    
    /// 开始标签
    private lazy var startLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12.0)
        label.textAlignment = .center
        label.textColor = .primary
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    /// 结束标签
    private var endLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12.0)
        label.textAlignment = .center
        label.textColor = .primary
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    var layout = CalendarAxisLayout()
    
    init(layout: CalendarAxisLayout) {
        super.init(frame: .zero)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        addSubview(startLabel)
        addSubview(endLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutLabels()
    }
    
    func highlightDateRange(_ dateRange: CalendarTimelineDateRange) {
        self.dateRange = dateRange
        layoutLabels()
    }
    
    private func layoutLabels() {
        guard let dateRange = dateRange else {
            startLabel.text = nil
            startLabel.isHidden = true
            endLabel.text = nil
            endLabel.isHidden = true
            return
        }
        
        let startDate = dateRange.start
        let endDate = dateRange.end
        startLabel.isHidden = false
        startLabel.text = startDate.timeString
        let labelHeight = 15.0
        let startPosition = layout.position(of: startDate)
        let startFrame = CGRect(x: 0,
                                y: startPosition.y - labelHeight / 2.0,
                                width: bounds.width,
                                height: labelHeight)
        startLabel.frame = startFrame
        
        if endDate.isInSameDayAs(startDate) {
            endLabel.text = endDate.timeString
            let endPosition = layout.position(of: endDate)
            let endFrame = CGRect(x: 0,
                                  y: endPosition.y - labelHeight / 2.0,
                                  width: bounds.width,
                                  height: labelHeight)
            endLabel.frame = endFrame
            if endFrame.intersects(startFrame) {
                endLabel.isHidden = true
            } else {
                endLabel.isHidden = false
            }
        } else {
            endLabel.isHidden = true
            endLabel.text = nil
            endLabel.frame = .zero
        }
    }
    
    func shouldHideHourLabel(_ hourLabel: UILabel) -> Bool {
        if startLabel.frame.intersects(hourLabel.frame) {
            return true
        }
        
        if !endLabel.isHidden, endLabel.frame.intersects(hourLabel.frame) {
            return true
        }
        
        return false
    }
}
