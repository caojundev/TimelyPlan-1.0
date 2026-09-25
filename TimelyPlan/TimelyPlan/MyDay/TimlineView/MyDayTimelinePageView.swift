//
//  MyDayTimelinePageView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/19.
//

import Foundation
import UIKit

class MyDayTimelinePageView: TPDayPageView {

    /// 习惯记录供应器
    var habitRecordProvider = MyDayHabitRecordProvider()
    
    var eventAddController: EventAddController?
    
    override func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return MyDayTimelinePageCell.self
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        super.adapter(adapter, didDequeCell: cell, at: indexPath)
        guard let cell = cell as? MyDayTimelinePageCell else {
            return
        }
        
        let timelineView = cell.timelineView
        timelineView.habitRecordProvider = habitRecordProvider
        timelineView.eventAddController = eventAddController
        timelineView.allDayEventsDisplayOption = MyDaySetting.shared.allDayEventsDisplayOption
        /// 同步全天区块的展开状态，避免其他分页单元格的状态不同步
        timelineView.isAllDayExpanded = MyDayState.shared.isAllDayExpanded
        timelineView.loadEvents(on: cell.date)
    }
    
    func setAllDayEventsDisplayOption(_ option: TimelineAllDayEventsDisplayOption) {
        guard let cells = adapter.visibleCells as? [MyDayTimelinePageCell] else {
            return
        }
        
        for cell in cells {
            cell.timelineView.allDayEventsDisplayOption = option
        }
    }
}

class MyDayTimelinePageCell: TPDayPageCell {

    private(set) lazy var timelineView: MyDayTimelineView = {
        let view = MyDayTimelineView(frame: bounds)
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
        timelineView.clear()
    }
}
