//
//  HabitHomeWeekDayMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/11.
//

import Foundation

class HabitHomeWeekDayMenuController: HabitHomeDayMenuController {
    
    /// 点击记录
    var didClickRecord: (() -> Void)?
    
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
        
        let menuVC = HabitDaySheetMenuViewController(task: self.task,
                                                     date: self.date,
                                                     status: self.status,
                                                     menuItems: menuItems)
        menuVC.didSelectMenuAction = { action in
            guard let type = HabitTaskMenuActionType(rawValue: action.identifier) else {
                return
            }

            self.didSelectMenuActionType?(type)
        }
        
        menuVC.didClickRecord = didClickRecord
        menuVC.slideShow(from: .bottom, animated: true, completion: nil)
    }
}
