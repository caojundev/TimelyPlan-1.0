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

}

class CalendarWeekPageView: TPCollectionWrapperView,
                            TPCollectionViewAdapterDataSource,
                            TPCollectionViewAdapterDelegate,
                            CalendarWeekViewDelegate {

    weak var delegate: CalendarWeekPageViewDelegate?
    
    /// 周视图天数
    var daysInWeekView: Int = 3 {
        didSet {
            if daysInWeekView != oldValue {
                flowLayout.invalidateLayout()
                setNeedsLayout()
                dragDropManager.dismiss()
            }
        }
    }
    
    /// 周开始日
    var firstWeekday: Weekday = .sunday
    
    /// 显示农历
    var showLunar: Bool = true
    
    /// 显示中国节假日
    var showChineseHolidays: Bool = true
    
    /// 显示周数
    var showWeekNumber: Bool = true {
        didSet {
            weekNumberView.showWeekNumber = showWeekNumber
        }
    }
    
    /// 当前可见日期
    private(set) var visibleDate: Date!
    
    /// 左右条目数
    private let kNearItemsCount = 6
    
    /// 滚动同步器
    private(set) lazy var synchronizer: CalendarWeekScrollSynchronizer = {
        return CalendarWeekScrollSynchronizer(hoursView: hoursView)
    }()
    
    private let weekNumberView = CalendarWeekNumberContainerView()
    
    private let hoursViewWidth = 50.0
    private lazy var hoursView: CalendarWeekTimelineHoursView = {
        let view = CalendarWeekTimelineHoursView(frame: .zero)
        return view
    }()
    
    /// 全天布局管理器
    private let allDayEventLayoutManager = CalendarStripLayoutManager()
    
    private lazy var dragDropManager: CalendarDragDropManager = {
        return CalendarDragDropManager(pageView: self)
    }()
    
    init(frame: CGRect, visibleDate: Date = .now) {
        super.init(frame: frame)
        self.visibleDate = visibleDate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        weekNumberView.showWeekNumber = showWeekNumber
        addSubview(weekNumberView)
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
        dragDropManager.eventsFrame = eventsFrame()
        
        weekNumberView.width = hoursViewWidth
        weekNumberView.height = weekDaysViewHeight
        weekNumberView.origin = .zero
        
        hoursView.width = hoursViewWidth
        hoursView.height = bounds.height - weekDaysViewHeight
        hoursView.top = weekDaysViewHeight
        DispatchQueue.main.async {
            self.updateContentOffset(animated: false)
        }
    }
    
    /// 事项显示区域
    func eventsFrame() -> CGRect {
        let weekDaysViewHeight = CalendarWeekView.weekDaysViewHeight
        return CGRect(x: hoursViewWidth,
                      y: weekDaysViewHeight,
                      width: bounds.width - hoursViewWidth,
                      height: bounds.height - weekDaysViewHeight)
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
                let weekStartDate = adapter.item(at: indexPath) as? Date else {
            return
        }
        
        cell.layoutIfNeeded() /// 需要立即布局以解决滚动跳动的问题
        let weekView = cell.weekView
        weekView.delegate = self
        weekView.showLunar = showLunar
        weekView.showChineseHolidays = showChineseHolidays
        if weekView.weekStartDate != weekStartDate {
            weekView.loadEvents(with: weekStartDate)
        }
        
        synchronizer.addSynchronizableView(weekView.eventsView)
    }

    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return weekCellSize
    }
    
    // MARK: - CalendarWeekViewDelegate
    func calendarWeekViewDidLoadAllDayEvents(_ view: CalendarWeekView) {
        updateAllDay(with: collectionView.contentOffset)
    }

    func calendarWeekView(_ view: CalendarWeekView, longPressEvent event: CalendarEvent) {
        
    }
    
    private var axisLayout = CalendarAxisLayout()
    
    func calendarWeekView(_ view: CalendarWeekView, didTapLocation location: CGPoint, onDate date: Date) {
        var startDate = axisLayout.date(of: location)
        startDate = startDate.dateByReplacingDay(with: date)
        let endDate = startDate.dateByAddingMinutes(20)!
        let dateRange = CalendarTimelineDateRange(start: startDate, end: endDate)
        dragDropManager.showAddEvent(with: dateRange)
        
        print("\(date.yearMonthDayString(omitYear: true)) - \(location)")
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let dayWidth = dayWidth
        let offsetX = targetContentOffset.pointee.x
        let targetX = round(offsetX / dayWidth) * dayWidth
        targetContentOffset.pointee.x = targetX
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let toDate = date(at: scrollView.contentOffset.x)
        if visibleDate == toDate {
            return
        }
    
        visibleDate = toDate
        let shouldPerformUpdate = shouldPerformUpdate()
        if shouldPerformUpdate {
            performUpdate()
        }
         
        updateWeekNumber()
        /// 日期变化回调
        delegate?.calendarWeekPageView(self, didScrollTo: toDate)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dragDropManager.dismiss()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        updateAllDay(with: offset)
    }
    
    // MARK: - Update
    private func updateWeekNumber() {
        guard let date = self.visibleDate else {
            return
        }
        
        weekNumberView.weekNumber = Calendar.weekNumber(for: date, firstWeekday: firstWeekday)
    }
    
    private func updateAllDay(with contentOffset: CGPoint) {
        updateAllDayVisibleOffset(with: contentOffset)
        updateAllDayHeight(with: contentOffset)
    }
    
    private func updateAllDayVisibleOffset(with contentOffset: CGPoint) {
        let visibleCells = adapter.visibleCells as! [CalendarWeekPageCell]
        for cell in visibleCells {
            let visibleOffset = collectionView.convert(contentOffset, toViewOrWindow: cell)
            cell.weekView.didChangeVisibleOffset(visibleOffset)
        }
    }
    
    private func updateAllDayHeight(with contentOffset: CGPoint) {
        let dateRange = visibleDateRange(at: contentOffset)
        let visibleCells = adapter.visibleCells as! [CalendarWeekPageCell]
        var maxRow = -1
        for cell in visibleCells {
            let result = cell.weekView.maxRowForAllDayView(in: dateRange)
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
        updateWeekNumber()
    }
    
    override func reloadData(animateStyle: SlideStyle) {
        super.reloadData(animateStyle: animateStyle)
        updateContentOffset(animated: false)
        updateWeekNumber()
    }
    
    func reloadWeekDays() {
        let visibleCells = adapter.visibleCells as! [CalendarWeekPageCell]
        for cell in visibleCells {
            let weekView = cell.weekView
            weekView.showLunar = showLunar
            weekView.showChineseHolidays = showChineseHolidays
            weekView.reloadWeekDays()
        }
    }
    
    /// 当前月份日期组件
    func setVisibleDate(_ date: Date, animated: Bool) {
        if visibleDate.isInSameDayAs(date) {
            return
        }
        
        dragDropManager.dismiss()
        
        /// 在同一周
        if visibleDate.isInSameWeekAs(date, firstWeekday: firstWeekday) {
            visibleDate = date
            updateContentOffset(animated: true)
            updateWeekNumber()
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
        updateWeekNumber()
    }
    
    func goNextDay() {
        visibleDate = visibleDate.dateByAddingDays(1)
        updateContentOffset(animated: true)
        updateWeekNumber()
    }
    
    /// 日期相对当前显示首日的列索引
    func column(of date: Date) -> Int {
        let days = Date.days(fromDate: visibleDate, toDate: date)
        return days
    }
    
    func date(of column: Int) -> Date {
        return visibleDate.dateByAddingDays(column)!
    }
    
    
    func eventView(at point: CGPoint) -> CalendarEventView? {
        let touchPoint = self.convert(point, toViewOrWindow: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: touchPoint) else {
            return nil
        }
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? CalendarWeekPageCell else {
            return nil
        }
        
        let eventsView = cell.weekView.eventsView
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
            self.adapter.performUpdate(updateVisibleItems: false)
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
    func highlightDateRange(_ dateRange: CalendarTimelineDateRange) {
        hoursView.highlightDateRange(dateRange)
    }
    
    func clearHighlight() {
        hoursView.clearHighlight()
    }
    
    // MARK: -  Helpers
    var isMoving: Bool {
        let offset = collectionView.contentOffset
        let dayWidth = dayWidth
        guard dayWidth > 0 else {
            return false
        }

        let remainder = offset.x.truncatingRemainder(dividingBy: dayWidth)
        return abs(remainder) > 1e-10
    }
    
    /// 日最小宽度
    private let minimumDayWidth = 40.0
    
    var dayWidth: CGFloat {
        let collectionSize = adapter.collectionViewSize()
        let daysInWeekView = clampedValue(daysInWeekView,
                                          CalendarSetting.minDaysInWeek,
                                          CalendarSetting.maxDaysInWeek)
        let width = ceil(collectionSize.width / CGFloat(daysInWeekView))
        return max(minimumDayWidth, width)
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
