//
//  HabitTaskBaseMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/17.
//

import Foundation

class HabitTaskBaseMenuController: TPBaseMenuController<HabitTaskMenuActionType> {

    override func orderedMenuActionTypeLists() -> [Array<HabitTaskMenuActionType>] {
        var lists: [Array<HabitTaskMenuActionType>]
        lists = [[.editLog,
                  .checkin,
                  .completeAll,
                  .addRecord,
                  .skipToday,
                  .cancelSkip,
                  .markAsFail,
                  .cancelFail,
                  .resetToday],
                 [.addToMyDay, .removeFromMyDay],
                 [.statistics],
                 [.focus],
                 [.edit, .archive],
                 [.delete]]
        return lists
    }
 
    override func menuActionTypes() -> [HabitTaskMenuActionType] {
        var types: [HabitTaskMenuActionType] = [.statistics, .edit, .archive, .delete]
        
        if isAddedToMyDay() {
            types.append(.removeFromMyDay)
        } else {
            types.append(.addToMyDay)
        }
        
        let status = taskStatus()
        if status == .notStarted || status == .inProgress {
            let mode = taskGoalMode()
            if mode == .checkin {
                types.append(.checkin)
            } else {
                /// 非打卡目标
                types.append(.completeAll)
                types.append(.addRecord)
            }

            /// 标记为失败
            types.append(.markAsFail)
            
            /// 跳过今天
            types.append(.skipToday)
        }
        
        if status == .completed || status.isFailed || status.isSkipped {
            /// 添加日志
            types.append(.editLog)
            
            /// 取消跳过
            if status.isSkipped {
                types.append(.cancelSkip)
            }
        }
        
        if status.isFailed {
            types.append(.cancelFail)
        }
        
        if status != .notStarted {
            types.append(.resetToday)
        }
        
        return types
    }
    
    // MARK: - 子类重写
    func isAddedToMyDay() -> Bool {
        return false
    }
    
    /// 当前任务状态
    func taskStatus() -> HabitTaskStatus {
        return .notStarted
    }
    
    /// 当前任务目标模式
    func taskGoalMode() -> HabitGoal.TargetMode {
        return .checkin
    }
}
