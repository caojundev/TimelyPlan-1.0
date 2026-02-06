//
//  TPCalendarSingleMonthCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/12.
//

import Foundation

class TPCalendarSingleMonthCell: TPCollectionCell {
    
    fileprivate(set) var monthView: TPCalendarMonthView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        monthView = TPCalendarMonthView(frame: bounds)
        contentView.addSubview(monthView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        monthView.frame = bounds
    }
}
