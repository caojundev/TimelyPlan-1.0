//
//  CalendarQuarterWeekCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/5.
//

import Foundation
import UIKit

class CalendarQuarterWeekCell: UICollectionViewCell {
    
    /// 周视图
    private(set) lazy var weekView: CalendarQuarterWeekView = {
        let view = CalendarQuarterWeekView(frame: self.bounds)
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
