//
//  CalendarDayPagingView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/3.
//

import Foundation

class CalendarDayPagingView: CalendarDatePageView {
    
    override func getDates() -> [Date] {
        var dates: [Date] = [visibleDate]
        for i in 1...kNearItemsCount {
            let leftDate = visibleDate.dateByAddingDays(-i)!
            dates.insert(leftDate, at: 0)
            let rightDate = visibleDate.dateByAddingDays(i)!
            dates.append(rightDate)
        }

        return dates
    }
    
    override func validatedDate(_ date: Date) -> Date {
        return date.startOfDay()
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return CalendarDayTimelineCell.self
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? CalendarDayTimelineCell else {
            return
        }
        
        let date = adapter.item(at: indexPath) as! Date
    }
}

class CalendarDayTimelineCell: TPCollectionCell {
    
    private lazy var timelineView: CalendarDayTimelineView = {
        let view = CalendarDayTimelineView(frame: .zero)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(timelineView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        timelineView.frame = bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        timelineView.reset()
    }
}
