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
    
    /// 选择管理器
    var selection: TPCalendarDateSelection? {
        didSet {
            selection?.addUpdater(self) /// 添加选择器更新监听
        }
    }
    
    /// 显示农历
    var showLunar: Bool = true
    
    /// 显示中国节假日
    var showChineseHolidays: Bool = true
    
    /// 周开始日
    private(set) var firstWeekday: Weekday = .sunday

    /// 当前周日期
    private(set) var visibleDateComponents: DateComponents = Date().yearMonthDayComponents
    
    private var requestToken: Int = 0
    
    private var rangeEventsInfo: CalendarRangeEventsInfo?
    
    private var eventsProvider: CalendarRangeEventsProvider?
    
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
    
    /// 获取事项的日期范围
    func eventRange() -> DateInterval? {
        guard let date = Date.dateFromComponents(visibleDateComponents) else {
            return nil
        }
        
        let range = date.rangeOfThisWeek(firstWeekday: firstWeekday)
        guard let start = range.startDate, let end = range.endDate else {
            return nil
        }
        
        return DateInterval(start: start, end: end)
    }
    
    func configure(firstWeekday: Weekday,
                   visibleDateComponents: DateComponents,
                   eventsProvider: CalendarRangeEventsProvider? = nil) {
        self.firstWeekday = firstWeekday
        self.visibleDateComponents = visibleDateComponents
        self.eventsProvider = eventsProvider
        self.eventsProvider?.addEventChangeDelegate(self)
        
        rangeEventsInfo = nil
        cancelCurrentRequest()
        reloadData()
        reloadEventsInfo()
    }
    
    private func reloadEventsInfo() {
        // 异步获取事项数据
        guard let eventsProvider = eventsProvider, let range = eventRange() else {
            return
        }
        
        // 生成新的请求令牌
        requestToken += 1
        let token = requestToken
        eventsProvider.fetchRangeEventsInfo(in: range) { [weak self] eventsInfo in
            guard let self = self else { return }
            // 检查令牌是否匹配
            guard token == self.requestToken else { return }
            self.rangeEventsInfo = eventsInfo
            self.updateEventsInfo()
        }
    }
    
    private func updateEventsInfo() {
        guard let cells = adapter.visibleCells as? [TPCalendarDayCell] else {
            return
        }
        
        for cell in cells {
            guard !cell.isHidden, let dateComponents = cell.dayDateComponents else {
                continue
            }
            
            let colors = rangeEventsInfo?.eventColors(for: dateComponents)
            cell.configureEventColors(colors)
        }
    }
    
    private func cancelCurrentRequest() {
        requestToken += 1
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
            cell.showLunar = showLunar
            cell.showChineseHolidays = showChineseHolidays
            cell.dayDateComponents = components
            cell.isChecked = shouldShowCheckmarkForItem(at: indexPath)
            cell.reloadData()
            
            /// 配置事项颜色信息
            let colors = rangeEventsInfo?.eventColors(for: components)
            cell.configureEventColors(colors)
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

extension TPCalendarSingleWeekView: CalendarEventChangeDelegate {
    
    func calendarEventsDidChange(in ranges: [DateInterval]) {
        guard let eventRange = eventRange() else {
            return
        }
        
        let shouldUpdate = ranges.anySatisfy { $0.intersects(eventRange)}
        if shouldUpdate {
            reloadEventsInfo()
        }
    }
}
