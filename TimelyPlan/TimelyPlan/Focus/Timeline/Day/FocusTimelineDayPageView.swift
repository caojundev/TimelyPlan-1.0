//
//  FocusTimelineDayPageView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/7.
//

import Foundation

class FocusTimelineDayPageView: CalendarDatePageView {
    
    /// 滚动同步器
    private lazy var synchronizer: FocusTimelineSynchronizer = {
        return FocusTimelineSynchronizer()
    }()
    
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
        return FocusTimelineDayTimelineCell.self
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? FocusTimelineDayTimelineCell else {
            return
        }
        
        /// 需要立即布局以解决滚动跳动的问题
        cell.layoutIfNeeded()
        
        let date = adapter.item(at: indexPath) as! Date
        cell.timelineView.date = date
        synchronizer.addTimelineView(cell.timelineView)
    }
}

class FocusTimelineDayTimelineCell: TPCollectionCell {
    
    let timelineView = FocusTimelineView(frame: .zero)

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
