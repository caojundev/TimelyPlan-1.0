//
//  HabitDayMenuPresenter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/16.
//

import Foundation

class HabitDayMenuPresenter {
    
    private static let processor = HabitTaskMenuActionProcessor()
    
    private static func dayMenuController(
        for periodItem: HabitPeriodItem,
        on date: Date) -> HabitDayInfoMenuController {
        let habitTask = periodItem.habitTask
        let record = periodItem.record(on: date)
        let menuController = HabitDayInfoMenuController(periodItem: periodItem, date: date)
        menuController.didSelectMenuActionType = { type in
            processor.performMenuAction(type, for: habitTask, on: date, with: record)
        }
        
        menuController.didClickRecord = {
            processor.clickRecrod(for: habitTask, on: date)
        }
        
        return menuController
    }
    
    static func showPopoverMenu(for periodItem: HabitPeriodItem, on date: Date) {
        let menuController = dayMenuController(for: periodItem, on: date)
        menuController.showPopoverMenu()
    }
    
    static func showSheetMenu(for periodItem: HabitPeriodItem, on date: Date) {
        let menuController = dayMenuController(for: periodItem, on: date)
        menuController.showSheetMenu()
    }
}
