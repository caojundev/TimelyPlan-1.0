//
//  CalendarEventView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/10.
//

import Foundation
import QuartzCore

enum CalendarEventDisplayStyle {
    case modern /// 现代
    case classic /// 传统
}

class CalendarEventView: UIView {
    
    var style: CalendarEventDisplayStyle = .modern
    
    let event: CalendarEvent
    
    /// 线条图层
    private let lineLayer = CALayer()
    
    /// 名称标签
    private let nameLabel = UILabel()
    
    /// 时间标签
    private let timeLabel = UILabel()
    
    var highlighted: Bool = false {
        didSet {
            updateStyle()
        }
    }
    
    init(event: CalendarEvent) {
        self.event = event
        super.init(frame: .zero)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        self.layer.cornerRadius = 2.0
        self.clipsToBounds = true
        self.padding = UIEdgeInsets(top: 4.0, left: 2.0, bottom: 2.0, right: 2.0)
        layer.addSublayer(lineLayer)
        
        nameLabel.font = .systemFont(ofSize: 10, weight: .bold)
        nameLabel.text = event.name
        addSubview(nameLabel)
        
        timeLabel.font = .systemFont(ofSize: 8, weight: .medium)
        timeLabel.text = event.startDate.timeString
        addSubview(timeLabel)
    }
    
    private let timeLabelHeight = 16.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateStyle()
        
        let layoutFrame = layoutFrame()
        nameLabel.width = layoutFrame.width
        nameLabel.sizeToFit()
        nameLabel.left = layoutFrame.minX
        if nameLabel.height + timeLabelHeight + padding.verticalLength <= height {
            nameLabel.top = layoutFrame.minY
            
            timeLabel.isHidden = false
            timeLabel.width = layoutFrame.width
            timeLabel.height = timeLabelHeight
            timeLabel.left = layoutFrame.minX
            timeLabel.top = nameLabel.bottom
        } else {
            timeLabel.isHidden = true
            nameLabel.centerY = layoutFrame.midY
        }
        
        executeWithoutAnimation {
            self.lineLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.width, height: 2.4)
        }
    }
    
    private func updateStyle() {
        if highlighted {
            backgroundColor = event.color
            lineLayer.backgroundColor = event.color.darkerColor.cgColor
            nameLabel.textColor = CalendarEventColor.highlightedForegroundColor(for: event.color)
        } else {
            backgroundColor = CalendarEventColor.backgroundColor(for: event.color)
            lineLayer.backgroundColor = event.color.cgColor
            nameLabel.textColor = CalendarEventColor.foregroundColor(for: event.color)
        }
        
        timeLabel.textColor = nameLabel.textColor
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
