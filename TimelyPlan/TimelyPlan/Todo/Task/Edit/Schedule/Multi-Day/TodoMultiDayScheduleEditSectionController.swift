//
//  TodoMultiDayScheduleEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/21.
//

import Foundation

class TodoMultiDayScheduleEditSectionController: TPTableItemSectionController,
                                                          TPCalendarSingleDateSelectionDelegate,
                                                          TPCalendarMonthViewDelegate {

    /// 日期信息改变回调
    var didChangeDateInfo: ((TaskDateInfo) -> Void)?
    
    /// 日期信息
    var dateInfo: TaskDateInfo = TaskDateInfo(style: .multiDay) {
        didSet {
            updateCalendarSelectDate()
        }
    }
    
    /// 编辑类型
    var editType: DateRangeEditType = .end {
        didSet {
            updateCalendarSelectDate()
        }
    }
    
    /// 当前编辑类型对应的日期
    private var currentDate: Date {
        get {
            return editType == .start ? dateInfo.startDate : dateInfo.endDate
        }
        
        set {
            let calculator = TodoMultiDateInfoCalculator(dateInfo: self.dateInfo)
            calculator.setDate(newValue, editType: editType)
            self.dateInfo = calculator.dateInfo
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
        cellItem.monthViewDelegate = self
        cellItem.updater = { [weak self] in
            self?.updateCalendarCellItem()
        }
        
        cellItem.height = 420.0
        return cellItem
    }()
    
    /// 时间单元格条目
    private lazy var timeCellItem: TodoTaskEditTableCellItem = { [weak self] in
        let cellItem = TodoTaskEditTableCellItem()
        cellItem.imageName = "schedule_time_24"
        cellItem.updater = {
            self?.updateTimeCellItem()
        }
        
        cellItem.didSelectHandler = {
            self?.editTime()
        }
        
        cellItem.didClickRightButton = { _ in
            self?.clearSpecificTime()
        }
        
        return cellItem
    }()
    
    override init() {
        super.init()
        self.headerItem.height = 0.0
        self.footerItem.height = 0.0
        self.cellItems = [calendarCellItem, timeCellItem]
    }

    /// 日期范围改版
    private func dateInfoChanged() {
        didChangeDateInfo?(dateInfo)
        reloadTime()
    }

    // MARK: - 更新单元格条目
    /// 更新日历单元格条目
    private func updateCalendarCellItem() {
        calendarCellItem.visibleDateComponents = currentDate.yearMonthDayComponents
    }
    
    /// 更新时间单元格条目
    private func updateTimeCellItem() {
        if dateInfo.isAllDay {
            timeCellItem.title = resGetString("All Day")
            timeCellItem.isActive = false
        } else {
            let format: String
            if editType == .start {
                format = resGetString("Start %@")
            } else {
                format = resGetString("Due %@")
            }
            
            timeCellItem.title = String(format: format, currentDate.timeString)
            timeCellItem.isActive = true
        }
    }
    
    // MARK: - Edit
    /// 编辑时间
    private func editTime() {
        let timePicker = TPTimePickerViewController()
        var editDate = dateInfo.startDate
        if dateInfo.isAllDay {
            editDate = .now
        }
        
        timePicker.date = editDate
        timePicker.didPickDate = { date in
            self.didPickTime(date)
        }
        
        timePicker.popoverShowAsNavigationRoot()
    }
    
    /// 选中时间
    private func didPickTime(_ date: Date) {
        let calculator = TodoMultiDateInfoCalculator(dateInfo: self.dateInfo)
        calculator.setSpecificTime(date: date, editType: editType)
        self.dateInfo = calculator.dateInfo
        dateInfoChanged()
    }

    /// 删除具体时间
    private func clearSpecificTime() {
        let calculator = TodoMultiDateInfoCalculator(dateInfo: self.dateInfo)
        calculator.clearSpecificTime()
        self.dateInfo = calculator.dateInfo
        dateInfoChanged()
    }
    
    // MARK: - 日期范围操作
    func selectEditType(_ editType: DateRangeEditType) {
        self.editType = editType
        reloadCalendar(animated: true)
        reloadTime()
        updateCalendarSelectDate()
    }
    
    /// 更新跨天高亮
    func updateSpaningIndicator() {
        let cell = adapter?.cellForItem(calendarCellItem) as? TPCalendarTableCell
        cell?.updateSpaningIndicator()
    }
    
    // MARK: - 更新日历
    func reloadCalendar(animated: Bool) {
        calendarCellItem.updater?()
        let cell = adapter?.cellForItem(calendarCellItem) as? TPCalendarTableCell
        cell?.reloadData(animated: true)
    }
    
    private func reloadTime() {
        adapter?.reloadCell(forItem: timeCellItem, with: .none)
    }
    
    /// 更新日期选中
    func updateCalendarSelectDate() {
        dateSelection.setSelectedDateComponents(currentDate.yearMonthDayComponents)
    }
    
    // MARK: - TPCalendarMonthViewDelegate
    func spanDateRangesForCalendarMonthView(_ view: TPCalendarMonthView) -> [DateRange]? {
        return [dateInfo.dateRange]
    }
    
    // MARK: - TPCalendarSingleDateSelectionDelegate
    func singleDateSelection(_ selection: TPCalendarSingleDateSelection, didSelect date: DateComponents) {
        guard var selectedDate = Date.dateFromComponents(date) else {
            return
        }
        
        selectedDate = selectedDate.dateByReplacingTime(with: currentDate)
        self.currentDate = selectedDate
        self.updateSpaningIndicator()
        self.dateInfoChanged()
    }
    
}
