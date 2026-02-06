//
//  Named.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/1.
//

import Foundation

protocol TaskRepresentable: NSObjectProtocol, ListDiffable {
    
    /// 标识
    var identifier: String? { get set }
    
    /// 任务名称
    var name: String? { get set }

    /// 任务的摘要或概要信息
    var summary: String? { get }
    
    /// 获取任务信息
    var info: TaskInfo { get }
}

extension TaskRepresentable {
    
    /// 摘要信息
    var summary: String? {
        return nil
    }

    // MARK: - 等同性判断
    var hash: Int{
        let identifier = identifier ?? ""
        return identifier.hashValue
    }

    func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Self else { return false }
        if self === other { return true }
        return self.identifier == other.identifier
    }
}
