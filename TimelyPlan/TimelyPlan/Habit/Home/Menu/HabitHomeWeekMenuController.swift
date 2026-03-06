//
//  HabitHomeWeekMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/5.
//

import Foundation

class HabitHomeWeekMenuController: TPBaseMenuController<HabitTaskMenuActionType> {
    
    override func orderedMenuActionTypeLists() -> [Array<HabitTaskMenuActionType>] {
        var lists: [Array<HabitTaskMenuActionType>]
        lists = [[.edit,
                  .archive],
                 [.delete]]
        return lists
    }
 
    override func menuActionTypes() -> [HabitTaskMenuActionType] {
        return [.edit, .archive, .delete]
    }
}
