//
//  CalendarExpandWeekView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/7.
//

import Foundation
import UIKit

class CalendarExpandWeekView: TPCalendarScrollableWeekView {
    
    override func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return CalendarExpandWeekCell.self
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? CalendarExpandWeekCell else {
            return
        }
        
        if let dateComponents = adapter.item(at: indexPath) as? DateComponents {
            updateWeekView(cell.weekView, with: dateComponents)
        }
    }
}

class CalendarExpandWeekCell: TPCollectionCell {
    
    private(set) lazy var weekView: TPCalendarSingleWeekView = {
        return TPCalendarSingleWeekView(frame: bounds)
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
