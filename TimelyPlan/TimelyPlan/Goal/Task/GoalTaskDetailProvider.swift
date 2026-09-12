//
//  GoalTaskDetailProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/12.
//

import Foundation

/// 目标任务详情选项
struct GoalTaskDetailOption: OptionSet {
    
    let rawValue: Int
    
    /// 我的一天
    static let myDay = GoalTaskDetailOption(rawValue: 1 << 0)
    
    /// 计划（日期区间）
    static let schedule = GoalTaskDetailOption(rawValue: 1 << 1)
    
    /// 进度
    static let progress = GoalTaskDetailOption(rawValue: 1 << 2)
    
    /// 步骤
    static let step = GoalTaskDetailOption(rawValue: 1 << 3)
    
    /// 权重
    static let weight = GoalTaskDetailOption(rawValue: 1 << 4)
    
    /// 提醒
    static let reminder = GoalTaskDetailOption(rawValue: 1 << 5)
    
    /// 备注
    static let note = GoalTaskDetailOption(rawValue: 1 << 6)
    
    /// 所属目标计划
    static let goalPlan = GoalTaskDetailOption(rawValue: 1 << 7)
    
    /// 所有选项
    static let all: GoalTaskDetailOption = [myDay,
                                            .schedule,
                                            .progress,
                                            .step,
                                            .weight,
                                            .reminder,
                                            .note,
                                            .goalPlan]
    
    /// 除去我的一天的所有选项
    static var allExceptMyDay: GoalTaskDetailOption {
        return all.subtracting(.myDay)
    }
    
    /// 除去所属目标计划的所有选项
    static var allExceptGoalPlan: GoalTaskDetailOption {
        return all.subtracting(.goalPlan)
    }
}

class GoalTaskDetailProvider {
    
    /// 目标任务
    let task: GoalTask
    
    /// 详情显示选项
    var option: GoalTaskDetailOption
    
    init(task: GoalTask, option: GoalTaskDetailOption = .allExceptGoalPlan) {
        self.task = task
        self.option = option
    }
    
    /// 更新详情信息
    func attributedInfo() -> ASAttributedString? {
        var infos = [ASAttributedString]()
        
        if option.contains(.goalPlan) {
            infos.append(task.planFeature.attributedTitle)
        }
        
        if option.contains(.myDay), let info = task.attributedMyDayInfo {
            infos.append(info)
        }
        
        if option.contains(.schedule), let info = task.attributedDateInfo {
            infos.append(info)
        }
        
        if option.contains(.progress), let info = task.attributedProgressInfo {
            infos.append(info)
        }
        
        if option.contains(.step), let info = task.attributedStepInfo {
            infos.append(info)
        }
        
        if option.contains(.weight), let info = task.attributedWeightInfo {
            infos.append(info)
        }
        
        if option.contains(.reminder), let info = task.attributedAlarmInfo {
            infos.append(info)
        }
        
        if option.contains(.note), let info = task.attributedNoteInfo {
            infos.append(info)
        }
        
        if infos.count > 0 {
            return infos.joined(separator: " • ")
        }
        
        return nil
    }
}
