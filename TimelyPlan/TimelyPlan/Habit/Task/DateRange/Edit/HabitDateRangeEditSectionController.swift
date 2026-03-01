//
//  HabitDateRangeEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/2/1.
//

import Foundation

class HabitDateRangeEditSectionController: TPTableItemSectionController,
                                           TPCalendarSingleDateSelectionDelegate {

    /// 编辑类型
    var editType: DateRangeEditType = .end {
        didSet {
            updateCalendarSelectDate()
        }
    }
    
    /// 任务日期改变
    var dateRangeChanged: ((DateRange) -> Void)?
    
    /// 日期范围
    var dateRange: DateRange = DateRange() {
        didSet {
            updateCalendarSelectDate()
        }
    }
    
    /// 当前编辑类型对应的日期
    var currentDate: Date? {
        get {
            return editType == .start ? dateRange.startDate : dateRange.endDate
        }
        
        set {
            dateRange.setHabitDate(newValue, for: editType)
        }
    }
    
    private lazy var dateSelection: TPCalendarSingleDateSelection = {
        let selection = TPCalendarSingleDateSelection()
        selection.delegate = self
        return selection
    }()
    
    /// 日历
    lazy var calendarCellItem: TPCalendarTableCellItem = {
        let cellItem = TPCalendarTableCellItem()
        cellItem.selection = dateSelection
        cellItem.updater = { [weak self] in
            self?.updateCalendarCellItem()
        }
        
        cellItem.height = 460.0
        return cellItem
    }()
    
    override init() {
        super.init()
        self.headerItem.height = 0.0
        self.footerItem.height = 0.0
        self.cellItems = [calendarCellItem]
    }

    // MARK: - 更新单元格条目
    /// 更新日历单元格条目
    func updateCalendarCellItem() {
        if let date = currentDate {
            calendarCellItem.visibleDateComponents = date.yearMonthDayComponents
        }
    }

    // MARK: - 日期范围操作
    func didSelectEditType(_ editType: DateRangeEditType) {
        self.editType = editType
        reloadCalendar(animated: true)
        updateCalendarSelectDate()
    }
    
    /// 删除日期
    func deleteDate(editType: DateRangeEditType) {
        dateRange.setHabitDate(nil, for: editType)
        dateRangeChanged?(dateRange)
        updateCalendarSelectDate()
        updateEditList()
    }

    
    // MARK: - 更新日历
    func reloadCalendar(animated: Bool) {
        calendarCellItem.updater?()
        let cell = adapter?.cellForItem(calendarCellItem) as? TPCalendarTableCell
        cell?.reloadData(animated: true)
    }
    
    /// 更新日期选中
    func updateCalendarSelectDate() {
        dateSelection.setSelectedDateComponents(currentDate?.yearMonthDayComponents)
    }
    
    // MARK: - TPCalendarSingleDateSelectionDelegate
    func singleDateSelection(_ selection: TPCalendarSingleDateSelection, didSelect date: DateComponents) {
        guard var selectedDate = Date.dateFromComponents(date) else {
            return
        }
        
        if let currentDate = currentDate {
            selectedDate = selectedDate.dateByReplacingTime(with: currentDate)
        }
        
        currentDate = selectedDate
        dateRangeChanged?(dateRange)
        updateEditList()
    }
    
    func updateEditList() {
        adapter?.performUpdate(with: .fade, completion: nil)
    }
}
