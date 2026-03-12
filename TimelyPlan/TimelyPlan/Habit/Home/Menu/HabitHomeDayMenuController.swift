//
//  HabitHomeDayMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/6.
//

import Foundation

class HabitHomeDayMenuController: HabitTaskBaseMenuController {
    
    let task: HabitTask
    
    let status: HabitTaskStatus
    
    var date: Date
    
    init(task: HabitTask,
         status: HabitTaskStatus,
         date: Date) {
        self.task = task
        self.status = status
        self.date = date
        super.init()
    }
    
    override func allowMenuActionTypes() -> [HabitTaskMenuActionType] {
        let allowTypes: [HabitTaskMenuActionType] = [.edit,
                                                     .archive,
                                                     .delete]
        if date.isFutureDay {
            return allowTypes
        }

        return HabitTaskMenuActionType.allCases
    }
    
    override func taskGoalMode() -> HabitGoal.TargetMode {
        return task.goal.mode
    }
    
    override func taskStatus() -> HabitTaskStatus {
        return status
    }
}
