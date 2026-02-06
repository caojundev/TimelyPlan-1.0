//
//  CalendarMonthView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/22.
//

import Foundation
import UIKit

protocol CalendarMonthViewDelegate: AnyObject {
    
    /// 滚动到特定日期
    func calendarMonthView(_ monthView: CalendarMonthView, didScrollTo topWeekStartDate: Date)
    
    func calendarMonthView(_ monthView: CalendarMonthView,
                           fetchEventsForWeek weekStartDate: Date,
                           completion: @escaping ([CalendarEvent]?) -> Void)
}

class CalendarMonthView: TPCollectionWrapperView,
                         TPCollectionViewAdapterDataSource,
                         TPCollectionViewAdapterDelegate,
                         CalendarMonthWeekViewDelegate {
    
    /// 代理对象
    weak var delegate: CalendarMonthViewDelegate?
    
    /// 当前可见月份日期
    var visibleMonthDate: Date {
        return visibleMonthDate(with: topWeekStartDate)
    }
    
    /// 当前顶部周开始日期
    private(set) var topWeekStartDate: Date!
    
    /// 周开始日
    private let firstWeekday: Weekday = .sunday
    
    /// 日期数组
    private var dates: [Date] = []
    
    /// 相邻周数目
    private let nearWeeksCount = 20
    
    /// 周符号
    private let weekdaySymbolHeight = 20.0
    
    private let weekdaySymbolView: TPWeekdaySymbolView = {
        let view = TPWeekdaySymbolView(frame: .zero, style: .short)
        view.backgroundColor = .systemBackground
        view.firstWeekday = .sunday
        view.addSeparator(position: .bottom)
        return view
    }()
    
    /// 预加载索引偏移
    private let preloadOffset = 4
    
    private var colllectionFrame: CGRect {
        return bounds.inset(by: UIEdgeInsets(top: weekdaySymbolHeight))
    }

    /// 布局
    private let monthViewFlowLayout: CalendarMonthViewFlowLayout
    
    init(frame: CGRect, monthDate: Date) {
        self.monthViewFlowLayout = CalendarMonthViewFlowLayout()
        super.init(frame: frame, collectionViewLayout: self.monthViewFlowLayout)
        addSubview(weekdaySymbolView)
        adapter.dataSource = self
        adapter.delegate = self
        topWeekStartDate = monthDate.firstDayOfWeek(firstWeekday: firstWeekday)
        reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupCollectionView() {
        super.setupCollectionView()
        collectionView.isPrefetchingEnabled = false
        collectionView.scrollsToTop = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.backgroundColor = .systemBackground
    }
    
    override func layoutSubviews() {
        monthViewFlowLayout.collectionSize = colllectionFrame.size
        super.layoutSubviews()
        weekdaySymbolView.width = bounds.width
        weekdaySymbolView.height = weekdaySymbolHeight
        updateContentOffset(animated: false)
    }

    /// 更新当前日期数组
    private func updateDates() {
        var dates: [Date] = [topWeekStartDate]
        for i in 1...nearWeeksCount {
            if let previousDate = topWeekStartDate.dateByAddingWeeks(-i) {
                dates.insert(previousDate, at: 0)
            }
            
            if let nextDate = topWeekStartDate.dateByAddingWeeks(i) {
                dates.append(nextDate)
            }
        }
        
        for i in 1...monthViewFlowLayout.preferredRowsCount {
            let weeks = nearWeeksCount + i
            if let date = topWeekStartDate.dateByAddingWeeks(weeks) {
                dates.append(date)
            }
        }
        
        self.dates = dates
    }
    
    // MARK: - Public Methods
    func setVisibleDate(_ date: Date, animated: Bool = true) {
        let fromDate = topWeekStartDate!
        let toDate = date.firstDayOfWeek(firstWeekday: firstWeekday)
        topWeekStartDate = toDate
        if animated {
            let animateStyle = SlideStyle.verticalStyle(fromValue: fromDate, toValue: toDate)
            reloadData(animateStyle: animateStyle)
        } else {
            reloadData()
        }
    }
    
    override func reloadData() {
        updateDates()
        super.reloadData()
        reloadWeekdaySymbol()
        updateContentOffset(animated: false)
    }
    
    override func reloadData(animateStyle: SlideStyle) {
        updateDates()
        super.reloadData(animateStyle: animateStyle)
        reloadWeekdaySymbol()
        updateContentOffset(animated: false)
    }
    
    private func reloadWeekdaySymbol() {
        if weekdaySymbolView.firstWeekday != firstWeekday {
            weekdaySymbolView.firstWeekday = firstWeekday
            weekdaySymbolView.reloadData()
        }
    }
    
    private func shouldPerformUpdate() -> Bool {
        guard let index = dates.firstIndex(of: topWeekStartDate) else {
            return true
        }
        
        let visibleWeeksCount = collectionView.visibleCells.count
        if index > preloadOffset && index + visibleWeeksCount < dates.count - preloadOffset {
            return false
        }
        
        return true
    }
    
    private func performUpdate() {
        updateDates()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        adapter.performUpdate()
        updateContentOffset(animated: false)
        CATransaction.commit()
    }
    
    // MARK: -
    func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        return [String(describing: type(of: self)) as NSString]
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        return dates as [NSDate]
    }

    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return CalendarMonthWeekCell.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? CalendarMonthWeekCell, let date = adapter.item(at: indexPath) as? Date else {
            return
        }
        
        cell.weekStartDate = date
        cell.weekViewDelegate = self
        cell.reloadData()
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, lineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, interitemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return flowLayout.itemSize
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // MARK: - CalendarMonthWeekViewDelegate
    
    func calendarMonthWeekView(_ weekView: CalendarMonthWeekView, fetchEventsForWeek weekStartDate: Date, completion: @escaping ([CalendarEvent]?) -> Void) {
        guard let delegate = delegate else {
            completion(nil)
            return
        }

        delegate.calendarMonthView(self, fetchEventsForWeek: weekStartDate, completion: completion)
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let toDate = topWeekStartDate(at: scrollView.contentOffset)
        guard topWeekStartDate != toDate else {
            return
        }

        topWeekStartDate = toDate
        let shouldPerformUpdate = shouldPerformUpdate()
        if shouldPerformUpdate {
            performUpdate()
        }
        
        delegate?.calendarMonthView(self, didScrollTo: toDate)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let date = topWeekStartDate(at: scrollView.contentOffset)
        delegate?.calendarMonthView(self, didScrollTo: date)
    }
    
    // MARK: - TPAnimatedContainerViewDelegate
    
    override func animatedContainerView(_ containerView: TPAnimatedContainerView, frameForContentView contentView: UIView) -> CGRect {
        return colllectionFrame
    }
    
    // MARK: - Private Metehods
    /// 更新内容偏移
    private func updateContentOffset(animated: Bool) {
        guard let indexPath = adapter.indexPath(of: topWeekStartDate as NSDate) else {
            return
        }

        /// 设置新偏移
        var offset = CGPoint.zero
        offset.y = flowLayout.itemSize.height * CGFloat(indexPath.item)
        collectionView.setContentOffset(offset, animated: animated)
    }
    
    private func topWeekStartDate(at contentOffset: CGPoint) -> Date {
        var index = Int(contentOffset.y / flowLayout.itemSize.height)
        index = min(dates.count - 1, max(0, index))
        return dates[index]
    }
    
    func visibleMonthDate(with topWeekStartDate: Date) -> Date {
        var date = topWeekStartDate.dateByAddingWeeks(1)!
        date = date.dateByAddingDays(6)!
        return date.startOfMonth()
    }
}

