//
//  CalendarWeekAllDayEventsView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/13.
//

import Foundation
import UIKit

class CalendarWeekAllDayEventsView: UIView {

    var weekStartDate: Date?
    
    private let stripView: CalendarStripView = {
        let view = CalendarStripView()
        return view
    }()
    
    private let backLayer = CalendarWeekDaysBackLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .systemGray5
        clipsToBounds = true
        layer.addSublayer(backLayer)
        addSubview(stripView)
        reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        stripView.width = width
        stripView.height = stripView.heightThatFits(CalendarWeekConstant.allDayMaxStripLinesCount)
        stripView.origin = .zero
        executeWithoutAnimation {
            self.backLayer.frame = bounds
            self.backLayer.updateColors()
        }
    }
    
    func maxRow(in dateRange: (firstDate: Date, lastDate: Date)) -> Int {
        return stripView.maxRow(in: dateRange)
    }
    
    func didChangeVisibleOffset(_ offset: CGPoint) {
        stripView.didChangeVisibleOffset(offset)
    }
    
    func reloadData() {
        guard let weekStartDate = weekStartDate else {
            stripView.startDate = nil
            stripView.events = nil
            stripView.reloadData()
            return
        }
        
        stripView.startDate = weekStartDate
        
        var events = [CalendarEvent]()
        var event = CalendarEvent(name: "事件名称1",
                                  color: CalendarEventColor.random,
                                    startDate: weekStartDate.dateByAddingDays(1)!,
                                  endDate: weekStartDate.dateByAddingDays(2)!)
        events.append(event)

        event = CalendarEvent(name: "事件名称2",
                                  color: CalendarEventColor.random,
                                    startDate: weekStartDate.dateByAddingDays(2)!,
                                  endDate: weekStartDate.dateByAddingDays(4)!)
        events.append(event)

        event = CalendarEvent(name: "事件名称3",
                                  color: CalendarEventColor.random,
                                    startDate: weekStartDate.dateByAddingDays(3)!,
                                  endDate: weekStartDate.dateByAddingDays(3)!)
        events.append(event)
        
        event = CalendarEvent(name: "事件名称4",
                                  color: CalendarEventColor.random,
                                    startDate: weekStartDate.dateByAddingDays(1)!,
                                  endDate: weekStartDate.dateByAddingDays(4)!)
        events.append(event)
        
        event = CalendarEvent(name: "事件名称5",
                                  color: CalendarEventColor.random,
                                    startDate: weekStartDate.dateByAddingDays(1)!,
                                  endDate: weekStartDate.dateByAddingDays(1)!)
        events.append(event)
        
        event = CalendarEvent(name: "事件名称6",
                                  color: CalendarEventColor.random,
                                    startDate: weekStartDate.dateByAddingDays(4)!,
                                  endDate: weekStartDate.dateByAddingDays(5)!)
        events.append(event)
        
        event = CalendarEvent(name: "事件名称7",
                              color: CalendarEventColor.random,
                              startDate: weekStartDate,
                              endDate: weekStartDate.dateByAddingDays(1)!)
        events.append(event)
        
        event = CalendarEvent(name: "事件名称8",
                                  color: CalendarEventColor.random,
                                    startDate: weekStartDate.dateByAddingDays(1)!,
                                  endDate: weekStartDate.dateByAddingDays(1)!)
        events.append(event)
        
        event = CalendarEvent(name: "事件名称9",
                                  color: CalendarEventColor.random,
                                    startDate: weekStartDate.dateByAddingDays(1)!,
                                  endDate: weekStartDate.dateByAddingDays(1)!)
        events.append(event)
        
        event = CalendarEvent(name: "事件名称10",
                                  color: CalendarEventColor.random,
                                    startDate: weekStartDate.dateByAddingDays(1)!,
                                  endDate: weekStartDate.dateByAddingDays(2)!)
        events.append(event)
        
        event = CalendarEvent(name: "事件名称11",
                                  color: CalendarEventColor.random,
                                    startDate: weekStartDate.dateByAddingDays(2)!,
                                  endDate: weekStartDate.dateByAddingDays(2)!)
        events.append(event)
        stripView.events = events
        stripView.reloadData()
    }
}
