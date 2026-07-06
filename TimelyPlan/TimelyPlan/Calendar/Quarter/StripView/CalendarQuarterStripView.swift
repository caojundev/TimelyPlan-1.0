//
//  CalendarQuarterStripView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/6.
//

import Foundation
import UIKit

class CalendarQuarterStripView: UIView {

    /// 路径信息
    var events: [CalendarEvent]?
    
    /// 周开始日期
    var startDate: Date?
    
    /// 横条圆角半径
    var cornerRadius: CGFloat = 2.0
    
    /// 更多文本字体
    var moreTextFont: UIFont = .systemFont(ofSize: 10)
    
    /// 更多文本颜色
    var moreTextColor: UIColor = .gray
    
    /// 横跨天数
    private let days: Int = DAYS_PER_WEEK
    
    /// 布局
    private var layout: CalendarEventLayout?
    private let layoutManager: CalendarStripLayoutManager
    private let layoutProvider = CalendarStripLayoutProvider()
    
    /// 绘制缓存
    private var drawnEventPaths: [(path: CalendarEventPath, event: CalendarEvent)] = []
    private var moreTextInfos: [(column: Int, text: String)] = []

    init() {
        self.layoutManager = CalendarStripLayoutManager(days: self.days)
        super.init(frame: .zero)
        self.layoutManager.itemHeight = 6.0
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let canvasSize = bounds.size
        if layoutManager.canvasSize != canvasSize {
            layoutManager.canvasSize = canvasSize
            layoutManager.layoutIfNeeded()
            prepareDrawData()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 绘制事件横条
        for item in drawnEventPaths {
            let frame = layoutManager.eventFrame(for: item.path)
            drawEventBar(context: context, frame: frame, color: item.event.color)
        }
        
        // 绘制更多文本
        for info in moreTextInfos {
            let frame = layoutManager.moreTextFrame(for: info.column)
            drawMoreText(context: context, frame: frame, text: info.text)
        }
    }
    
    /// 绘制单个事件横条
    private func drawEventBar(context: CGContext, frame: CGRect, color: UIColor) {
        let path = UIBezierPath(roundedRect: frame, cornerRadius: cornerRadius)
        context.addPath(path.cgPath)
        context.setFillColor(color.cgColor)
        context.fillPath()
    }
    
    /// 绘制更多文本
    private func drawMoreText(context: CGContext, frame: CGRect, text: String) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: moreTextFont,
            .foregroundColor: moreTextColor
        ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedString.size()
        let textOrigin = CGPoint(
            x: frame.midX - textSize.width / 2,
            y: frame.midY - textSize.height / 2
        )
        attributedString.draw(at: textOrigin)
    }
    
    /// 准备绘制数据
    private func prepareDrawData() {
        drawnEventPaths.removeAll()
        moreTextInfos.removeAll()
        
        guard let layout = layout else {
            setNeedsDisplay()
            return
        }
        
        let linesCount = layoutManager.linesCount
        
        // 收集事件绘制数据
        for pathInfo in layout.pathInfos {
            let path = pathInfo.path
            if path.row >= linesCount {
                continue
            }
            
            if path.row == linesCount - 1 {
                let count = layout.eventsCount(at: path.position.column)
                if count > linesCount {
                    continue
                }
            }
            
            drawnEventPaths.append((path: pathInfo.path, event: pathInfo.event))
        }
        
        // 收集更多文本绘制数据
        for column in 0..<days {
            let eventsCount = layout.eventsCount(at: column)
            guard eventsCount > linesCount else {
                continue
            }
            
            let remainCount = eventsCount - linesCount + 1
            let text = "+\(remainCount)"
            moreTextInfos.append((column: column, text: text))
        }
        
        setNeedsDisplay()
    }
    
    func reset() {
        self.events = nil
        self.layout = nil
        drawnEventPaths.removeAll()
        moreTextInfos.removeAll()
        setNeedsDisplay()
    }
    
    func reloadData() {
        guard let startDate = startDate, let events = events, events.count > 0 else {
            layout = nil
            drawnEventPaths.removeAll()
            moreTextInfos.removeAll()
            setNeedsDisplay()
            return
        }
        
        layout = layoutProvider.layout(events: events, firstDate: startDate, days: days)
        prepareDrawData()
    }
}
