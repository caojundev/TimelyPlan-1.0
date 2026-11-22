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

    /// 是否允许左右滑动切换日期
    var allowsDateSwitchByPaging: Bool = true {
        didSet {
            collectionView?.isScrollEnabled = allowsDateSwitchByPaging
            collectionView?.isPagingEnabled = allowsDateSwitchByPaging
        }
    }

    override func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return MyDayTimelinePageCell.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        /// 尺寸变化（旋转 / 分屏）后分页单元格沿用旧尺寸，需要重新计算并回到当前日期所在页
        guard abs(collectionView.frame.width - bounds.width) > 0.5 else {
            return
        }
        
        collectionView.frame = bounds
        flowLayout.invalidateLayout()
        updateContentOffset(animated: false)
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
    
    func setAllDayEventsDisplayOption(_ option: MyDayTimelineAllDayEventsDisplayOption) {
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
