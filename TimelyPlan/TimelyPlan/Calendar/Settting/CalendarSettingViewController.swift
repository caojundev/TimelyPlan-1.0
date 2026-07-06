//
//  CalendarSettingViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/8.
//

import Foundation
import UIKit

class CalendarSettingViewController: BaseSettingViewController {

    private let headerHeight = 50.0
    
    private let headerPadding = UIEdgeInsets(top: 15.0, left: 12.0, bottom: 0.0, right: 12.0)
    
    /// 周开始日
    lazy var firstWeekdayCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.autoResizable = false
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Week Start on")
        cellItem.updater = {
            let firstWeekday = CalendarSetting.shared.firstWeekday
            self?.firstWeekdayCellItem.valueConfig = .valueText(firstWeekday.symbol)
        }
        
        cellItem.didSelectHandler = {
            self?.editFirstWeekday()
        }
        
        return cellItem
    }()
 
     lazy var generalSectionController: TPTableItemSectionController = {
         let sectionController = TPTableItemSectionController()
         sectionController.headerItem.height = 10.0
         sectionController.cellItems = [firstWeekdayCellItem]
         return sectionController
     }()
     
    lazy var habitSectionController: CalendarHabitSettingSectionController = {
        let sectionController = CalendarHabitSettingSectionController()
        sectionController.showInCalendarCellItem.title = resGetString("Show Habit")
        sectionController.headerItem.height = normalHeaderHeight
        return sectionController
    }()
    
    // MARK: - 新事项
    lazy var defaultEventDurationCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.autoResizable = false
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Default Duration")
        cellItem.updater = {
            let duration = CalendarSetting.shared.defaultEventDuration
            let valueText = (duration * SECONDS_PER_MINUTE).localizedTitle
            self?.defaultEventDurationCellItem.valueConfig = .valueText(valueText)
        }
        
        cellItem.didSelectHandler = {
            self?.editDefaultEventDuration()
        }
        
        return cellItem
    }()
 
     lazy var newEventsSectionController: TPTableItemSectionController = {
         let sectionController = TPTableItemSectionController()
         sectionController.headerItem.height = headerHeight
         sectionController.headerItem.padding = headerPadding
         sectionController.headerItem.title = resGetString("New Events")
         sectionController.cellItems = [defaultEventDurationCellItem]
         return sectionController
     }()
    
    // MARK: - 视图选项
    /// 显示周数
    lazy var showWeekNumberCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Show Week Number")
        cellItem.updater = {
            self?.showWeekNumberCellItem.isOn = CalendarSetting.shared.showWeekNumber
        }

        cellItem.valueChanged = { isOn in
            CalendarSetting.shared.showWeekNumber = isOn
        }
        
        return cellItem
    }()
    
    /// 显示农历
    lazy var showLunarCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Show Lunar Calendar")
        cellItem.updater = {
            self?.showLunarCellItem.isOn = CalendarSetting.shared.showLunar
        }

        cellItem.valueChanged = { isOn in
            CalendarSetting.shared.showLunar = isOn
        }
        
        return cellItem
    }()
    
    /// 显示中国节假日
    lazy var showChineseHolidaysCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Show Chinese Public Holidays")
        cellItem.updater = {
            self?.showChineseHolidaysCellItem.isOn = CalendarSetting.shared.showChineseHolidays
        }

        cellItem.valueChanged = { isOn in
            CalendarSetting.shared.showChineseHolidays = isOn
        }
        
        return cellItem
    }()
    
    lazy var viewOptionsSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = headerHeight
        sectionController.headerItem.padding = headerPadding
        sectionController.headerItem.title = resGetString("View Options")
        sectionController.cellItems = [showWeekNumberCellItem,
                                       showLunarCellItem,
                                       showChineseHolidaysCellItem]
        return sectionController
    }()
    
    /// 显示已完成任务
    lazy var showCompletedTaskCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Show Completed Task")
        cellItem.updater = {
            self?.showCompletedTaskCellItem.isOn = CalendarSetting.shared.showCompletedTask
        }

        cellItem.valueChanged = { isOn in
            CalendarSetting.shared.showCompletedTask = isOn
        }
        
        return cellItem
    }()
    
    lazy var taskOptionsSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 20.0
        sectionController.cellItems = [showCompletedTaskCellItem]
        return sectionController
    }()
    
    
    
    // MARK: - 周视图
    lazy var daysInWeekViewCellItem: TPDefaultInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPDefaultInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Days in Week View")
        cellItem.updater = {
            let days = CalendarSetting.shared.getDaysInWeek()
            self?.daysInWeekViewCellItem.valueConfig = .valueText("\(days)")
        }
        
        cellItem.didSelectHandler = {
            self?.editDaysInWeek()
        }
        
        return cellItem
    }()
    
    lazy var weekViewSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = headerHeight
        sectionController.headerItem.padding = headerPadding
        sectionController.headerItem.title = resGetString("Week View")
        sectionController.cellItems = [daysInWeekViewCellItem]
        return sectionController
    }()
    
    // MARK: - 月视图
    lazy var weeksInMonthViewCellItem: TPDefaultInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPDefaultInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Weeks in Month View")
        cellItem.updater = {
            let weeks = CalendarSetting.shared.getWeeksInMonth()
            self?.weeksInMonthViewCellItem.valueConfig = .valueText("\(weeks)")
        }
        
        cellItem.didSelectHandler = {
            self?.editWeeksInMonth()
        }
        
        return cellItem
    }()
    
    lazy var monthViewSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = headerHeight
        sectionController.headerItem.padding = headerPadding
        sectionController.headerItem.title = resGetString("Month View")
        sectionController.cellItems = [weeksInMonthViewCellItem]
        return sectionController
    }()
    
    // MARK: - 季度视图
    lazy var weeksInQuarterViewCellItem: TPDefaultInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPDefaultInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Weeks in Quarter View")
        cellItem.updater = {
            let weeks = CalendarSetting.shared.getWeeksInQuarter()
            self?.weeksInQuarterViewCellItem.valueConfig = .valueText("\(weeks)")
        }
        
        cellItem.didSelectHandler = {
            self?.editWeeksInQuarter()
        }
        
        return cellItem
    }()
    
    lazy var quarterViewSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = headerHeight
        sectionController.headerItem.padding = headerPadding
        sectionController.headerItem.title = resGetString("Quarter View")
        sectionController.cellItems = [weeksInQuarterViewCellItem]
        return sectionController
    }()
    
    // MARK: - 提醒
    lazy var timedEventAlertCellItem: TPDefaultInfoTableCellItem = { [weak self] in
        let cellItem = TPDefaultInfoTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.autoResizable = true
        cellItem.minimumHeight = defaultCellHeight
        cellItem.title = resGetString("Timed Event Alert")
        cellItem.subtitleConfig.font = .boldSystemFont(ofSize: 11.0)
        cellItem.subtitleConfig.numberOfLines = 2
        cellItem.updater = {
            self?.updateTimedEventAlertCellItem()
        }
        
        cellItem.didSelectHandler = {
            self?.editTimedEventAlert()
        }
        
        return cellItem
    }()
    
    lazy var allDayEventAlertCellItem: TPDefaultInfoTableCellItem = { [weak self] in
        let cellItem = TPDefaultInfoTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.autoResizable = true
        cellItem.minimumHeight = defaultCellHeight
        cellItem.title = resGetString("All-Day Event Alert")
        cellItem.subtitleConfig.font = .boldSystemFont(ofSize: 11.0)
        cellItem.subtitleConfig.numberOfLines = 2
        cellItem.updater = {
            self?.updateAllDayEventAlertCellItem()
        }
        
        cellItem.didSelectHandler = {
            self?.editAllDayEventAlert()
        }
        
        return cellItem
    }()

    lazy var alertSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = headerHeight
        sectionController.headerItem.padding = headerPadding
        sectionController.headerItem.title = resGetString("Default Alert")
        sectionController.cellItems = [timedEventAlertCellItem,
                                       allDayEventAlertCellItem]
        return sectionController
    }()
    
     override func viewDidLoad() {
         super.viewDidLoad()
         self.title = resGetString("Calendar Settings")
         self.sectionControllers = [generalSectionController,
                                    habitSectionController,
                                    newEventsSectionController,
                                    alertSectionController,
                                    viewOptionsSectionController,
                                    taskOptionsSectionController,
                                    weekViewSectionController,
                                    monthViewSectionController,
                                    quarterViewSectionController]
         self.reloadData()
     }
    
    // MARK: - Update CellItem
    private func updateTimedEventAlertCellItem() {
        guard let reminder = CalendarSetting.shared.timedEventReminder else {
            timedEventAlertCellItem.subtitle = resGetString("None")
            return
        }
        
        let info = reminder.info(startDate: nil, endDate: nil)
        timedEventAlertCellItem.subtitle = info
    }
    
    private func updateAllDayEventAlertCellItem() {
        guard let reminder = CalendarSetting.shared.allDayEventReminder else {
            allDayEventAlertCellItem.subtitle = resGetString("None")
            return
        }
        
        let info = reminder.info(startDate: nil, endDate: nil)
        allDayEventAlertCellItem.subtitle = info
    }
    
    
    // MARK: - Edit
    private func editFirstWeekday() {
        guard let cell = adapter.cellForItem(firstWeekdayCellItem) else {
            return
        }
        
        let firstWeekday = CalendarSetting.shared.firstWeekday
        WeekdayPickerController.show(currentWeekday: firstWeekday,
                                     allowWeekdays: [.sunday, .monday],
                                     from: cell.contentView,
                                     popoverPosition: .bottomLeft,
                                     permittedPositions: [.bottomLeft, .topLeft],
                                     isSourceViewCovered: false,
                                     animated: true) { weekday in
            if firstWeekday != weekday {
                CalendarSetting.shared.firstWeekday = weekday
                self.adapter.reloadCell(forItem: self.firstWeekdayCellItem, with: .none)
            }
        }
    }
    
    private func editDaysInWeek() {
        let pickerVC = TPCountPickerViewController()
        pickerVC.minimumCount = CalendarSetting.minDaysInWeek
        pickerVC.maximumCount = CalendarSetting.maxDaysInWeek
        pickerVC.count = CalendarSetting.shared.getDaysInWeek()
        pickerVC.didPickCount = { count in
            CalendarSetting.shared.setDaysInWeek(count)
            self.adapter.reloadCell(forItem: self.daysInWeekViewCellItem,
                                    with: .none)
        }
        
        pickerVC.popoverShow()
    }
    
    private func editWeeksInMonth() {
        let pickerVC = TPCountPickerViewController()
        pickerVC.minimumCount = CalendarSetting.minWeeksInMonth
        pickerVC.maximumCount = CalendarSetting.maxWeeksInMonth
        pickerVC.count = CalendarSetting.shared.getWeeksInMonth()
        pickerVC.didPickCount = { count in
            CalendarSetting.shared.setWeeksInMonth(count)
            self.adapter.reloadCell(forItem: self.weeksInMonthViewCellItem,
                                    with: .none)
        }
        
        pickerVC.popoverShow()
    }
    
    private func editWeeksInQuarter() {
        let pickerVC = TPCountPickerViewController()
        pickerVC.minimumCount = CalendarSetting.minWeeksInQuarter
        pickerVC.maximumCount = CalendarSetting.maxWeeksInQuarter
        pickerVC.count = CalendarSetting.shared.getWeeksInQuarter()
        pickerVC.didPickCount = { count in
            CalendarSetting.shared.setWeeksInQuarter(count)
            self.adapter.reloadCell(forItem: self.weeksInQuarterViewCellItem,
                                    with: .none)
        }
        
        pickerVC.popoverShow()
    }
    
    private func editDefaultEventDuration() {
        let vc = CalendarEventDurationEditViewController(style: .insetGrouped)
        vc.didEndEditing = {
            self.adapter.reloadCell(forItem: self.defaultEventDurationCellItem,
                                    with: .none)
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func editTimedEventAlert() {
        let reminder = CalendarSetting.shared.timedEventReminder
        let vc = CalendarEventAlertEditViewController(reminder: reminder, isAllDay: false)
        vc.didEndEditing = { reminder in
            CalendarSetting.shared.timedEventReminder = reminder
            self.adapter.reloadCell(forItem: self.timedEventAlertCellItem, with: .none)
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func editAllDayEventAlert() {
        let reminder = CalendarSetting.shared.allDayEventReminder
        let vc = CalendarEventAlertEditViewController(reminder: reminder, isAllDay: true)
        vc.didEndEditing = { reminder in
            CalendarSetting.shared.allDayEventReminder = reminder
            self.adapter.reloadCell(forItem: self.allDayEventAlertCellItem, with: .none)
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
 }
