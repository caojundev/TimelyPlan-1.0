//
//  MyDaySettingViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/17.
//

import Foundation
import UIKit

class MyDaySettingViewController: BaseSettingViewController {

    private let headerHeight = 50.0
    
    private let headerPadding = UIEdgeInsets(top: 15.0, left: 12.0, bottom: 0.0, right: 12.0)
    
    /// 周开始日
    lazy var firstWeekdayCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.autoResizable = false
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Week Start on")
        cellItem.updater = {
            let firstWeekday = MyDaySetting.shared.firstWeekday
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
    
    // MARK: - 视图选项
    /// 显示农历
    lazy var showLunarCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Show Lunar Calendar")
        cellItem.updater = {
            self?.showLunarCellItem.isOn = MyDaySetting.shared.showLunar
        }

        cellItem.valueChanged = { isOn in
            MyDaySetting.shared.showLunar = isOn
        }
        
        return cellItem
    }()
    
    /// 显示中国节假日
    lazy var showChineseHolidaysCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Show Chinese Public Holidays")
        cellItem.updater = {
            self?.showChineseHolidaysCellItem.isOn = MyDaySetting.shared.showChineseHolidays
        }

        cellItem.valueChanged = { isOn in
            MyDaySetting.shared.showChineseHolidays = isOn
        }
        
        return cellItem
    }()
    
    lazy var viewOptionsSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = headerHeight
        sectionController.headerItem.padding = headerPadding
        sectionController.headerItem.title = resGetString("View Options")
        sectionController.cellItems = [showLunarCellItem,
                                       showChineseHolidaysCellItem]
        return sectionController
    }()
    
    // MARK: - 事项显示
    
    /// 显示待办
    lazy var showTodoCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Show Todo")
        cellItem.updater = {
            self?.showTodoCellItem.isOn = MyDaySetting.shared.showTodo
        }

        cellItem.valueChanged = { isOn in
            MyDaySetting.shared.showTodo = isOn
        }

        return cellItem
    }()
    
    /// 显示习惯
    lazy var showHabitCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Show Habit")
        cellItem.updater = {
            self?.showHabitCellItem.isOn = MyDaySetting.shared.showHabit
        }

        cellItem.valueChanged = { isOn in
            MyDaySetting.shared.showHabit = isOn
        }

        return cellItem
    }()
    
    
    /// 显示专注
    lazy var showFocusCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Show Focus Timer")
        cellItem.updater = {
            self?.showFocusCellItem.isOn = MyDaySetting.shared.showFocus
        }

        cellItem.valueChanged = { isOn in
            MyDaySetting.shared.showFocus = isOn
        }

        return cellItem
    }()
    
    /// 显示日历事项
    lazy var showCalendarEventCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Show Calendar Event")
        cellItem.updater = {
            self?.showCalendarEventCellItem.isOn = MyDaySetting.shared.showCalendarEvent
        }

        cellItem.valueChanged = { isOn in
            MyDaySetting.shared.showCalendarEvent = isOn
        }

        return cellItem
    }()

    lazy var showSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = normalHeaderHeight
        sectionController.cellItems = [showCalendarEventCellItem,
                                       showTodoCellItem,
                                       showFocusCellItem,
                                       showHabitCellItem]
        return sectionController
    }()

    /// 返回
    lazy var dismissButtonItem: UIBarButtonItem = {
        let image = resGetImage("chevron_right_24")
        let item = UIBarButtonItem(image: image,
                                   style: .plain,
                                   target: self,
                                   action: #selector(clickDismiss))
        return item
    }()
    
     override func viewDidLoad() {
         super.viewDidLoad()
         self.title = resGetString("My Day Settings")
         self.navigationItem.leftBarButtonItem = dismissButtonItem
         self.sectionControllers = [generalSectionController,
                                    viewOptionsSectionController,
                                    showSectionController]
         self.reloadData()
     }
    
    // MARK: - Event Response
    @objc private func clickDismiss() {
        TPImpactFeedback.impactWithSoftStyle()
        dismiss(animated: true)
    }
    
    // MARK: - Edit
    private func editFirstWeekday() {
        guard let cell = adapter.cellForItem(firstWeekdayCellItem) else {
            return
        }
        
        let firstWeekday = MyDaySetting.shared.firstWeekday
        WeekdayPickerController.show(currentWeekday: firstWeekday,
                                     allowWeekdays: [.sunday, .monday],
                                     from: cell,
                                     popoverPosition: .bottomLeft,
                                     permittedPositions: [.bottomLeft, .topLeft],
                                     isSourceViewCovered: false,
                                     animated: true) { weekday in
            if firstWeekday != weekday {
                MyDaySetting.shared.firstWeekday = weekday
                self.adapter.reloadCell(forItem: self.firstWeekdayCellItem, with: .none)
            }
        }
    }

 }

