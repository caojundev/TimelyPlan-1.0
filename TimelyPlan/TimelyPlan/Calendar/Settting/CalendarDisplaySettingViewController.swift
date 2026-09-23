//
//  CalendarDisplaySettingViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/11.
//

import Foundation
import UIKit

/// 日历事项显示设置（合并习惯、目标、专注、倒数日）
class CalendarDisplaySettingViewController: BaseSettingViewController {
    
    /// 习惯
    lazy var habitSectionController: CalendarHabitSettingSectionController = {
        let sectionController = CalendarHabitSettingSectionController()
        sectionController.showInCalendarCellItem.title = resGetString("Show Habit")
        sectionController.headerItem.height = titleHeaderHeight
        sectionController.headerItem.padding = titleHeaderPadding
        sectionController.headerItem.title = resGetString("Habit")
        return sectionController
    }()
    
    /// 目标
    lazy var goalSectionController: CalendarGoalSettingSectionController = {
        let sectionController = CalendarGoalSettingSectionController()
        sectionController.showInCalendarCellItem.title = resGetString("Show Goal")
        sectionController.headerItem.height = titleHeaderHeight
        sectionController.headerItem.padding = titleHeaderPadding
        sectionController.headerItem.title = resGetString("Goal")
        return sectionController
    }()
    
    /// 专注
    lazy var focusSectionController: CalendarFocusSettingSectionController = {
        let sectionController = CalendarFocusSettingSectionController()
        sectionController.headerItem.height = titleHeaderHeight
        sectionController.headerItem.padding = titleHeaderPadding
        sectionController.headerItem.title = resGetString("Focus")
        return sectionController
    }()
    
    /// 倒数日
    lazy var showInCountdownCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Show Countdown")
        cellItem.updater = {
            self?.showInCountdownCellItem.isOn = CalendarSetting.shared.showInCountdown
        }
        
        cellItem.valueChanged = { isOn in
            CalendarSetting.shared.showInCountdown = isOn
        }
        
        return cellItem
    }()
    
    lazy var countdownSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = titleHeaderHeight
        sectionController.headerItem.padding = titleHeaderPadding
        sectionController.headerItem.title = resGetString("Countdown")
        sectionController.cellItems = [showInCountdownCellItem]
        return sectionController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Show in Calendar")
        self.sectionControllers = [habitSectionController,
                                   goalSectionController,
                                   focusSectionController,
                                   countdownSectionController]
        self.reloadData()
    }
}
