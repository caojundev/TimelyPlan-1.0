//
//  CalendarStripEventView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/26.
//

import Foundation
import UIKit

class CalendarStripEventView: UIView {
    
    var contentOffset: CGPoint = .zero {
        didSet {
            updateContentFrame()
        }
    }
    
    let event: CalendarEvent
    
    let path: CalendarEventPath
    
    /// 最小内容宽度
    private let minimumContentWidth = 40.0

    /// 线条图层
    private let lineLayer = CALayer()
    
    private let textLayer: CATextLayer = {
        let textLayer = CATextLayer()
        let font = CTFontCreateWithName("Helvetica-Bold" as CFString, 10.0, nil)
        textLayer.font = font
        textLayer.fontSize = 10.0
        textLayer.alignmentMode = .left
        textLayer.contentsScale = UIScreen.main.scale
        return textLayer
    }()

    let foregroundColor: UIColor
    
    init(event: CalendarEvent, path: CalendarEventPath) {
        self.event = event
        self.path = path
        self.foregroundColor = CalendarEventColor.foregroundColor(for: event.color)
        super.init(frame: .zero)
        layer.cornerRadius = 2.0
        layer.masksToBounds = true
        textLayer.string = event.name
        layer.addSublayer(textLayer)
        backgroundColor = CalendarEventColor.backgroundColor(for: event.color)
        lineLayer.backgroundColor = event.color.cgColor
        layer.addSublayer(lineLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        executeWithoutAnimation {
            self.lineLayer.frame = CGRect(x: 0.0, y: 0.0, width: 3.0, height: self.bounds.height)
        }
        
        textLayer.foregroundColor = foregroundColor.cgColor
        updateContentFrame()
    }

    /// 更新内容布局
    private func updateContentFrame() {
        let layoutFrame = bounds.inset(by: UIEdgeInsets(horizontal: 5.0))
        var originX = contentOffset.x + 5.0
        clampValue(&originX, layoutFrame.minX, layoutFrame.maxX - minimumContentWidth)
        let frame = CGRect(x: originX, y: 0.0, width: layoutFrame.maxX - originX, height: bounds.height)
        executeWithoutAnimation {
            self.textLayer.frame = frame
        }
    }
}
