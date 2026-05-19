//
//  CalendarStripView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/22.
//

import Foundation
import UIKit

class CalendarStripView: UIView {
    
    enum Mode {
        case week
        case day
    }
    
    /// 路径信息
    var events: [CalendarEvent]?
    
    /// 周开始日期
    var startDate: Date?
    
    /// 事件子图层
    private var eventViews: [CalendarStripEventView] = []
    
    /// 更多图层
    private var moreTextLayers: [CalendarStripMoreTextLayer] = []
    
    /// 布局
    private var layout: CalendarEventLayout?
    private let layoutManager: CalendarStripLayoutManager
    private let layoutProvider = CalendarStripLayoutProvider()

    /// 横跨天数
    private let days: Int
    
    init(mode: Mode = .week) {
        if mode == .day {
            self.days = 1
        } else {
            self.days = DAYS_PER_WEEK
        }
        
        self.layoutManager = CalendarStripLayoutManager(days: self.days)
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let canvasSize = bounds.size
        if layoutManager.canvasSize != canvasSize {
            /// 尺寸改变重现初始化图层
            layoutManager.canvasSize = canvasSize
            layoutManager.layoutIfNeeded()
            setupViews()
        } else {
            executeWithoutAnimation {
                self.layoutEventViews()
            }
        }
    }
    
    private func layoutEventViews() {
        for eventView in eventViews {
            eventView.frame = layoutManager.eventFrame(for: eventView.path)
        }
        
        for layer in moreTextLayers {
            layer.frame = layoutManager.moreTextFrame(for: layer.column)
        }
    }
    
    /// 初始化图层
    private func setupViews() {
        removeAllEventViews()
        guard let layout = layout else {
            return
        }
        
        layoutManager.canvasSize = bounds.size
        layoutManager.layoutIfNeeded()
        setupEventViews(with: layout)
        setupMoreTextLayers(with: layout)
    }
    
    private func removeAllEventViews() {
        eventViews.forEach { $0.removeFromSuperview() }
        eventViews.removeAll()
        
        moreTextLayers.forEach { $0.removeFromSuperlayer() }
        moreTextLayers.removeAll()
    }
    
    /// 事件图层
    private func setupEventViews(with layout: CalendarEventLayout) {
        for pathInfo in layout.pathInfos {
            let path = pathInfo.path
            if path.row >= layoutManager.linesCount {
                continue
            }
            
            if path.row == layoutManager.linesCount - 1 {
                let count = layout.eventsCount(at: path.position.column)
                if count > layoutManager.linesCount {
                    continue
                }
            }
            
            let eventView = CalendarStripEventView(event: pathInfo.event, path: pathInfo.path)
            eventView.frame = layoutManager.eventFrame(for: pathInfo.path)
            addSubview(eventView)
            eventViews.append(eventView)
        }
    }
    
    /// 更多文本图层
    private func setupMoreTextLayers(with layout: CalendarEventLayout) {
        let linesCount = layoutManager.linesCount
        for column in 0..<days {
            let eventsCount = layout.eventsCount(at: column)
            guard eventsCount > linesCount else {
                continue
            }
            
            let remainCount = eventsCount - linesCount + 1
            let title = "+\(remainCount)"
            let textLayer = CalendarStripMoreTextLayer.layer(with: column, string: title)
            textLayer.frame = layoutManager.moreTextFrame(for: column)
            layer.addSublayer(textLayer)
            moreTextLayers.append(textLayer)
        }
    }
    
    func reset() {
        self.events = nil
        self.layout = nil
        self.removeAllEventViews()
    }
    
    func reloadData() {
        guard let startDate = startDate, let events = events, events.count > 0 else {
            layout = nil
            return
        }
        
        layout = layoutProvider.layout(events: events, firstDate: startDate, days: days)
        setupViews()
    }
    
    func heightThatFits(_ linesCount: Int) -> CGFloat {
        return layoutManager.heightThatFits(linesCount)
    }
    
    func maxRow(in dateRange: (firstDate: Date, lastDate: Date)) -> Int {
        guard let startDate = startDate else {
            return -1
        }

        let rangeStart = Date.days(fromDate: startDate, toDate: dateRange.firstDate)
        let rangeLength = Date.days(fromDate: dateRange.firstDate, toDate: dateRange.lastDate) + 1
        let startColumn = max(0, rangeStart)
        let endColumn = min(days, rangeStart + rangeLength)
        guard endColumn > startColumn else {
            return -1
        }
        
        /// 取不到 end 值
        var result = -1
        for column in startColumn..<endColumn {
            let maxRow = maxRow(at: column)
            if maxRow > result {
                result = maxRow
            }
        }
    
        return result
    }
    
    func didChangeVisibleOffset(_ offset: CGPoint) {
        for eventView in eventViews {
            eventView.contentOffset = CGPoint(x: offset.x - eventView.frame.origin.x, y: 0.0)
        }
    }
    
    // MARK: - Helpers
    /// 获取特定列对应的最大行索引，如果列没有事件则返回 -1
    private func maxRow(at column: Int) -> Int {
        guard column >= 0, column < days else {
            return -1
        }
        
        for moreTextLayer in moreTextLayers {
            if moreTextLayer.column == column {
                return layoutManager.linesCount - 1
            }
        }
        
        var maxRow = -1
        for eventView in eventViews {
            let path = eventView.path
            guard path.position.column <= column, path.position.end >= column else {
                continue
            }
            
            if path.row > maxRow {
                maxRow = path.row
            }
        }
    
        return maxRow
    }
}
