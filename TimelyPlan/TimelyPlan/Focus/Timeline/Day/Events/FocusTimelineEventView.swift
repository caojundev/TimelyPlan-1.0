//
//  FocusTimelineEventView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/7.
//

import Foundation
import UIKit

class FocusTimelineEventView: UIView {
    
    let event: FocusTimelineEvent
    
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        self.layer.cornerRadius = 2.4
        self.clipsToBounds = true
        self.padding = UIEdgeInsets(top: 2.0, left: 4.0, bottom: 2.0, right: 2.0)
        
        let startDate = Calendar.current.date(bySettingHour: 13,
                                              minute: 00,
                                              second: 0,
                                              of: .now)!
        
        let timeline = FocusRecordTimeline(startDate: startDate, recordDurations: [FocusRecordDuration(type: .focus, interval: 3600),
             FocusRecordDuration(type: .pause, interval: 3600),])
        
        pauseView.timeline = timeline
        pauseView.alpha = 0.2
        addSubview(pauseView)
        
        nameLabel.font = .systemFont(ofSize: 10, weight: .bold)
        nameLabel.text = event.name
        addSubview(nameLabel)
        
        durationLabel.font = .systemFont(ofSize: 9, weight: .bold)
        durationLabel.text = event.focusDuration.localizedTitle
        addSubview(durationLabel)
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
        backgroundColor = event.color
        let textColor = CalendarEventColor.highlightedForegroundColor(for: event.color)
        nameLabel.textColor = textColor
        durationLabel.textColor = textColor
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
