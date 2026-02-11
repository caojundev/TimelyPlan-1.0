//
//  FocusTimelineDayPageView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/7.
//

import Foundation

class FocusTimelineDayPageView: CalendarDatePageView,
                                FocusTimelineEventProvider {
    
    
    weak var eventProvider: FocusTimelineEventProvider?
    
    /// 小时高度
    var hourHeight: CGFloat = 80.0 {
        didSet {
            updateHourHeight()
        }
    }
    
    /// 时间线打开时自动定位到的小时
    var autoScrollHour: Int = 6
    
    /// 滚动同步器
    private var synchronizer: FocusTimelineSynchronizer?
    
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
        /// 需要立即布局以解决滚动跳动的问题
        cell.layoutIfNeeded()
        
        guard let cell = cell as? FocusTimelineDayTimelineCell else {
            return
        }
        
        let timelineView = cell.timelineView
        timelineView.hourHeight = hourHeight
        timelineView.eventProvider = self
        
        let date = adapter.item(at: indexPath) as! Date
        timelineView.date = date
        timelineView.reloadData()

        /// 将时间线视图添加到同步器
        let synchronizer = getSynchronizer()
        synchronizer.addTimelineView(timelineView)
    }
    
    private func getSynchronizer() -> FocusTimelineSynchronizer {
        if let synchronizer = synchronizer {
            return synchronizer
        }
        
        let synchronizer = FocusTimelineSynchronizer()
        let maxY = hourHeight * CGFloat(HOURS_PER_DAY) - height
        let offsetY = CGFloat(autoScrollHour) * hourHeight
        synchronizer.setContentOffset(CGPoint(x: 0.0, y: min(offsetY, maxY)))
        self.synchronizer = synchronizer
        return synchronizer
    }
    
    /// 更新时间线视图小时高度
    private func updateHourHeight() {
        guard let cells = collectionView.visibleCells as? [FocusTimelineDayTimelineCell] else {
            return
        }
        
        for cell in cells {
            cell.timelineView.hourHeight = hourHeight
        }
    }
    
    private func isVisibleDate(_ date: Date) -> Bool {
        if visibleDate.isInSameDayAs(date) {
            return true
        }

        if collectionView.isDragging {
            let dates = adapter.allItems() as! [Date]
            /// 当 contentOffset 当前位置非整页时，计算当前显示的是哪两页
            let currentPageIndex = validatedIndex(Int(collectionView.contentOffset.x / bounds.width))
            if dates[currentPageIndex].isInSameDayAs(date) {
                return true
            }

            // 非显示完整页面，检查下一页
            let nextPageIndex = validatedIndex(currentPageIndex + 1)
            if dates[nextPageIndex].isInSameDayAs(date) {
                return true
            }
        }
        
        if let visibleCells = collectionView.visibleCells as? [FocusTimelineDayTimelineCell] {
            for visibleCell in visibleCells {
                if visibleCell.date.isInSameDayAs(date) {
                    return true
                }
            }
        }
        
        return false
    }
    
    // MARK: - FocusTimelineEventProvider
    func fetchTimelineEvents(for date: Date, completion: @escaping ([FocusTimelineEvent]?) -> Void) {
        guard isVisibleDate(date) else {
            completion(nil)
            return
        }
        
        eventProvider?.fetchTimelineEvents(for: date, completion: completion)
    }
}

class FocusTimelineDayTimelineCell: TPCollectionCell {
    var date: Date {
        return timelineView.date
    }
    
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
