//
//  CalendarEventView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/10.
//

import Foundation
import QuartzCore
import UIKit

enum CalendarEventDisplayStyle {
    case modern /// 现代
    case classic /// 传统
}

class CalendarEventView: UIView {
    
    struct Constants {
        static let padding = UIEdgeInsets(top: 4.0, left: 2.0, bottom: 2.0, right: 2.0)
        static let nameLabelFont = UIFont.systemFont(ofSize: 10, weight: .bold)
        static let timeLabelHeight = 16.0
        static let timeLabelFont = UIFont.systemFont(ofSize: 8, weight: .medium)
    }
    
    var style: CalendarEventDisplayStyle = .modern
    
    let event: CalendarEvent
    
    /// 线条图层
    private let lineLayer = CALayer()
    
    /// 名称标签
    private let nameLabel = UILabel()
    
    /// 时间标签
    let timeLabel = UILabel()
    
    var isHighlighted: Bool = false {
        didSet {
            updateStyle()
            updateNameLabel()
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
        padding = Constants.padding
        clipsToBounds = true
        layer.cornerRadius = CalendarConstant.eventViewCornerRadius
        layer.addSublayer(lineLayer)
        nameLabel.font = Constants.nameLabelFont
        addSubview(nameLabel)
        
        timeLabel.font = Constants.timeLabelFont
        timeLabel.text = event.startDate.timeString
        addSubview(timeLabel)
        updateStyle()
        updateNameLabel()
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateStyle()
        
        let layoutFrame = layoutFrame()
        nameLabel.width = layoutFrame.width
        nameLabel.sizeToFit()
        nameLabel.left = layoutFrame.minX
        if nameLabel.height + Constants.timeLabelHeight + padding.verticalLength <= height {
            nameLabel.top = layoutFrame.minY
            
            timeLabel.isHidden = false
            timeLabel.width = layoutFrame.width
            timeLabel.height = Constants.timeLabelHeight
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
    
    private func updateNameLabel() {
        let title = event.title ?? resGetString("Untitled")
        if event.isCompleted {
            nameLabel.attributed.text = "\(title, .font(Constants.nameLabelFont), .strikethrough(.single, color: nameLabel.textColor))"
        } else {
            nameLabel.text = title
        }
    }
    
    private func updateStyle() {
        if isHighlighted {
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
}
