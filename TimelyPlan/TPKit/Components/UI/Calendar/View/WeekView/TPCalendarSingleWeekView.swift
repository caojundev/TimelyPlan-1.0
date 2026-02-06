//
//  TPCalendarSingleWeekView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/3.
//

import Foundation

@objc protocol TPCalendarSingleWeekViewDelegate: AnyObject {
    
    /// 日期对应处单元格类
    @objc optional func calendarSingleWeekView(_ view: TPCalendarSingleWeekView, cellClassForDateComponents components: DateComponents) -> AnyClass?
    
    /// 日期对应处单元格出队列通知，在该方法中配置单元格
    @objc optional func calendarSingleWeekView(_ view: TPCalendarSingleWeekView, didDequeCell cell: UICollectionViewCell, forDateComponents components: DateComponents)
    
    /// 点击日期回调
    @objc optional func calendarSingleWeekView(_ view: TPCalendarSingleWeekView, didSelectDate components: DateComponents)
    
    @objc optional func calendarSingleWeekView(_ view: TPCalendarSingleWeekView, shouldHighlightDate components: DateComponents) -> Bool
}

class TPCalendarSingleWeekView: TPCollectionWrapperView,
                                 TPCollectionSingleSectionListDataSource,
                                 TPCollectionViewAdapterDelegate,
                                 TPCalendarDateSelectionUpdater {

    /// 代理对象
    weak var delegate: TPCalendarSingleWeekViewDelegate?
    
    /// 当前周日期
    var visibleDateComponents: DateComponents = Date().yearMonthDayComponents
    
    /// 周开始日
    var firstWeekday: Weekday = .sunday

    /// 选择管理器
    var selection: TPCalendarDateSelection? {
        didSet {
            selection?.addUpdater(self) /// 添加选择器更新监听
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure { collectionView in
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.showsVerticalScrollIndicator = false
            collectionView.bounces = false
        }
        
        adapter.dataSource = self
        adapter.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Data Source
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        guard let date = Date.dateFromComponents(visibleDateComponents) else {
            return nil
        }
        
        let dates = date.thisWeekDays(firstWeekday: firstWeekday.rawValue)
        var componentsArray = [DateComponents]()
        for date in dates {
            componentsArray.append(date.yearMonthDayComponents)
        }
    
        return componentsArray as [NSDateComponents]
    }
    
    // MARK: - Delegate
    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        let dateComponents = adapter.item(at: indexPath) as! DateComponents
        if let cellClass = delegate?.calendarSingleWeekView?(self, cellClassForDateComponents: dateComponents) {
            return cellClass
        }
        
        return TPCalendarDayCell.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let components = adapter.item(at: indexPath) as! DateComponents
        if let cell = cell as? TPCalendarDayCell {
            cell.dayDateComponents = components
            cell.isChecked = shouldShowCheckmarkForItem(at: indexPath)
        }
        
        delegate?.calendarSingleWeekView?(self, didDequeCell: cell, forDateComponents: components)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewSize = adapter.collectionViewSize()
        let itemWidth = collectionViewSize.width / CGFloat(DAYS_PER_WEEK)
        let itemHeight = collectionViewSize.height
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        
        let components = adapter.item(at: indexPath) as! DateComponents
        selection?.selectDate(components)
        delegate?.calendarSingleWeekView?(self, didSelectDate: components)
    }
    
    func shouldShowCheckmarkForItem(at indexPath: IndexPath) -> Bool {
        if let selection = selection {
            let date = adapter.item(at: indexPath) as! DateComponents
            return selection.isSelectedDate(date)
        }
        
        return false
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let components = adapter.item(at: indexPath) as! DateComponents
        let shouldHighlight = delegate?.calendarSingleWeekView?(self, shouldHighlightDate: components) ?? true
        return shouldHighlight
    }
    
    // MARK: - TPCalendarDateSelectionUpdater
    func updateCalendar(forDates dates: [DateComponents]) {
        var updateDates = [DateComponents]()
        for date in dates {
            if adapter.indexPath(of: date as NSDateComponents) != nil {
                /// 更新日期在当前显示列表
                updateDates.append(date)
            }
        }
        
        adapter.reloadCell(forItems: updateDates as [NSDateComponents])
    }
}
