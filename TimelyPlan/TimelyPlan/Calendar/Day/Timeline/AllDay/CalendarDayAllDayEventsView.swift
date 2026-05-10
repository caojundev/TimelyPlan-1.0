//
//  CalendarDayAllDayEventsView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/9.
//


import Foundation
import UIKit

class CalendarDayAllDayEventsView: UIView {

    var date: Date? {
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
        stripView.width = width
        stripView.height = stripView.heightThatFits(CalendarDayConstant.allDayMaxStripLinesCount)
        stripView.origin = .zero
    }
    
    func maxRow() -> Int {
        guard let date = date else {
            return -1
        }

        return stripView.maxRow(in: (date, date))
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
