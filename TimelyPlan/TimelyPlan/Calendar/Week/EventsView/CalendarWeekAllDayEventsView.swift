//
//  CalendarWeekAllDayEventsView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/13.
//

import Foundation
import UIKit

class CalendarWeekAllDayEventsView: UIView {

    var weekStartDate: Date? {
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
    
    func reset() {
        stripView.reset()
    }
    
    func reloadData() {
        stripView.reloadData()
    }
}
