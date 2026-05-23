//
//  CalendarPageAllDayEventsView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/18.
//

import Foundation
import UIKit

protocol CalendarPageAllDayEventsViewDelegate: AnyObject {
    
    /// 单击事项
    func calendarPageAllDayEventsView(_ view: CalendarPageAllDayEventsView, didTapEvent event: CalendarEvent)
    
    /// 点击更多
    func calendarPageAllDayEventsView(_ view: CalendarPageAllDayEventsView, didTapMoreOnDate date: Date)
}


class CalendarPageAllDayEventsView: UIView, CalendarStripViewDelegate {

    weak var delegate: CalendarPageAllDayEventsViewDelegate?
    
    var firstDate: Date? {
        get {
            return stripView.startDate
        }
        
        set {
            stripView.startDate = newValue
        }
    }
    
    var events: [CalendarEvent]? {
        get {
            return stripView.events
        }
        
        set {
            stripView.events = newValue
        }
    }
    
    private lazy var stripView: CalendarStripView = {
        let mode: CalendarStripView.Mode = self.mode == .day ? .day : .week
        let view = CalendarStripView(mode: mode)
        view.delegate = self
        return view
    }()
    
    /// 时间线背景图层
    private lazy var backgroundLayer: CalendarTimelineBackLayer = {
        let layer = CalendarTimelineBackLayer(mode: mode)
        layer.showHorizontalLines = false
        layer.leftDividerBottomMargin = 0.0
        return layer
    }()
    
    let mode: CalendarPageMode
    
    init(frame: CGRect, mode: CalendarPageMode) {
        self.mode = mode
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .systemGray5
        clipsToBounds = true
        layer.addSublayer(backgroundLayer)
        addSubview(stripView)
        reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        stripView.width = width
        stripView.height = stripView.heightThatFits(CalendarConstant.allDayMaxStripLinesCount)
        stripView.origin = .zero
        executeWithoutAnimation {
            self.backgroundLayer.frame = bounds
            self.backgroundLayer.updateColors()
        }
    }
    
    func maxRow(in dateRange: (firstDate: Date, lastDate: Date)) -> Int {
        return stripView.maxRow(in: dateRange)
    }
    
    func didChangeVisibleOffset(_ offset: CGPoint) {
        stripView.didChangeVisibleOffset(offset)
    }
    
    func reset() {
        stripView.reset()
    }
    
    func reloadData() {
        stripView.reloadData()
    }
    
    // MARK: - CalendarStripViewDelegate
    func calendarStripView(_ view: CalendarStripView, didTapEvent event: CalendarEvent) {
        delegate?.calendarPageAllDayEventsView(self, didTapEvent: event)
    }
    
    func calendarStripView(_ view: CalendarStripView, didTapMoreOnDate date: Date) {
        delegate?.calendarPageAllDayEventsView(self, didTapMoreOnDate: date)
    }
}
