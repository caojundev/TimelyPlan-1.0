//
//  CalendarPageTimelineCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/18.
//

import Foundation
import UIKit

class CalendarPageTimelineCell: TPCollectionCell {

    var timelineView: CalendarPageTimelineView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTimelineView()
        contentView.addSubview(timelineView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTimelineView() {
        self.timelineView = CalendarPageTimelineView(frame: bounds, mode: .day)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        timelineView.frame = bounds
    }
}

