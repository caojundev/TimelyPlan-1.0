//
//  FocusTimelineEventView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/7.
//

import Foundation
import UIKit

/// 时间线事件点击代理协议
protocol FocusTimelineEventTapDelegate: AnyObject {
    /// 当用户点击时间线事件时调用
    /// - Parameter event: 被点击的时间线事件
    func didTapTimelineEvent(_ event: FocusTimelineEvent)
}

class FocusTimelineEventView: UIView {
    
    let event: FocusTimelineEvent
    
    /// 点击事件代理
    weak var tapDelegate: FocusTimelineEventTapDelegate?
    
    /// 用于展示暂停视图
    private let pauseView = FocusTimelinePauseView(frame: .zero)
    
    /// 名称标签
    private let nameLabel = UILabel()
    
    /// 时长标签
    private let durationLabel = UILabel()
    
    var highlighted: Bool = false {
        didSet {
            updateStyle()
        }
    }
    
    init(event: FocusTimelineEvent) {
        self.event = event
        super.init(frame: .zero)
        setupSubviews()
        setupGestureRecognizer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        self.layer.cornerRadius = 2.4
        self.clipsToBounds = true
        self.padding = UIEdgeInsets(top: 2.0, left: 4.0, bottom: 2.0, right: 2.0)

        pauseView.timeline = event.timeline
        pauseView.alpha = 0.4
        addSubview(pauseView)
        
        nameLabel.font = .systemFont(ofSize: 10, weight: .bold)
        nameLabel.text = event.name
        addSubview(nameLabel)
        
        durationLabel.font = .systemFont(ofSize: 9, weight: .bold)
        durationLabel.text = event.focusDuration.localizedTitle
        addSubview(durationLabel)
    }
    
    /// 设置手势识别器
    private func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    /// 处理点击事件
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        tapDelegate?.didTapTimelineEvent(event)
    }
    
    private let durationLabelHeight = 16.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pauseView.frame = bounds
        updateStyle()
        let layoutFrame = layoutFrame()
        durationLabel.width = layoutFrame.width / 2.0
        durationLabel.sizeToFit()
        
        if durationLabelHeight + padding.verticalLength <= height {
            nameLabel.isHidden = false
            durationLabel.isHidden = false
            
            durationLabel.right = layoutFrame.maxX
            durationLabel.top = layoutFrame.minY
            
            nameLabel.width = layoutFrame.width - durationLabel.width
            nameLabel.height = durationLabel.height
            nameLabel.origin = layoutFrame.origin
        } else {
            nameLabel.isHidden = true
            durationLabel.isHidden = true
        }
    }
    
    private func updateStyle() {
        let eventColor = event.color
        let textColor = CalendarEventColor.highlightedForegroundColor(for: eventColor)
        nameLabel.textColor = textColor
        durationLabel.textColor = textColor
        
        if highlighted {
            self.backgroundColor = eventColor.darkerColor
        } else {
            self.backgroundColor = eventColor
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.highlighted = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.highlighted = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.highlighted = false
    }
}
