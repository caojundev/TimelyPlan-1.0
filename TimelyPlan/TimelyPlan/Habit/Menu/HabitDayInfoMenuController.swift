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
    
    private func menuViewController() -> HabitDayInfoMenuViewController? {
        let menuItems = menuItems()
        guard menuItems.count > 0 else {
            return nil
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
        return menuVC
    }
    
    func showPopoverMenu() {
        if let menuVC = menuViewController() {
            menuVC.popoverShow()
        }
    }
    
    func showSheetMenu() {
        guard let menuVC = menuViewController() else {
            return
        }
        
        if let sheet = menuVC.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.detents = [.medium()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
        }
        
        menuVC.show()
    }
}
