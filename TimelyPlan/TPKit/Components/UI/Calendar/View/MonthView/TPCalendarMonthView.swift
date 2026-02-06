//
//  TPCalendarMonthView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/12.
//

import Foundation
import UIKit

protocol TPCalendarMonthViewDelegate: AnyObject {
    
    /// 日期对应处单元格类
    func calendarMonthView(_ view: TPCalendarMonthView, cellClassForDateComponents components: DateComponents) -> AnyClass?
    
    /// 日期对应处单元格出队列通知，在该方法中配置单元格
    func calendarMonthView(_ view: TPCalendarMonthView, didDequeCell cell: UICollectionViewCell, forDateComponents components: DateComponents)
    
    /// 点击日期回调
    func calendarMonthView(_ view: TPCalendarMonthView, didSelectDate components: DateComponents)
    
    func calendarMonthView(_ view: TPCalendarMonthView, shouldHighlightDate components: DateComponents) -> Bool?
    
    /// 获取日历的跨度日期范围数组
    func spanDateRangesForCalendarMonthView(_ view: TPCalendarMonthView) -> [DateRange]?
}

extension TPCalendarMonthViewDelegate {
    func calendarMonthView(_ view: TPCalendarMonthView, cellClassForDateComponents components: DateComponents) -> AnyClass? {
        return nil
    }
    
    func calendarMonthView(_ view: TPCalendarMonthView, didDequeCell cell: UICollectionViewCell, forDateComponents components: DateComponents) {}
    
    func calendarMonthView(_ view: TPCalendarMonthView, didSelectDate components: DateComponents) {}
    
    func calendarMonthView(_ view: TPCalendarMonthView, shouldHighlightDate components: DateComponents) -> Bool? {
        return nil
    }
    
    func spanDateRangeForCalendarMonthView(_ view: TPCalendarMonthView) -> DateRange? {
        return nil
    }
}

class TPCalendarMonthView: UIView,
                           TPCalendarSpanningViewDelegate,
                           TPCollectionSingleSectionListDataSource,
                           TPCollectionViewAdapterDelegate,
                           TPCalendarDateSelectionUpdater {
    
    /// 代理对象
    weak var delegate: TPCalendarMonthViewDelegate?
    
    /// 当前月份日期
    var visibleDateComponents: DateComponents = Date().yearMonthComponents
    
    /// 周开始日
    var firstWeekday: Weekday = .sunday
    
    /// 选择管理器
    var selection: TPCalendarDateSelection? {
        didSet {
            selection?.addUpdater(self) /// 添加选择器更新监听
        }
    }

    /// 集合视图
    private var collectionView: UICollectionView!
    
    private let spanningView = TPCalendarSpanningView()

    /// 集合视图适配器
    private let adapter: TPCollectionViewAdapter = TPCollectionViewAdapter()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    func setupSubviews() {
        spanningView.delegate = self
        addSubview(spanningView)
        
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: collectionViewLayout)
        collectionView.isPrefetchingEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        addSubview(collectionView)
        
        /// 设置适配器
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.frame = bounds
        CATransaction.commit()
        spanningView.frame = bounds
    }

    func reloadData() {
        adapter.reloadData()
        updateSpaningIndicator()
    }
    
    func updateSpaningIndicator() {
        spanningView.reloadData()
    }
    
    // MARK: - Data Source
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        
        /// 获取当前月份的日期
        let monthDate = Date.dateFromComponents(visibleDateComponents)!
        let monthDates = monthDate.calendarMonthDays(firstWeekday: firstWeekday)
        return monthDates.map {$0.yearMonthDayComponents} as [NSDateComponents]
    }
    
    // MARK: - Delegate
    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        let dateComponents = adapter.item(at: indexPath) as! DateComponents
        if let cellClass = delegate?.calendarMonthView(self, cellClassForDateComponents: dateComponents) {
            return cellClass
        }
        
        return TPCalendarDayCell.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        cell.isHidden = !isCurrentMonthDate(at: indexPath)
        let components = adapter.item(at: indexPath) as! DateComponents
        if let cell = cell as? TPCalendarDayCell {
            cell.dayDateComponents = components
            cell.isChecked = shouldShowCheckmarkForItem(at: indexPath)
        }

        delegate?.calendarMonthView(self, didDequeCell: cell, forDateComponents: components)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsCount = adapter.itemsCount(at: indexPath.section)
        let weeksCount = Date.numberOfWeeksInMonth(of: itemsCount)
        let itemWidth = floor(bounds.width / CGFloat(DAYS_PER_WEEK))
        let itemHeight = floor(bounds.height / CGFloat(weeksCount))
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let components = adapter.item(at: indexPath) as! DateComponents
        let delegateHighlight = delegate?.calendarMonthView(self, shouldHighlightDate: components) ?? true
        let selectionsHighlight = selection?.shouldHighlightDate(components) ?? true
        let isCurrentMonth = visibleDateComponents.isInSameMonth(as: components)
        return delegateHighlight && selectionsHighlight && isCurrentMonth
    }

    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        
        let components = adapter.item(at: indexPath) as! DateComponents
        selection?.selectDate(components)
        delegate?.calendarMonthView(self, didSelectDate: components)
    }
    
    func shouldShowCheckmarkForItem(at indexPath: IndexPath) -> Bool {
        if let selection = selection {
            let date = adapter.item(at: indexPath) as! DateComponents
            return selection.isSelectedDate(date)
        }
        
        return false
    }
    
    // MARK: - TPCalendarDateSelectionUpdater
    func updateCalendar(forDates dates: [DateComponents]) {
        /// 过滤出在当前月份中的日期
        var updateDates = [DateComponents]()
        for date in dates {
            if date.isInSameMonth(as: visibleDateComponents) {
                updateDates.append(date)
            }
        }
        
        adapter.reloadCell(forItems: updateDates as [NSDateComponents])
        
        /// 更新跨天视图
        spanningView.reloadData()
    }
    
    // MARK: - TPCalendarSpanningViewDelegate
    func monthDateComponentsForCalendarSpanningView(_ view: TPCalendarSpanningView) -> DateComponents? {
        return visibleDateComponents
    }
    
    func displayDaysForCalendarSpanningView(_ view: TPCalendarSpanningView) -> [DateComponents]? {
        guard let sectionObject = adapter.objects.first else {
            return nil
        }
        
        return adapter.items(for: sectionObject) as? [DateComponents]
    }
    
    func spanDateRangesForCalendarSpanningView(_ view: TPCalendarSpanningView) -> [DateRange]? {
        let dateRanges = delegate?.spanDateRangesForCalendarMonthView(self)
        return dateRanges
    }
    
    // MARK: - Helpers
    /// 判断索引处的日期是否是当前月的日期
    private func isCurrentMonthDate(at indexPath: IndexPath) -> Bool {
        let dateComponents = adapter.item(at: indexPath) as! DateComponents
        return visibleDateComponents.isInSameMonth(as: dateComponents)
    }
    
}
