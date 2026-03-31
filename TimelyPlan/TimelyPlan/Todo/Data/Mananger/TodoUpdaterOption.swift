//
//  TodoUpdaterOption.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/30.
//

import Foundation

struct TodoUpdaterOption: OptionSet {
    
    let rawValue: Int
    
    /// 列表
    static let list = TodoUpdaterOption(rawValue: 1 << 0)

    /// 任务
    static let task = TodoUpdaterOption(rawValue: 2 << 1)
    
    /// 步骤
    static let step = TodoUpdaterOption(rawValue: 3 << 1)
    
    /// 标签
    static let tag = TodoUpdaterOption(rawValue: 4 << 1)
    
    /// 过滤器
    static let filter = TodoUpdaterOption(rawValue: 5 << 1)
    
    /// 所有
    static let all: TodoUpdaterOption = [.list, .task, .step, .tag, .filter]
}
