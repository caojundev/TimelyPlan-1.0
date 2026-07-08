//
//  TPCalendarSingleMonthCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/12.
//

import Foundation

class TPCalendarSingleMonthCell: TPCollectionCell {
    
    private(set) lazy var  monthView: TPCalendarMonthView = {
        return TPCalendarMonthView(frame: bounds)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(monthView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        monthView.frame = bounds
    }
    
    func updateSpaningIndicator() {
        monthView.updateSpaningIndicator()
    }
}
