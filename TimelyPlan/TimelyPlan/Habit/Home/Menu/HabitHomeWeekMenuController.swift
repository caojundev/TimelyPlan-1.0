//
//  HabitHomeWeekMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/5.
//

import Foundation

class HabitHomeWeekMenuController: TPBaseMenuController<HabitTaskMenuActionType> {
    
    let task: HabitTask
    
    init(task: HabitTask) {
        self.task = task
        super.init()
    }
    
    override func orderedMenuActionTypeLists() -> [Array<HabitTaskMenuActionType>] {
        var lists: [Array<HabitTaskMenuActionType>]
        lists = [[.addToMyDay,
                  .removeFromMyDay],
                 [.focus],
                 [.edit,
                  .archive],
                 [.delete]]
        return lists
    }
 
    override func menuActionTypes() -> [HabitTaskMenuActionType] {
        var types: [HabitTaskMenuActionType] = [.focus, .edit, .archive, .delete]
        if task.isAddedToMyDay {
            types.append(.removeFromMyDay)
        } else {
            types.append(.addToMyDay)
        }
        
        return types
    }
}
