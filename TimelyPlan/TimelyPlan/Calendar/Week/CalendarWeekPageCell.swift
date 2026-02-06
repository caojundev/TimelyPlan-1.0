//
//  CalendarWeekPageCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/8.
//

import Foundation
import UIKit

class CalendarWeekPageCell: TPCollectionCell {
    
    /// 周开始日期
    var weekStartDate: Date?
    
    var eventsView: CalendarWeekEventsView {
        return weekView.eventsView
    }
    
    private lazy var weekView: CalendarWeekView = {
        let view = CalendarWeekView(frame: bounds)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(weekView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        weekView.frame = bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        weekView.reset()
    }
    
    func reloadData() {
        weekView.weekStartDate = weekStartDate
        weekView.reloadData()
    }
    
    func didChangeVisibleOffset(_ offset: CGPoint) {
        eventsView.didChangeVisibleOffset(offset)
    }
}
