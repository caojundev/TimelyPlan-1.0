//
//  CalendarStripEventView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/26.
//

import Foundation
import UIKit

class CalendarStripEventView: UIView {
    
    struct Constants {
        static let cornerRadius = 2.0
        
        static let lineLayerWidth = 3.0
        
        /// 最小内容宽度
        static let minimumContentWidth = 40.0
        
        static let nameLabelFont = UIFont.systemFont(ofSize: 10, weight: .bold)
    }
    
    var contentOffset: CGPoint = .zero {
        didSet {
            updateContentFrame()
        }
    }
    
    let event: CalendarEvent
    
    let path: CalendarEventPath

    /// 线条图层
    private let lineLayer = CALayer()
    
    /// 名称标签
    private let nameLabel = UILabel()
    
    
    
//    private let textLayer: CATextLayer = {
//        let textLayer = CATextLayer()
//        let font = CTFontCreateWithName("Helvetica-Bold" as CFString, 10.0, nil)
//        textLayer.font = font
//        textLayer.fontSize = 10.0
//        textLayer.alignmentMode = .left
//        textLayer.contentsScale = UIScreen.main.scale
//        return textLayer
//    }()

    let foregroundColor: UIColor
    
    init(event: CalendarEvent, path: CalendarEventPath) {
        self.event = event
        self.path = path
        self.foregroundColor = CalendarEventColor.foregroundColor(for: event.color)
        super.init(frame: .zero)
        backgroundColor = CalendarEventColor.backgroundColor(for: event.color)
        layer.cornerRadius = Constants.cornerRadius
        layer.masksToBounds = true
        layer.addSublayer(lineLayer)
        lineLayer.backgroundColor = event.color.cgColor
        
        nameLabel.lineBreakMode = .byClipping
        nameLabel.textColor = foregroundColor
        nameLabel.font = Constants.nameLabelFont
        addSubview(nameLabel)
        updateNameLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        executeWithoutAnimation {
            self.lineLayer.frame = CGRect(x: 0.0,
                                          y: 0.0,
                                          width: Constants.lineLayerWidth,
                                          height: self.bounds.height)
        }

        updateContentFrame()
    }

    private func updateNameLabel() {
        let title = event.title ?? resGetString("Untitled")
        if event.isCompleted {
            nameLabel.attributed.text = "\(title, .font(Constants.nameLabelFont), .strikethrough(.single, color: foregroundColor))"
        } else {
            nameLabel.text = title
        }
    }
    
    /// 更新内容布局
    private func updateContentFrame() {
        let layoutFrame = bounds.inset(by: UIEdgeInsets(horizontal: 5.0))
        var originX = contentOffset.x + 5.0
        clampValue(&originX, layoutFrame.minX, layoutFrame.maxX - Constants.minimumContentWidth)
        nameLabel.frame = CGRect(x: originX, y: 0.0, width: layoutFrame.maxX - originX, height: bounds.height)
    }
}
