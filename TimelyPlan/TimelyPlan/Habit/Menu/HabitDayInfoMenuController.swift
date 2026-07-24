//
//  HabitDayInfoMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/2.
//

import Foundation

enum HabitDayMenuType {
    case all /// 包含所有操作
    case recordOnly /// 仅记录操作
}

class HabitDayInfoMenuController: HabitHomeDayMenuController {

    /// 点击记录
    var didClickRecord: (() -> Void)?
    
    private var menuType: HabitDayMenuType = .all
    
    let periodItem: HabitPeriodItem
    
    init(periodItem: HabitPeriodItem, date: Date) {
        self.periodItem = periodItem
        let status = periodItem.status(on: date)
        super.init(task: periodItem.habitTask, status: status, date: date)
    }
    
    override func allowMenuActionTypes() -> [HabitTaskMenuActionType] {
        if menuType == .all {
            return super.allowMenuActionTypes()
        }
        
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
    
    func showPopoverMenu(with menuType: HabitDayMenuType) {
        self.menuType = menuType
        if let menuVC = menuViewController() {
            menuVC.popoverShow()
        }
    }
    
    func showSheetMenu(with menuType: HabitDayMenuType) {
        self.menuType = menuType
        guard let menuVC = menuViewController() else {
            return
        }
        
        if let sheet = menuVC.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.detents = [.medium(), .large()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
        }
        
        menuVC.show()
    }
}
