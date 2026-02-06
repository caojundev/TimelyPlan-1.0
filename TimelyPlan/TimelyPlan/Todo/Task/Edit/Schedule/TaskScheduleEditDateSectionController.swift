//
//  TaskScheduleEditDateSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/2/1.
//

import Foundation

class TaskScheduleEditDateSectionController: TPTableItemSectionController,
                                             TPCalendarSingleDateSelectionDelegate,
                                             TPCalendarMonthViewDelegate {
    
    /// 日期信息改变回调
    var didChangeDateInfo: ((TaskDateInfo) -> Void)?
    
    /// 日期信息
    var dateInfo: TaskDateInfo = TaskDateInfo() {
        didSet {
            updateCalendarSelectDate()
            setVisibleMonth(containing: dateInfo.startDate)
        }
    }
    
    var repeatRule: RepeatRule?
    
    /// 日历单元格条目
    private lazy var calendarCellItem: TPCalendarTableCellItem = {
        let cellItem = TPCalendarTableCellItem()
        cellItem.selection = dateSelection
        cellItem.monthViewDelegate = self
        return cellItem
    }()

    /// 日历日期选择器
    private lazy var dateSelection: TPCalendarSingleDateSelection = {
        let selection = TPCalendarSingleDateSelection()
        selection.delegate = self
        return selection
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
    
    /// 持续时长
    lazy var durationCellItem: TodoTaskEditTableCellItem = { [weak self] in
        let cellItem = TodoTaskEditTableCellItem()
        cellItem.imageName = "schedule_duration_24"
        cellItem.updater = {
            self?.updateDurationCellItem()
        }
        
        cellItem.didSelectHandler = {
            self?.editDuration()
        }
        
        cellItem.didClickRightButton = { _ in
            self?.selectDuration(nil)
        }
        
        return cellItem
    }()

    override var cellItems: [TPBaseTableCellItem]? {
        get {
            var cellItems = [calendarCellItem, timeCellItem]
            if !dateInfo.isAllDay {
                cellItems.append(durationCellItem)
            }
            
            return cellItems
        }
        
        set {}
    }
    
    override init() {
        super.init()
        self.headerItem.height = 0.0
        self.setupSeparatorFooterItem()
        self.updateCalendarSelectDate()
    }
    
    
    /// 日期范围改版
    private func dateInfoChanged() {
        didChangeDateInfo?(dateInfo)
        adapter?.reloadCell(forItems: [timeCellItem, durationCellItem], with: .none)
        adapter?.performUpdate(with: .top, completion: nil)
    }

    // MARK: - Update
    /// 更新日期选中
    func updateCalendarSelectDate() {
        let dateComponents = dateInfo.startDate.yearMonthDayComponents
        dateSelection.setSelectedDateComponents(dateComponents)
    }
    
    /// 更新时间单元格条目
    private func updateTimeCellItem() {
        if dateInfo.isAllDay {
            timeCellItem.title = resGetString("All Day")
            timeCellItem.isActive = false
        } else {
            let format = resGetString("Start %@")
            timeCellItem.title = String(format: format, dateInfo.startDate.timeString)
            timeCellItem.isActive = true
        }
    }
    
    /// 更新时长单元格
    private func updateDurationCellItem() {
        if dateInfo.duration > 0 {
            let textColor = durationCellItem.activeColor
            durationCellItem.title = dateInfo.attributedDurationEndDateString(textColor: textColor,
                                                                                        badgeBaselineOffset: 8.0,
                                                                                        badgeFont: .boldSystemFont(ofSize: 8.0))
            durationCellItem.isActive = true
        } else {
            durationCellItem.title = resGetString("Duration")
            durationCellItem.isActive = false
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
        dateInfo.setSpecificTime(with: date)
        dateInfoChanged()
    }
    
    /// 删除具体时间
    private func clearSpecificTime() {
        dateInfo.clearSpecificTime()
        dateInfoChanged()
    }
    
    // MARK: - 持续时长
    private func editDuration() {
        let pickerVC = TPDurationPickerViewController()
        pickerVC.minimumDuration = SECONDS_PER_MINUTE
        pickerVC.duration = dateInfo.duration
        pickerVC.didPickDuration = { duration in
            self.selectDuration(duration)
        }
    
        pickerVC.popoverShowAsNavigationRoot()
    }
    
    private func selectDuration(_ duration: Duration?) {
        guard let duration = duration else {
            dateInfo.clearDuration()
            dateInfoChanged()
            return
        }

        if dateInfo.duration != duration {
            dateInfo.setDuration(duration)
            dateInfoChanged()
        }
    }

    // MARK: - TPCalendarSingleDateSelectionDelegate
    func singleDateSelection(_ selection: TPCalendarSingleDateSelection, didSelect date: DateComponents) {
        guard let selectedDate = Date.dateFromComponents(date) else {
            return
        }
        
        dateInfo.setStartDate(selectedDate)
        updateCalendarSpanningIndicator()
        dateInfoChanged()
    }
    
    // MARK: - TPCalendarMonthViewDelegate
    func spanDateRangesForCalendarMonthView(_ view: TPCalendarMonthView) -> [DateRange]? {
        guard let repeatRule = repeatRule, repeatRule.type != RepeatType.none else {
            return nil
        }

        let monthDate = Date.dateFromComponents(view.visibleDateComponents)!
        let scheduler = RepeatScheduler()
        guard let repeatDates = scheduler.repeatDates(inMonthOf: monthDate,
                                                      matching: repeatRule,
                                                      startDate: dateInfo.startDate) else {
            return nil
        }

        return repeatDates.map { repeatDate in
            return DateRange(startDate: repeatDate, endDate: repeatDate)
        }
    }
    
    
    // MARK: - Public Methods
    
    func setStartDateVisible() {
        setVisibleMonth(containing: dateInfo.startDate)
    }
    
    /// 将日期所在月份设为当前显示
    func setVisibleMonth(containing date: Date) {
        let visibleDateComponents = date.yearMonthComponents
        guard calendarCellItem.visibleDateComponents != visibleDateComponents else {
            return
        }
        
        calendarCellItem.visibleDateComponents = visibleDateComponents
        let cell = adapter?.cellForItem(calendarCellItem) as? TPCalendarTableCell
        cell?.reloadData(animated: true)
    }
    
    // MARK: - Update
    
    /// 更新日历跨天指示器
    func updateCalendarSpanningIndicator() {
        /// 更新月视图指示器
        if let monthViews = dateSelection.updaters as? [TPCalendarMonthView] {
            for monthView in monthViews {
                monthView.updateSpaningIndicator()
            }
        }
    }
}
