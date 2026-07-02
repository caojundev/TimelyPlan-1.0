//
//  HabitDayMenuPresenter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/16.
//

import Foundation

class HabitDayMenuPresenter {
    
    private static let processor = HabitTaskMenuActionProcessor()
    
    /// 显示信息菜单（包含了习惯信息）
    static func showMenu(for periodItem: HabitPeriodItem, on date: Date) {
        let habitTask = periodItem.habitTask
        let record = periodItem.record(on: date)
        let menuController = HabitDayInfoMenuController(periodItem: periodItem, date: date)
        menuController.didSelectMenuActionType = { type in
            processor.performMenuAction(type, for: habitTask, on: date, with: record)
        }
        
        menuController.didClickRecord = {
            processor.clickRecrod(for: habitTask, on: date)
        }
        
        menuController.showMenu()
    }
}
