//
//  TodoFilterSpecificDateRangeSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/2.
//

import Foundation

class TodoFilterSpecificDateRangeSectionController: TPTableItemSectionController,
                                                    TPCalendarMonthViewDelegate,
                                                    TPCalendarSingleDateSelectionDelegate  {
    
    /// 任务日期改变
    var didChangeDateRange: ((TodoSpecificDateRange) -> Void)?
    
    /// 编辑类型
    var editType: DateRangeEditType = .start {
        didSet {
            updateCalendarSelectDate()
        }
    }
    
    lazy var dateRangeCellItem: TodoFilterSpecificDateRangeSegmentedCellItem = { [weak self] in
        let cellItem = TodoFilterSpecificDateRangeSegmentedCellItem()
        cellItem.updater = { [weak self] in
            self?.updateDateRangeCellItem()
        }
        
        cellItem.didSelectEditType = { editType in
            self?.selectEditType(editType)
        }
        
        return cellItem
    }()
    
    /// 日历单元格
    private lazy var calendarCellItem: TPCalendarTableCellItem = {
        let cellItem = TPCalendarTableCellItem()
        cellItem.monthViewDelegate = self
        cellItem.selection = dateSelection
        cellItem.updater = { [weak self] in
            self?.updateCalendarCellItem()
        }

        cellItem.height = 400.0
        return cellItem
    }()
    
    /// 日期选择器
    private lazy var dateSelection: TPCalendarSingleDateSelection = {
        let selection = TPCalendarSingleDateSelection()
        selection.delegate = self
        return selection
    }()
    
    private(set) var dateRange: TodoSpecificDateRange
    
    init(dateRange: TodoSpecificDateRange? = nil) {
        self.dateRange = dateRange ?? TodoSpecificDateRange()
        super.init()
        self.headerItem.height = 10.0
        self.cellItems = [dateRangeCellItem, calendarCellItem]
        self.updateCalendarSelectDate()
    }

    // MARK: - 更新单元格条目
    func updateDateRangeCellItem() {
        let dateRange = DateRange(startDate: dateRange.fromDate, endDate: dateRange.toDate)
        dateRangeCellItem.dateRange = dateRange
        dateRangeCellItem.editType = editType
    }
    
    /// 更新日历单元格条目
    func updateCalendarCellItem() {
        if let currentDate = getCurrentDate() {
            calendarCellItem.visibleDateComponents = currentDate.yearMonthDayComponents
        }
    }
    
    // MARK: - 编辑操作
    func selectEditType(_ editType: DateRangeEditType) {
        self.editType = editType
        reloadCalendar(animated: true)
        updateCalendarSelectDate()
        reloadDateRange()
    }
    
    /// 选中时间
    func pickTime(_ date: Date) {
        setCurrentDate(date)
        didChangeDateRange?(dateRange)
        reloadDateRange()
    }
    
    
    // MARK: - Reload

    func reloadDateRange() {
        adapter?.reloadCell(forItem: dateRangeCellItem, with: .none)
    }
    
    func reloadCalendar(animated: Bool) {
        calendarCellItem.updater?()
        
        let cell = adapter?.cellForItem(calendarCellItem) as? TPCalendarTableCell
        cell?.reloadData(animated: true)
    }
    
    /// 更新日期选中
    private func updateCalendarSelectDate() {
        let currentDate = getCurrentDate()
        dateSelection.setSelectedDateComponents(currentDate?.yearMonthDayComponents)
    }
    
    // MARK: - TFCalendarSingleDateSelectionDelegate
    func singleDateSelection(_ selection: TPCalendarSingleDateSelection, didSelect date: DateComponents) {
        var selectedDate = Date.dateFromComponents(date)!
        if let currentDate = getCurrentDate() {
            selectedDate = selectedDate.dateByReplacingTime(with: currentDate)
        } else {
            /// 当前无
            if editType == .start {
                selectedDate = selectedDate.date(withHour: 9, minute: 0)!
            } else {
                selectedDate = selectedDate.date(withHour: 18, minute: 0)!
            }
        }
        
        setCurrentDate(selectedDate)
        didChangeDateRange?(dateRange)
        reloadDateRange()
    }
    
    // MARK: - TPCalendarMonthViewDelegate
    func spanDateRangesForCalendarMonthView(_ view: TPCalendarMonthView) -> [DateRange]? {
        let dateRange = DateRange(startDate: dateRange.fromDate, endDate: dateRange.toDate)
        return [dateRange]
    }
    
    // MARK: - Helpers
    /// 当前编辑类型对应的日期
    private func getCurrentDate() -> Date? {
        return dateRange.date(for: editType)
    }
    
    private func setCurrentDate(_ date: Date) {
        setDate(date, for: editType)
    }
    
    private func setDate(_ date: Date?, for editType: DateRangeEditType) {
        dateRange.setDate(date, for: editType)
    }
    
}
