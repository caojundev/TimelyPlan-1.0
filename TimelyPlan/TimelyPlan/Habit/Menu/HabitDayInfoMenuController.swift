//
//  HabitDayInfoMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/2.
//

import Foundation

class HabitDayInfoMenuController: HabitHomeDayMenuController {
    
    /// 点击记录
    var didClickRecord: (() -> Void)?
    
    let periodItem: HabitPeriodItem
    
    init(periodItem: HabitPeriodItem, date: Date) {
        self.periodItem = periodItem
        let status = periodItem.status(on: date)
        super.init(task: periodItem.habitTask, status: status, date: date)
    }
    
    override func allowMenuActionTypes() -> [HabitTaskMenuActionType] {
        var allowTypes: [HabitTaskMenuActionType]
        allowTypes = [.completeAll,
                      .checkin,
                      .addRecord,
                      .skipToday,
                      .cancelSkip,
                      .markAsFail,
                      .cancelFail,
                      .resetToday,
                      .editLog]
        return allowTypes
    }
    
    func showMenu() {
        let menuItems = menuItems()
        guard menuItems.count > 0 else {
            return
        }
        
        let menuVC = HabitDayInfoMenuViewController(periodItem: periodItem,
                                                    date: date,
                                                    menuItems: menuItems)
        menuVC.didSelectMenuAction = { action in
            guard let type = HabitTaskMenuActionType(rawValue: action.identifier) else {
                return
            }

            self.didSelectMenuActionType?(type)
        }
        
        menuVC.didClickRecord = didClickRecord
        menuVC.popoverShow()
    }
}