class CalendarMonthViewFlowLayout: UICollectionViewFlowLayout {
    
    var collectionSize: CGSize = .zero {
        didSet {
            if collectionSize != oldValue {
                updateItemSize()
            }
        }
    }

    var preferredRowsCount = 6
    
    private var minimumItemHeight = 120.0
    
    /// 更新条目尺寸
    private func updateItemSize() {
        let itemWidth = collectionSize.width
        var itemHeight = collectionSize.height / CGFloat(preferredRowsCount)
        itemHeight = max(itemHeight, minimumItemHeight)
        self.itemSize = CGSize(width: itemWidth, height: itemHeight)
        self.invalidateLayout()
    }
    
    override func prepare() {
        super.prepare()
        scrollDirection = .vertical
        sectionInset = .zero
        minimumInteritemSpacing = 0.0
        minimumLineSpacing = 0.0
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        // 计算最近的单元格顶部位置
        let offsetY = proposedContentOffset.y
        let nearestPage = round(offsetY / itemSize.height)
        var targetY = nearestPage * itemSize.height
        let contentHeight = collectionView?.contentSize.height ?? .greatestFiniteMagnitude
        if targetY + collectionSize.height > contentHeight {
            targetY = CGFloat(Int(offsetY / itemSize.height)) * itemSize.height
        }
        
        // 返回调整后的偏移量
        return CGPoint(x: proposedContentOffset.x, y: targetY)
    }
    
    /// 启用实时布局更新
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
