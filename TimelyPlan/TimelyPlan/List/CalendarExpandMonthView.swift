//
//  CalendarExpandMonthView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/7.
//

import Foundation
import UIKit

class CalendarExpandMonthView: TPCalendarScrollableMonthView {
    
    override func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return CalendarExpandMonthCell.self
    }

    override func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? CalendarExpandMonthCell else {
            return
        }
        
        let dateComponents = adapter.item(at: indexPath) as! DateComponents
        let monthView = cell.monthView
        monthView.delegate = delegate
        monthView.visibleDateComponents = dateComponents
        monthView.selection = selection
        monthView.reloadData()
    }
}

class CalendarExpandMonthCell: TPCollectionCell {
    
    private(set) lazy var  monthView: CalendarExpandSingleMonthView = {
        return CalendarExpandSingleMonthView(frame: bounds)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(monthView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        monthView.frame = bounds
    }
}

class CalendarExpandSingleMonthView: UIView,
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
    }

    func reloadData() {
        adapter.reloadData()
    }

    // MARK: - Data Source
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        
        /// 获取当前月份的日期
        let monthDate = Date.dateFromComponents(visibleDateComponents)!
        let monthDates = monthDate.calendarGridMonthDates(firstWeekday: firstWeekday)
        return monthDates.map {$0.yearMonthDayComponents} as [NSDateComponents]
    }
    
    // MARK: - Delegate
    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return TPCalendarDayCell.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? TPCalendarDayCell else {
            return
        }
        
        let components = adapter.item(at: indexPath) as! DateComponents
        cell.isDimmed = !visibleDateComponents.isInSameMonth(as: components)
        cell.dayDateComponents = components
        cell.isChecked = shouldShowCheckmarkForItem(at: indexPath)
        cell.reloadData()
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = floor(bounds.width / CGFloat(DAYS_PER_WEEK))
        let itemHeight = 60.0
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let components = adapter.item(at: indexPath) as! DateComponents
        let selectionsHighlight = selection?.shouldHighlightDate(components) ?? true
        return selectionsHighlight
    }

    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        let components = adapter.item(at: indexPath) as! DateComponents
        selection?.selectDate(components)
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
        adapter.reloadCell(forItems: dates as [NSDateComponents])
    }

}

