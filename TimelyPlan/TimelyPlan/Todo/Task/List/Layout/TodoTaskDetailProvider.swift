//
//  TodoTaskDetailProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/27.
//

import Foundation

struct TodoTaskDetailOption: OptionSet {
    
    let rawValue: Int
    
    /// 我的一天
    static let myDay = TodoTaskDetailOption(rawValue: 1 << 0)

    /// 计划
    static let schedule = TodoTaskDetailOption(rawValue: 1 << 1)
    
    /// 步骤
    static let step = TodoTaskDetailOption(rawValue: 1 << 2)

    /// 进度
    static let progress = TodoTaskDetailOption(rawValue: 1 << 3)

    /// 标签
    static let tag = TodoTaskDetailOption(rawValue: 1 << 4)
    
    /// 备注
    static let note = TodoTaskDetailOption(rawValue: 1 << 5)

    /// 列表
    static let list = TodoTaskDetailOption(rawValue: 1 << 6)

    /// 所有选项
    static let all: TodoTaskDetailOption = [myDay,
                                            .schedule,
                                            .step,
                                            .progress,
                                            .tag,
                                            .note,
                                            .list]
    
    /// 除去列表的所有选项
    static var allExceptList: TodoTaskDetailOption {
        return all.subtracting(.list)
    }
}

class TodoTaskDetailProvider {
    
    let task: TodoTask
    
    var option: TodoTaskDetailOption = .allExceptList
    
    init(task: TodoTask, option: TodoTaskDetailOption = .allExceptList) {
        self.task = task
        self.option = option
    }

    /// 更新详情信息
    func attributedInfo() -> ASAttributedString? {
        var infos = [ASAttributedString]()
        if option.contains(.list) {
            if let list = task.list {
                infos.append(list.title.attributedString)
            } else {
                infos.append(resGetString("Inbox").attributedString)
            }
        }
        
        if option.contains(.schedule), let info = task.schedule?.attributedInfo() {
            infos.append(info)
        }
        
        if option.contains(.myDay), let info = task.attributedMyDayInfo() {
            infos.append(info)
        }
        
        if option.contains(.step), let info = task.attributedStepInfo {
            infos.append(info)
        }
        
        if option.contains(.progress), let info = task.attributedProgressInfo {
            infos.append(info)
        }
        
        if option.contains(.note), let info = task.attributedNoteInfo() {
            infos.append(info)
        }
        
        if option.contains(.tag), let info = task.attributedTagInfo {
            infos.append(info)
        }
        
        if infos.count > 0 {
            return infos.joined(separator: " • ")
        }
        
        return nil
    }
    
}
