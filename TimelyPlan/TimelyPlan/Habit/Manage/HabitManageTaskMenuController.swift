//
//  HabitManageTaskMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/6.
//

import Foundation

class HabitManageTaskMenuController: TPBaseMenuController<HabitTaskMenuActionType> {
    
    let task: HabitTask
    
    init(task: HabitTask) {
        self.task = task
        super.init()
    }
    
    override func orderedMenuActionTypeLists() -> [Array<HabitTaskMenuActionType>] {
        var lists: [Array<HabitTaskMenuActionType>]
        lists = [[.edit],
                 [.archive, .unarchive],
                 [.delete]]
        return lists
    }
 
    override func menuActionTypes() -> [HabitTaskMenuActionType] {
        if task.isArchived {
            return [.unarchive, .delete]
        } else {
            return [.edit, .archive, .delete]
        }
    }
}
