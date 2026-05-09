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
    private var synchronizer: CalendarDayTimelineSynchronizer?
    
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
        let synchronizer = getSynchronizer()
        synchronizer.addTimelineView(timelineView)
        
        let date = adapter.item(at: indexPath) as! Date
        if timelineView.date != date, isVisibleDate(date) {
            timelineView.loadEvents(for: date)
            print("加载: \(date.yearMonthDayTimeString(omitYear: true)) - \(date.timeIntervalSince1970)")
        }
    }
    
    private func getSynchronizer() -> CalendarDayTimelineSynchronizer {
        if let synchronizer = synchronizer {
            return synchronizer
        }
        
        let synchronizer = CalendarDayTimelineSynchronizer()
        let maxY = hourHeight * CGFloat(HOURS_PER_DAY)
        let offsetY = CGFloat(autoScrollHour) * hourHeight
        synchronizer.setContentOffset(CGPoint(x: 0.0, y: min(offsetY, maxY)))
        self.synchronizer = synchronizer
        return synchronizer
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
