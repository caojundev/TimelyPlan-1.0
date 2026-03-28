//
//  HabitDayMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/16.
//

import Foundation

class HabitDayMenuController {
    
    private let processor = HabitTaskMenuActionProcessor()
    
    func showMenu(for periodItem: HabitPeriodItem, on date: Date) {
        let habitTask = periodItem.habitTask
        let status = periodItem.status(on: date)
        let record = periodItem.record(on: date)
        let menuController = HabitHomeWeekDayMenuController(task: habitTask, status: status, date: date)
        menuController.didSelectMenuActionType = {[weak self] type in
            self?.processor.performMenuAction(type, for: habitTask, on: date, with: record)
        }
        
        menuController.didClickRecord = { [weak self] in
            self?.processor.clickRecrod(for: habitTask, on: date)
        }
        
        menuController.showMenu()
    }
}
