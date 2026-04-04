//
//  TodoProgressEnum.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/12.
//

import Foundation

/// 记录输入类型
enum TodoRecordInputType: String {
    case positive
    case negative
    case update
    
    /// 类型图标
    var image: UIImage? {
        let imageName = "todo_task_record_\(self.rawValue)_24"
        return resGetImage(imageName)
    }
}

/// 计算方式
enum TodoProgressCalculation: Int, Codable, TPMenuRepresentable {
    
    /// 添加
    case sum = 0
    
    /// 更新
    case update
    
    var title: String {
        switch self {
        case .sum:
            return resGetString("Sum")
        case .update:
            return resGetString("Update")
        }
    }
}

/// 记录方式
enum TodoProgressRecordType: Int, Codable, TPMenuRepresentable {
    
    /// 手动
    case manual = 0
    
    /// 自动
    case auto
    
    var title: String {
        switch self {
        case .manual:
            return resGetString("Manual")
        case .auto:
            return resGetString("Auto")
        }
    }
}

