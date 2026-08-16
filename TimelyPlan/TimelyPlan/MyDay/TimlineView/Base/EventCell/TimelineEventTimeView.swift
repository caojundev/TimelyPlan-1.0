//
//  TimelineEventTimeView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/16.
//

import Foundation
import UIKit

// MARK: - 时间视图
class TimelineEventTimeView: UIView {
    
    var onClickTime: (() -> Void)?
    
    // MARK: 时间标签
    private(set) lazy var startTimeLabel: UILabel = {
        let label = UILabel()
        label.font = TimelineConfig.timeFont
        label.textColor = TimelineConfig.timeColor
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private(set) lazy var endTimeLabel: UILabel = {
        let label = UILabel()
        label.font = TimelineConfig.timeFont
        label.textColor = TimelineConfig.timeColor
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private(set) lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.font = TimelineConfig.timeFont
        label.textColor = .primary
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        label.isHidden = true
        return label
    }()
    
    // MARK: 按钮
    private lazy var timeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(clickTime), for: .touchUpInside)
        return button
    }()
    
    // MARK: 数据
    private var currentItem: TimelineItem?
    private var isAllDayEvent = false
    
    // MARK: 布局常量
    private let topPadding: CGFloat = 4.0
    private let bottomPadding: CGFloat = 4.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(timeButton)
        addSubview(startTimeLabel)
        addSubview(endTimeLabel)
        addSubview(currentTimeLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds
        
        // 按钮占满整个视图
        timeButton.frame = bounds
        
        // 开始时间标签
        startTimeLabel.sizeToFit()
        
        if isAllDayEvent {
            // 全天事项：开始时间标签垂直居中
            startTimeLabel.frame = CGRect(
                x: 0,
                y: (bounds.height - startTimeLabel.bounds.height) / 2,
                width: bounds.width,
                height: startTimeLabel.bounds.height
            )
            
            // 重置结束时间标签frame（虽然隐藏但保持合理布局）
            endTimeLabel.frame = CGRect(
                x: 0,
                y: bounds.height - bottomPadding,
                width: bounds.width,
                height: 0
            )
            
            // 重置当前时间标签frame
            currentTimeLabel.frame = CGRect(
                x: 0,
                y: (bounds.height - currentTimeLabel.bounds.height) / 2,
                width: bounds.width,
                height: currentTimeLabel.bounds.height
            )
        } else {
            // 非全天事项：正常布局
            // 开始时间标签 - 固定在顶部
            startTimeLabel.frame = CGRect(
                x: 0,
                y: topPadding,
                width: bounds.width,
                height: startTimeLabel.bounds.height
            )
            
            // 结束时间标签 - 固定在底部
            endTimeLabel.sizeToFit()
            endTimeLabel.frame = CGRect(
                x: 0,
                y: bounds.height - bottomPadding - endTimeLabel.bounds.height,
                width: bounds.width,
                height: endTimeLabel.bounds.height
            )
            
            // 当前时间标签 - 根据进度动态定位
            if !currentTimeLabel.isHidden {
                // 重新计算当前时间标签位置
                updateCurrentTimeLabel()
            } else {
                currentTimeLabel.sizeToFit()
                currentTimeLabel.alignCenter()
            }
        }
    }
    
    /// 配置时间视图
    func configure(with item: TimelineItem) {
        currentItem = item
        isAllDayEvent = item.event.isAllDay
        
        if item.event.isAllDay {
            // 全天事项：隐藏当前时间和结束时间标签
            startTimeLabel.text = resGetString("All-Day")
            endTimeLabel.text = nil
            endTimeLabel.isHidden = true
            currentTimeLabel.isHidden = true
        } else {
            // 非全天事项：显示开始和结束时间
            startTimeLabel.text = item.startDate.timeString
            endTimeLabel.text = item.endDate.timeString
            
            if item.nodeStyle == .connectToNext || item.nodeStyle == .connectToBoth {
                endTimeLabel.isHidden = true
            } else {
                endTimeLabel.isHidden = false
            }
            
            // 更新当前时间标签
            updateCurrentTimeLabel()
        }
        
        setNeedsLayout()
    }
    
    /// 更新当前时间标签位置和显示状态
    private func updateCurrentTimeLabel() {
        guard let item = currentItem,
              !item.event.isAllDay else {
            currentTimeLabel.isHidden = true
            return
        }
        
        let now = Date()
        
        // 检查当前日期是否在事项时间区间内
        guard now >= item.startDate && now <= item.endDate else {
            currentTimeLabel.isHidden = true
            return
        }
        
        currentTimeLabel.isHidden = false
        currentTimeLabel.text = now.timeString
        
        // 计算当前时间标签在开始和结束标签之间的位置
        let totalDuration = item.endDate.timeIntervalSince(item.startDate)
        guard totalDuration > 0 else {
            currentTimeLabel.isHidden = true
            return
        }
        
        let elapsedTime = now.timeIntervalSince(item.startDate)
        let progress = elapsedTime / totalDuration
        
        // 手动计算位置
        let startLabelBottom = startTimeLabel.frame.maxY
        let endLabelTop = endTimeLabel.frame.minY
        let availableHeight = endLabelTop - startLabelBottom
        
        let currentTimeY = startLabelBottom + availableHeight * CGFloat(progress) - currentTimeLabel.frame.height / 2

        currentTimeLabel.sizeToFit()
        currentTimeLabel.alignHorizontalCenter()
        currentTimeLabel.top = currentTimeY
    }
    
    /// 更新当前时间（用于时间流逝时的动态更新）
    func updateCurrentTime() {
        updateCurrentTimeLabel()
    }
    
    /// 点击时间区域
    @objc private func clickTime() {
        onClickTime?()
    }
}
