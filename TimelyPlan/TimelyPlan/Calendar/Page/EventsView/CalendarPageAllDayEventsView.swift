//
//  CalendarPageAllDayEventsView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/18.
//

import Foundation
import UIKit

class CalendarPageAllDayEventsView: UIView {

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
        return view
    }()
    
    private let backLayer = CalendarWeekDaysBackLayer()
    
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
