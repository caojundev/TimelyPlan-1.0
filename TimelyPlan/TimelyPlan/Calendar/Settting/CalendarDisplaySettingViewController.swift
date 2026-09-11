//
//  CalendarDisplaySettingViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/11.
//

import Foundation
import UIKit

/// 日历事项显示设置（合并习惯、目标、专注）
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Show in Calendar")
        self.sectionControllers = [habitSectionController,
                                   goalSectionController,
                                   focusSectionController]
        self.reloadData()
    }
}
