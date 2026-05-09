//
//  CalendarDayPagingView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/3.
//

import Foundation

class CalendarDayPagingView: CalendarDatePageView {
    
    /// 小时高度
    var hourHeight: CGFloat = 80.0 {
        didSet {
            updateHourHeight()
        }
    }
    
    private let timelineTopPadding = 20.0
    
    private let timelineBottomPadding = 40.0
    
    /// 时间线打开时自动定位到的小时
    lazy var autoScrollHour: Int = {
        return Date().hour
    }()
    
    /// 滚动同步器
    private lazy var synchronizer: CalendarDayTimelineSynchronizer = {
        let synchronizer = CalendarDayTimelineSynchronizer()
        let maxY = hourHeight * CGFloat(HOURS_PER_DAY)
        let offsetY = CGFloat(autoScrollHour) * hourHeight
        synchronizer.setContentOffset(CGPoint(x: 0.0, y: min(offsetY, maxY)))
        return synchronizer
    }()
    
    private let allDayEventLayoutManager = CalendarStripLayoutManager()
    
    override func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return CalendarDayTimelineCell.self
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? CalendarDayTimelineCell else {
            return
        }
    
        /// 需要立即布局以解决滚动跳动的问题
        cell.layoutIfNeeded()
        
        /// 配置时间线视图
        let timelineView = cell.timelineView
        timelineView.hourHeight = hourHeight
        timelineView.topPadding = timelineTopPadding
        timelineView.bottomPadding = timelineBottomPadding
        timelineView.layoutIfNeeded()
        
        /// 将时间线视图添加到同步器
        synchronizer.addTimelineView(timelineView)
        
        let date = adapter.item(at: indexPath) as! Date
        if timelineView.date != date, isVisibleDate(date) {
            timelineView.loadEvents(for: date)
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateAllDay(with: scrollView.contentOffset)
        print(#function)
    }

    override func updateContentOffset(animated: Bool) {
        super.updateContentOffset(animated: animated)
        collectionView.layoutIfNeeded() /// 先完成布局
        let contentOffset = collectionView.contentOffset
        self.updateAllDay(with: contentOffset)
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        super.scrollViewDidEndDecelerating(scrollView)
        self.updateAllDay(with: scrollView.contentOffset)
        print(#function)
    }
    
    // MARK: - 更新布局
    private func updateAllDay(with contentOffset: CGPoint) {
        updateAllDayVisibleOffset(with: contentOffset)
        updateAllDayHeight(with: contentOffset)
    }
    
    private func updateAllDayVisibleOffset(with contentOffset: CGPoint) {
//        let visibleCells = adapter.visibleCells as! [CalendarDayTimelineCell]
//        for cell in visibleCells {
//            let visibleOffset = collectionView.convert(contentOffset, toViewOrWindow: cell)
//            cell.didChangeVisibleOffset(visibleOffset)
//        }
    }

    private func updateAllDayHeight(with contentOffset: CGPoint) {
        let visibleCells = adapter.visibleCells as! [CalendarDayTimelineCell]
        var maxRow = -1
        for cell in visibleCells {
            let result = cell.timelineView.maxRowForAllDayView()
            if maxRow < result {
                maxRow = result
            }
        }
    
        var allDayHeight = 0.0
        if maxRow >= 0 {
            let linesCount = min(maxRow + 1, CalendarDayConstant.allDayMaxStripLinesCount)
            allDayHeight = allDayEventLayoutManager.heightThatFits(linesCount)
        }
    
        synchronizer.allDayHeight = allDayHeight
        print(allDayHeight)
        print(contentOffset)
    }
    
    // MARK: - Helpers
    private func dateRange(for visibleCells: [CalendarDayTimelineCell]) -> (firstDate: Date, lastDate: Date) {
        var startDate: Date = .now
        var endDate: Date = startDate
        for visibleCell in visibleCells {
            let date = visibleCell.timelineView.date
            if date < startDate {
                startDate = date
            }
            
            if date > endDate {
                endDate = date
            }
        }
        
        return (startDate, endDate)
    }
    
    /// 更新时间线视图小时高度
    private func updateHourHeight() {
        guard let cells = collectionView.visibleCells as? [CalendarDayTimelineCell] else {
            return
        }
        
        for cell in cells {
            cell.timelineView.hourHeight = hourHeight
        }
    }
}

class CalendarDayTimelineCell: TPCollectionCell {
    
    private(set) lazy var timelineView: CalendarDayTimelineView = {
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
}
