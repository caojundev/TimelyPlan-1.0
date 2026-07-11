//
//  TPCalendarScrollableWeekView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/28.
//

import Foundation
import UIKit

class TPCalendarScrollableWeekView: TPCollectionWrapperView,
                                    TPCollectionViewAdapterDataSource,
                                    TPCollectionViewAdapterDelegate {
    
    /// 月份视图代理对象
    weak var delegate: TPCalendarSingleWeekViewDelegate?
    
    weak var eventsProvider: CalendarRangeEventsProvider?
    
    /// 符号样式
    var symbolStyle: WeekdaySymbolStyle = .short
    
    /// 显示农历
    var showLunar: Bool = true
    
    /// 显示中国节假日
    var showChineseHolidays: Bool = true
    
    /// 日历视图切换到新月份回调
    var didChangeVisibleDateComponents: ((_ currentDateComponents: DateComponents,
                                          _ previousDateComponents: DateComponents) -> Void)?
    
    /// 日期选择管理器
    var selection: TPCalendarDateSelection? = TPCalendarSingleDateSelection()
    
    /// 周开始日
    var firstWeekday: Weekday = .firstWeekday {
        didSet {
            guard firstWeekday != oldValue else {
                return
            }
        
            var date: Date?
            if let selection = selection as? TPCalendarSingleDateSelection,
               let selectedComponents = selection.selectedDate {
               date = Date.dateFromComponents(selectedComponents)
            }
            
            let currentDate = date ?? .now
            visibleDateComponents = currentDate.firstDayOfWeek(firstWeekday: firstWeekday).yearMonthDayComponents
        }
    }
    
    /// 当前月份日期组件
    private(set) lazy var visibleDateComponents: DateComponents = {
        return Date.now.firstDayOfWeek(firstWeekday: firstWeekday).yearMonthDayComponents
    }()
    
    /// 当前月左右月份数目
    private let kNearWeeksCount = 5

    override func setupSubviews() {
        super.setupSubviews()
        scrollDirection = .horizontal
        adapter.cellStyle.backgroundColor = .clear
        adapter.cellStyle.selectedBackgroundColor = .clear
        adapter.dataSource = self
        adapter.delegate = self
        reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateContentOffset(animated: false)

        /// 内容偏移可能会被 collectionView 布局覆盖，在下一个 Runloop 再更新一次
        DispatchQueue.main.async {
            self.updateContentOffset(animated: false)
        }
    }
    
    override func setupCollectionView() {
        super.setupCollectionView()
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.isPagingEnabled = true
    }
    
    func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        return [String(describing: type(of: self)) as NSString]
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        var dateComponentsArray = [visibleDateComponents]
        for i in 1...kNearWeeksCount {
            let leftDateComponents = visibleDateComponents.yearMonthDayCompontentsByAddingWeeks(-i)!
            dateComponentsArray.insert(leftDateComponents, at: 0)
            let rightDateComponents = visibleDateComponents.yearMonthDayCompontentsByAddingWeeks(i)!
            dateComponentsArray.append(rightDateComponents)
        }

        return dateComponentsArray as [NSDateComponents]
    }

    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return TPCalendarSingleWeekCell.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? TPCalendarSingleWeekCell else {
            return
        }
        
        let dateComponents = adapter.item(at: indexPath) as! DateComponents
        let symbolsView = cell.symbolsView
        symbolsView.style = symbolStyle
        symbolsView.setFirstWeekday(firstWeekday)
        updateWeekView(cell.weekView, with: dateComponents)
    }
    
    func updateWeekView(_ weekView: TPCalendarSingleWeekView, with dateComponents: DateComponents) {
        weekView.delegate = delegate
        weekView.selection = selection
        weekView.showLunar = showLunar
        weekView.showChineseHolidays = showChineseHolidays
        weekView.configure(firstWeekday: firstWeekday,
                           visibleDateComponents: dateComponents,
                           eventsProvider: eventsProvider)
    }

    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return adapter.collectionViewSize()
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.size.width
        var index = Int(scrollView.contentOffset.x / width)
        index = min(2 * kNearWeeksCount, max(0, index))
        let indexPath = IndexPath(item: index, section: 0)

        let toDateComponents = adapter.item(at: indexPath) as! DateComponents
        if visibleDateComponents == toDateComponents {
            return
        }

        let fromDateComponents = visibleDateComponents
        visibleDateComponents = toDateComponents

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        adapter.performUpdate(updateVisibleItems: false)
        CATransaction.commit()
        
        updateContentOffset(animated: false)
        
        /// 日期变化回调
        didChangeVisibleDateComponents?(toDateComponents, fromDateComponents)
    }
    
    override func reloadData() {
        super.reloadData()
        updateContentOffset(animated: false)
    }
    
    override func reloadData(animateStyle: SlideStyle) {
        super.reloadData(animateStyle: animateStyle)
        updateContentOffset(animated: false)
    }
    
    /// 当前月份日期组件
    func setVisibleDateComponents(_ dateComponents: DateComponents, animated: Bool = false) {
        /// 判断是否在同一周
        guard let date = Date.dateFromComponents(dateComponents) else {
            return
        }
        
        let dateComponents = date.firstDayOfWeek(firstWeekday: firstWeekday).yearMonthDayComponents
        guard animated else {
            visibleDateComponents = dateComponents
            reloadData()
            return
        }
        
        let animateStyle = SlideStyle.horizontalStyle(fromValue: visibleDateComponents, toValue: dateComponents)
        visibleDateComponents = dateComponents
        reloadData(animateStyle: animateStyle)
    }
    
    // MARK: - Private Metehods
    /// 更新内容偏移
    func updateContentOffset(animated: Bool) {
        collectionView.layoutIfNeeded()
        var index = kNearWeeksCount
        if let indexPath = adapter.indexPath(of: visibleDateComponents as NSDateComponents) {
            index = indexPath.item
        }
 
        /// 设置新偏移
        var offset = CGPoint.zero
        offset.x = bounds.width * CGFloat(index)
        collectionView.contentOffset = offset
    }
}
