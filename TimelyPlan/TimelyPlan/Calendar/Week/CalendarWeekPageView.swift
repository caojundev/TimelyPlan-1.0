//
//  CalendarWeekPageView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/8.
//

import Foundation
import UIKit

protocol CalendarWeekPageViewDelegate: AnyObject {
    
    /// 滚动到特定日期
    func calendarWeekPageView(_ weekPageView: CalendarWeekPageView, didScrollTo date: Date)
    
    func calendarWeekPageView(_ weekPageView: CalendarWeekPageView,
                              fetchEventsForWeek weekStartDate: Date,
                              completion: @escaping ([CalendarEvent]?) -> Void)
}

class CalendarWeekPageView: TPCollectionWrapperView,
                            TPCollectionViewAdapterDataSource,
                            TPCollectionViewAdapterDelegate {

    weak var delegate: CalendarWeekPageViewDelegate?
    
    /// 周开始日
    var firstWeekday: Weekday = .sunday
    
    /// 当前可见日期
    private(set) var visibleDate: Date!
    
    /// 左右条目数
    private let kNearItemsCount = 6
    
    /// 滚动同步器
    private lazy var synchronizer: CalendarWeekScrollSynchronizer = {
        return CalendarWeekScrollSynchronizer(hoursView: hoursView)
    }()
    
    private let hoursViewWidth = 50.0
    private let hoursView: CalendarWeekTimelineHoursView = {
        let view = CalendarWeekTimelineHoursView(frame: .zero)
        return view
    }()
    
    private let allDayEventLayoutManager = CalendarStripLayoutManager()
    
    init(frame: CGRect, visibleDate: Date = .now) {
        super.init(frame: frame)
        self.visibleDate = visibleDate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        addSubview(hoursView)
        addSeparator(position: .top)
        scrollDirection = .horizontal
        adapter.cellStyle.backgroundColor = .clear
        adapter.cellStyle.selectedBackgroundColor = .clear
        adapter.dataSource = self
        adapter.delegate = self
    }
    
    override func setupCollectionView() {
        super.setupCollectionView()
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let weekDaysViewHeight = CalendarWeekView.weekDaysViewHeight
        hoursView.width = hoursViewWidth
        hoursView.height = bounds.height - weekDaysViewHeight
        hoursView.top = weekDaysViewHeight
        DispatchQueue.main.async {
            self.updateContentOffset(animated: false)
        }
    }
    
    override func animatedContainerView(_ containerView: TPAnimatedContainerView, frameForContentView contentView: UIView) -> CGRect {
        return CGRect(x: hoursViewWidth,
                      y: 0.0,
                      width: bounds.width - hoursViewWidth,
                      height: bounds.height)
    }
    
    // MARK: -
    func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        return [String(describing: type(of: self)) as NSString]
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        let currentDate = visibleDate.startOfWeek(firstWeekday: firstWeekday)
        var dates: [Date] = [currentDate]
        for i in 1...kNearItemsCount {
            let leftDate = currentDate.dateByAddingWeeks(-i)!
            dates.insert(leftDate, at: 0)
            let rightDate = currentDate.dateByAddingWeeks(i)!
            dates.append(rightDate)
        }
        
        return dates as [NSDate]
    }

    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return CalendarWeekPageCell.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? CalendarWeekPageCell,
              let date = adapter.item(at: indexPath) as? Date else {
            return
        }
        
        /// 需要立即布局以解决滚动跳动的问题
        cell.layoutIfNeeded()
        cell.weekStartDate = date
        cell.reloadData()
        synchronizer.addEventsView(cell.eventsView)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return weekCellSize
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let dayWidth = dayWidth
        let offsetX = targetContentOffset.pointee.x
        let targetX = round(offsetX / dayWidth) * dayWidth
        targetContentOffset.pointee.x = targetX
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print(#function)
        let toDate = date(at: scrollView.contentOffset.x)
        if visibleDate == toDate {
            return
        }
    
        visibleDate = toDate
        let shouldPerformUpdate = shouldPerformUpdate()
        if shouldPerformUpdate {
            performUpdate()
        }
         
        /// 日期变化回调
        delegate?.calendarWeekPageView(self, didScrollTo: toDate)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        updateAllDayHeight(with: offset)
        updateAllDayVisibleOffset(with: offset)
    }
    
    private func updateAllDayVisibleOffset(with contentOffset: CGPoint) {
        let visibleCells = adapter.visibleCells as! [CalendarWeekPageCell]
        for cell in visibleCells {
            let visibleOffset = collectionView.convert(contentOffset, toViewOrWindow: cell)
            cell.didChangeVisibleOffset(visibleOffset)
        }
    }
    
    private func updateAllDayHeight(with contentOffset: CGPoint) {
        let dateRange = visibleDateRange(at: contentOffset)
        let visibleCells = adapter.visibleCells as! [CalendarWeekPageCell]
        var maxRow = -1
        for cell in visibleCells {
            let result = cell.eventsView.maxRowForAllDayView(in: dateRange)
            if maxRow < result {
                maxRow = result
            }
        }
    
        var allDayHeight = 0.0
        if maxRow >= 0 {
            let linesCount = min(maxRow + 1, CalendarWeekConstant.allDayMaxStripLinesCount)
            allDayHeight = allDayEventLayoutManager.heightThatFits(linesCount)
        }
        
        synchronizer.allDayHeight = allDayHeight
    }
    
    // MARK: - Public Methods
    override func reloadData() {
        super.reloadData()
        updateContentOffset(animated: false)
    }
    
    override func reloadData(animateStyle: SlideStyle) {
        super.reloadData(animateStyle: animateStyle)
        updateContentOffset(animated: false)
    }
    
    /// 当前月份日期组件
    func setVisibleDate(_ date: Date, animated: Bool) {
        if visibleDate.isInSameDayAs(date) {
            return
        }
        
        /// 在同一周
        if visibleDate.isInSameWeekAs(date, firstWeekday: firstWeekday) {
            visibleDate = date
            updateContentOffset(animated: true)
            return
        }
                
        /// 在不同周
        let animateStyle = SlideStyle.horizontalStyle(fromValue: visibleDate, toValue: date)
        visibleDate = date        
        reloadData(animateStyle: animateStyle)
    }
    
    func goPreviousDay() {
        visibleDate = visibleDate.dateByAddingDays(-1)
        updateContentOffset(animated: true)
    }
    
    func goNextDay() {
        visibleDate = visibleDate.dateByAddingDays(1)
        updateContentOffset(animated: true)
    }
    
    func eventView(at point: CGPoint) -> CalendarEventView? {
        let touchPoint = self.convert(point, toViewOrWindow: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: touchPoint) else {
            return nil
        }
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? CalendarWeekPageCell else {
            return nil
        }
        
        let eventsView = cell.eventsView
        let convertedPoint = self.convert(point, toViewOrWindow: eventsView)
        return eventsView.eventView(at: convertedPoint)
    }
    
    // MARK: - Private Metehods
    private let preloadWeekOffset = 2
    private func shouldPerformUpdate() -> Bool {
        let currentWeekStartDate = visibleDate.startOfWeek(firstWeekday: firstWeekday)
        guard let indexPath = adapter.indexPath(of: currentWeekStartDate as NSDate) else {
            return true
        }
        
        let weekIndex = indexPath.item
        let visibleWeeksCount = collectionView.visibleCells.count
        if weekIndex >= preloadWeekOffset && weekIndex + visibleWeeksCount <= adapter.allItems().count - preloadWeekOffset {
            return false
        }

        return true
    }
    
    private func performUpdate() {
        executeWithoutAnimation {
            self.adapter.performUpdate()
            self.updateContentOffset(animated: false)
        }
    }
    
    /// 更新内容偏移
    private func updateContentOffset(animated: Bool) {
        var offset = CGPoint.zero
        offset.x = offsetX(for: visibleDate)
        collectionView.setContentOffset(offset, animated: animated)
        collectionView.layoutIfNeeded()
        updateAllDayHeight(with: offset)
        updateAllDayVisibleOffset(with: offset)
    }
    
    private func offsetX(for date: Date) -> CGFloat {
        let days = Date.days(fromDate: firstWeekStartDate, toDate: date)
        return CGFloat(days) * dayWidth
    }
    
    private func date(at offsetX: CGFloat) -> Date {
        let index = Int(round(offsetX / dayWidth))
        let date = firstWeekStartDate.dateByAddingDays(index)!
        return date
    }
    
    private func visibleDateRange(at contentOffset: CGPoint) -> (firstDate: Date, lastDate: Date) {
        let offsetX = contentOffset.x
        let index = Int(offsetX / dayWidth)
        let startDate = firstWeekStartDate.dateByAddingDays(index)!
        let collectionSize = adapter.collectionViewSize()
        let days = ceil((collectionSize.width - (CGFloat(index + 1) * dayWidth - offsetX)) / dayWidth)
        let endDate = startDate.dateByAddingDays(Int(days))!
        return (startDate, endDate)
    }
    
    
    
    // MARK: - 时间线
    func highlightRange(_ range: CalendarTimelineRange?) {
        hoursView.highlightRange(range)
    }
    
    func clearHighlight() {
        hoursView.clearHighlight()
    }
    
    /// 获取y坐标对应的时间偏移
    func timeOffset(at point: CGPoint) -> Duration {
        let convertedPoint = self.convert(point, toViewOrWindow: hoursView)
        return hoursView.timeOffset(at: convertedPoint)
    }
    
    // MARK: -  Helpers
    /// 日宽度
    private let minimumDayWidth = 120.0
    private let maximumDayWidth = 160.0
    private var dayWidth: CGFloat {
        let collectionSize = adapter.collectionViewSize()
        let width = ceil(collectionSize.width / CGFloat(DAYS_PER_WEEK))
        return min(max(minimumDayWidth, width), maximumDayWidth)
    }
    
    /// 周单元格尺寸
    private var weekCellSize: CGSize {
        let width = dayWidth * CGFloat(DAYS_PER_WEEK)
        let height = adapter.collectionViewSize().height
        let size = CGSize(width: width, height: height)
        return size
    }
    
    /// 首个周开始日
    private var firstWeekStartDate: Date {
         let weekStartDate = adapter.allItems().first as? Date
         return weekStartDate!
     }
     
}

extension CalendarWeekPageView {
    
    /// 时间线滚动视图
    var timelineScrollView: UIScrollView {
        return hoursView.contentView
    }
}
