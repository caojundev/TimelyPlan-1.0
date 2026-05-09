//
//  CalendarDayAllDayEventsView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/9.
//


import Foundation
import UIKit

class CalendarDayAllDayEventsView: UIView {

    var date: Date?
    
    private lazy var stripView: CalendarStripView = {
        let view = CalendarStripView(mode: .day)
        return view
    }()

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
        addSubview(stripView)
        reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        stripView.frame = bounds
    }
    
    func maxRow() -> Int {
        guard let date = date else {
            return -1
        }

        return stripView.maxRow(in: (date, date))
    }
    
    func reset() {
        self.stripView.reset()
    }
    
    
    func reloadData() {
        guard let date = date else {
            stripView.startDate = nil
            stripView.events = nil
            stripView.reloadData()
            return
        }
        
        stripView.startDate = date
        
        var events = [CalendarEvent]()
        let count = arc4random() % 10
        for i in 0...count {
            let name = "事件名称 \(i)"
            let event = CalendarEvent(name: name,
                                      color: CalendarEventColor.random,
                                      startDate: date,
                                      endDate: date.dateByAddingDays(1)!)
            events.append(event)

        }
        
        stripView.events = events
        stripView.reloadData()
    }
}
