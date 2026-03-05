//
//  HabitMenuActionController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/17.
//

import Foundation

/*
class HabitMenuActionController: TPBaseMenuController<HabitMenuActionType> {

    /// 菜单处理器
//    var processor = HabitMenuActionProcessor()
    
    /// 菜单作用的任务
    let task: HabitTask
    
    /// 今日日期
    var date: Date

    init(task: HabitTask, onDate date: Date = Date()) {
        self.task = task
        self.date = date
        super.init()
        
        self.didSelectMenuActionType = { [weak self] actionType in
            guard let self = self else {
                return
            }
            
            self.processor.performMenuAction(actionType,
                                             forTask: self.task,
                                             onDate: self.date,
                                             fromSourceView: self.sourceView)
        }
    }
    
    override func orderedMenuActionTypeLists() -> [Array<HabitMenuActionType>] {
        var lists: [Array<HabitMenuActionType>]
        lists = [[.editLog,
                  .checkin,
                  .completeAll,
                  .addRecord,
                  .skipToday,
                  .cancelSkip,
                  .markAsFail,
                  .cancelFail,
                  .resetToday],
                 [.moveTop],
                 [.edit,
                  .move],
                 [.delete]]
        return lists
    }
 
    override func menuActionTypes() -> [HabitMenuActionType] {
        var types: [HabitMenuActionType] = [.edit,
                                            .move,
                                            .delete]
        let status = taskStatus()
        if status == .notStarted || status == .inProgress {
            if task.targetMode == .checkin {
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
        
        if status == .completed ||
            status == .failed(nil) ||
            status == .skipped(nil) {
            
            /// 添加日志
            types.append(.editLog)
        
            /// 取消跳过
            if status == .skipped(nil) {
                types.append(.cancelSkip)
            }
        }
        
        if status == .failed(nil) {
            types.append(.cancelFail)
        }
        
        if status != .notStarted {
            types.append(.resetToday)
        }
        
        return types
    }
    
    // MARK: - 子类重写
    /// 任务状态
    func taskStatus() -> HabitTaskStatus {
        return .notStarted
    }
}
*/
