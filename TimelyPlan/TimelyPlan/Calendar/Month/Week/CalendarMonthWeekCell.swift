//
//  CalendarMonthWeekCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/22.
//

import Foundation

class CalendarMonthWeekCell: UICollectionViewCell {
    
    /// 周视图
    private(set) lazy var weekView: CalendarMonthWeekView = {
        let view = CalendarMonthWeekView(frame: self.bounds)
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

}
