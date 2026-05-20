//
//  CalendarPageView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/18.
//

import Foundation
import UIKit

protocol CalendarPageViewDelegate: AnyObject {
    
    /// 滚动到特定日期
    func calendarPageView(_ pageView: CalendarPageView, didScrollTo date: Date)
    
    func calendarPageViewWillEndDragging(_ pageView: CalendarPageView, withTargetDate date: Date)
    
    func calendarPageView(_ pageView: CalendarPageView, newEventWithDateRange dateRange: CalendarTimelineDateRange)
}

class CalendarPageView: TPCollectionWrapperView,
                        TPCollectionViewAdapterDataSource,
                        TPCollectionViewAdapterDelegate,
                        CalendarPageTimelineViewDelegate,
                        CalendarDragDropManageViewDelegate {
    
    /// 代理对象
    weak var delegate: CalendarPageViewDelegate?
    
    /// 每一页包含的天数
    var pageDaysCount = DAYS_PER_WEEK
    
    /// 屏幕首选显示天数
    var displayDays: Int = 3 {
        didSet {
            if displayDays != oldValue {
                dragDropManager.dismiss()
                flowLayout.invalidateLayout()
                setNeedsLayout()
            }
        }
    }
    
    /// 周开始日
    var firstWeekday: Weekday = .sunday
    
    /// 显示农历
    var showLunar: Bool = true
    
    /// 显示中国节假日
    var showChineseHolidays: Bool = true
    
    /// 当前可见日期
    private(set) var visibleDate: Date!

    /// 滚动同步器
    private(set) lazy var synchronizer: CalendarPageScrollSynchronizer = {
        return CalendarPageScrollSynchronizer(hoursView: hoursView)
    }()
    
    /// 小时时间线视图
    let hoursViewWidth = 50.0
    private lazy var hoursView: CalendarPageTimelineHoursView = {
        let view = CalendarPageTimelineHoursView(frame: .zero)
        return view
    }()
    
    /// 全天布局管理器
    private let allDayEventLayoutManager = CalendarStripLayoutManager()
    
    /// 拖放管理器
    private lazy var dragDropManager: CalendarDragDropManager = {
        let manager = CalendarDragDropManager(pageView: self)
        manager.delegate = self
        return manager
    }()
    
    // 时间线坐标轴布局
    private var axisLayout = CalendarAxisLayout()
    
    /// 左右条目数
    let nearItemsCount = 6

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
        let eventsFrame = eventsFrame()
        dragDropManager.eventsFrame = eventsFrame
        
        hoursView.width = hoursViewWidth
        hoursView.height = eventsFrame.height
        hoursView.top = eventsFrame.minY
        
        DispatchQueue.main.async {
            self.updateContentOffset(animated: false)
        }
    }
    
    override func animatedContainerView(_ containerView: TPAnimatedContainerView, frameForContentView contentView: UIView) -> CGRect {
        let eventFrame = eventsFrame()
        return CGRect(x: eventFrame.minX,
                      y: 0.0,
                      width: eventFrame.width,
                      height: bounds.height)
    }
    
    // MARK: - 子类重写方法
    /// 事项显示区域
    func eventsFrame() -> CGRect {
        return CGRect(x: hoursViewWidth,
                      y: 0.0,
                      width: bounds.width - hoursViewWidth,
                      height: bounds.height)
    }
    
    func getPageStartDates() -> [Date] {
        return []
    }
    
    func shouldPerformUpdate() -> Bool {
        return true
    }
    
    func willEndDragging(withTargetDate date: Date) {
        
    }
    
    // MARK: - 更新
    private func updateAllDay(with contentOffset: CGPoint) {
        updateAllDayVisibleOffset(with: contentOffset)
        updateAllDayHeight(with: contentOffset)
    }
    
    private func updateAllDayVisibleOffset(with contentOffset: CGPoint) {
        let visibleCells = adapter.visibleCells as! [CalendarPageTimelineCell]
        for cell in visibleCells {
            let visibleOffset = collectionView.convert(contentOffset, toViewOrWindow: cell)
            cell.timelineView.didChangeVisibleOffset(visibleOffset)
        }
    }
    
    private func updateAllDayHeight(with contentOffset: CGPoint) {
        let dateRange = visibleDateRange(at: contentOffset)
        let visibleCells = adapter.visibleCells as! [CalendarPageTimelineCell]
        var maxRow = -1
        for cell in visibleCells {
            let result = cell.timelineView.maxRowForAllDayView(in: dateRange)
            if maxRow < result {
                maxRow = result
            }
        }
    
        var allDayHeight = 0.0
        if maxRow >= 0 {
            let linesCount = min(maxRow + 1, CalendarConstant.allDayMaxStripLinesCount)
            allDayHeight = allDayEventLayoutManager.heightThatFits(linesCount)
        }
        
        synchronizer.allDayHeight = allDayHeight
    }
    
    /// 更新内容偏移
    private func updateContentOffset(animated: Bool) {
        var offset = CGPoint.zero
        offset.x = offsetX(for: visibleDate)
        collectionView.setContentOffset(offset, animated: animated)
        collectionView.layoutIfNeeded()
        updateAllDayHeight(with: offset)
    }
    
    private func performUpdate() {
        executeWithoutAnimation {
            self.adapter.performUpdate(updateVisibleItems: false)
            self.updateContentOffset(animated: false)
        }
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
        
        dragDropManager.dismiss()
        
        // 重新加载数据
        let animateStyle = SlideStyle.horizontalStyle(fromValue: visibleDate,
                                                      toValue: date)
        visibleDate = date
        reloadData(animateStyle: animateStyle)
    }
    
    func goPreviousDay() {
        let toDate = visibleDate.dateByAddingDays(-1)!
        goToDate(date: toDate)
    }
    
    func goNextDay() {
        let toDate = visibleDate.dateByAddingDays(1)!
        goToDate(date: toDate)
    }
    
    /// 日期相对当前显示首日的列索引
    func column(of date: Date) -> Int {
        let days = Date.days(fromDate: visibleDate, toDate: date)
        return days
    }
    
    func date(of column: Int) -> Date {
        return visibleDate.dateByAddingDays(column)!
    }

    // MARK: - 时间线
    func highlightDateRange(_ dateRange: CalendarTimelineDateRange) {
        hoursView.highlightDateRange(dateRange)
    }
    
    func clearHighlight() {
        hoursView.clearHighlight()
    }
    
    // MARK: -
    func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        return [String(describing: type(of: self)) as NSString]
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        let dates = getPageStartDates()
        return dates as [NSDate]
    }

    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return CalendarPageTimelineCell.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? CalendarPageTimelineCell,
              let firstDate = adapter.item(at: indexPath) as? Date else {
            return
        }
        
        cell.layoutIfNeeded() /// 需要立即布局以解决滚动跳动的问题
        
        let timelineView = cell.timelineView!
        timelineView.delegate = self
        timelineView.showLunar = showLunar
        timelineView.showChineseHolidays = showChineseHolidays
        if timelineView.firstDate != firstDate {
            timelineView.loadEvents(with: firstDate)
        }
        
        let eventsView = timelineView.eventsView
        synchronizer.addSynchronizableView(eventsView)
    }

    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return pageCellSize
    }
    
    // MARK: - CalendarPageTimelineViewDelegate
    
    func pageTimelineViewDidLoadAllDayEvents(_ view: CalendarPageTimelineView) {
        updateAllDay(with: collectionView.contentOffset)
    }
    
    func pageTimelineView(_ view: CalendarPageTimelineView, didTapLocation location: CGPoint, onDate date: Date) {
        guard !dragDropManager.isActive else {
            dragDropManager.dismiss()
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        let minutes = CalendarSetting.shared.getDefaultEventDuration()
        let dateRange = axisLayout.snappedDateRange(onDay: date,
                                                    touchPoint: location,
                                                    minutes: minutes)
        dragDropManager.showAddEvent(with: dateRange)
    }
    
    func pageTimelineView(_ view: CalendarPageTimelineView, longPressEvent event: CalendarEvent) {
        guard !dragDropManager.isActive else {
            dragDropManager.dismiss()
            return
        }
        
        TPImpactFeedback.impactWithMediumStyle()
        dragDropManager.showEvent(event)
    }
    
    func pageTimelineView(_ view: CalendarPageTimelineView, didTapEvent event: CalendarEvent) {
        guard !dragDropManager.isActive else {
            dragDropManager.dismiss()
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
    }
    
    
    // MARK: - CalendarDragDropManageViewDelegate
    
    func dragDropManageView(_ view: CalendarDragDropManageView, newEventWithDateRange dateRange: CalendarTimelineDateRange) {
        TPImpactFeedback.impactWithSoftStyle()
        dragDropManager.dismiss()
        delegate?.calendarPageView(self, newEventWithDateRange: dateRange)
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let dayWidth = dayWidth
        let targetOffsetX = targetContentOffset.pointee.x
        var targetPage = round(targetOffsetX / dayWidth)
        if abs(velocity.x) < 1.0 {
            let velocityThreshold: CGFloat = 0.2
            if velocity.x > velocityThreshold {
                targetPage += 1
            } else if velocity.x < -velocityThreshold {
                targetPage -= 1
            }
        }
        
        let targetX = targetPage * dayWidth
        targetContentOffset.pointee.x = targetX
        let targetDate = date(at: targetX)
        willEndDragging(withTargetDate: targetDate)
        delegate?.calendarPageViewWillEndDragging(self, withTargetDate: targetDate)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let toDate = date(at: scrollView.contentOffset.x)
        if visibleDate == toDate {
            return
        }
    
        visibleDate = toDate
        if shouldPerformUpdate() {
            performUpdate()
        }
        
        /// 日期变化回调
        delegate?.calendarPageView(self, didScrollTo: toDate)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dragDropManager.dismiss()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        updateAllDay(with: offset)
    }
    
    // MARK: -  Helpers
    /// 页面是否在移动中
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
    
    /// 每日宽度
    var dayWidth: CGFloat {
        let collectionSize = adapter.collectionViewSize()
        let width = ceil(collectionSize.width / CGFloat(displayDays))
        return max(minimumDayWidth, width)
    }
    
    /// 手动跳转特定日期
    private func goToDate(date: Date) {
        visibleDate = date
        if shouldPerformUpdate() {
            adapter.performUpdate(updateVisibleItems: false)
        }
        
        updateContentOffset(animated: true)
        delegate?.calendarPageView(self, didScrollTo: date)
    }
    
    /// 获取指定日期对应的水平偏移
    private func offsetX(for date: Date) -> CGFloat {
        let days = Date.days(fromDate: firstPageStartDate, toDate: date)
        return CGFloat(days) * dayWidth
    }
    
    /// 获取指定内容偏移对应的日期
    private func date(at offsetX: CGFloat) -> Date {
        let index = Int(round(offsetX / dayWidth))
        let date = firstPageStartDate.dateByAddingDays(index)!
        return date
    }
    
    /// 获取指定内容偏移时可见的日期范围
    private func visibleDateRange(at contentOffset: CGPoint) -> (firstDate: Date,
                                                                 lastDate: Date) {
        let offsetX = contentOffset.x
        let index = Int(offsetX / dayWidth)
        let startDate = firstPageStartDate.dateByAddingDays(index)!
        let collectionSize = adapter.collectionViewSize()
        let days = ceil((collectionSize.width - (CGFloat(index + 1) * dayWidth - offsetX)) / dayWidth)
        let endDate = startDate.dateByAddingDays(Int(days))!
        return (startDate, endDate)
    }
    
    /// 首个页面开始日
    private var firstPageStartDate: Date {
         let startDate = adapter.allItems().first as? Date
         return startDate!
    }
    
    /// 页面单元格尺寸
    private var pageCellSize: CGSize {
        let width = dayWidth * CGFloat(pageDaysCount)
        let height = adapter.collectionViewSize().height
        let size = CGSize(width: width, height: height)
        return size
    }
}
