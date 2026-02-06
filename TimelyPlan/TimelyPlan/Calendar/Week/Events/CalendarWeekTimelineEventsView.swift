//
//  CalendarWeekTimelineEventsView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/12.
//

import Foundation
import UIKit

class CalendarWeekTimelineEventsView: UIScrollView {
    
    var weekStartDate: Date?
    
    var hourHeight: CGFloat = 40 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var topPadding: CGFloat = 20 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var bottomPadding: CGFloat = 40 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 天视图数组
    private var dayViews: [CalendarDayEventsView]!

    private var daysCount = DAYS_PER_WEEK
    
    /// 时间线背景图层
    private let backgroundLayer: CalendarWeekTimelineBackLayer = {
        let backlayer = CalendarWeekTimelineBackLayer()
        backlayer.columnsCount = DAYS_PER_WEEK
        return backlayer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupContentView() {
        scrollsToTop = false
        showsVerticalScrollIndicator = false
        layer.addSublayer(backgroundLayer)

        /// 初始化日视图
        var dayViews = [CalendarDayEventsView]()
        for _ in 1...daysCount {
            let view = CalendarDayEventsView()
            addSubview(view)
            dayViews.append(view)
        }
        
        self.dayViews = dayViews
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let contentHeight = hourHeight * CGFloat(HOURS_PER_DAY) + topPadding + bottomPadding
        self.contentSize = CGSize(width: width, height: contentHeight)
        
        let dayViewHeight = contentHeight - topPadding - bottomPadding
        let itemWidth = width / CGFloat(DAYS_PER_WEEK)
        for (index, dayView) in dayViews.enumerated() {
            let x = CGFloat(index) * itemWidth
            dayView.frame = CGRect(x: x, y: topPadding, width: itemWidth, height: dayViewHeight)
        }
        
        backgroundLayer.topPadding = topPadding
        backgroundLayer.bottomPadding = bottomPadding
        backgroundLayer.hourHeight = hourHeight
        backgroundLayer.updateColors()
        let backLayerFrame = CGRect(x: 0.0, y: 0.0, width: width, height: contentHeight)
        executeWithoutAnimation {
            backgroundLayer.frame = backLayerFrame
        }
    }
    
    func reloadData() {
        
    }
    
    func eventView(at point: CGPoint) -> CalendarEventView? {
        guard bounds.contains(point) else {
            return nil
        }
        
        let itemWidth = width / CGFloat(DAYS_PER_WEEK)
        let index = Int(point.x / itemWidth)
        let dayView = dayViews[index]
        let convertedPoint = convert(point, toViewOrWindow: dayView)
        return dayView.eventView(at: convertedPoint)
    }
}
