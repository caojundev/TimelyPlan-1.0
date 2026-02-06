//
//  TodoUpdaterOption.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/30.
//

import Foundation

struct TodoUpdaterOption: OptionSet {
    
    let rawValue: Int
    
    /// 目录
    static let folder = TodoUpdaterOption(rawValue: 1 << 0)

    /// 列表
    static let list = TodoUpdaterOption(rawValue: 2 << 0)

    /// 任务
    static let task = TodoUpdaterOption(rawValue: 3 << 1)
    
    /// 步骤
    static let step = TodoUpdaterOption(rawValue: 4 << 1)
    
    /// 标签
    static let tag = TodoUpdaterOption(rawValue: 5 << 1)
    
    /// 过滤器
    static let filter = TodoUpdaterOption(rawValue: 6 << 1)
    
    /// 所有
    static let all: TodoUpdaterOption = [.folder, .list, .task, .step, .tag, .filter]
}
