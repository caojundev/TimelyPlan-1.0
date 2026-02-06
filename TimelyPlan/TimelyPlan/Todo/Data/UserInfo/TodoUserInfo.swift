//
//  TodoUserInfo.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/27.
//

import Foundation
    
public class TodoUserInfo: NSObject, Codable {
    
    /// 列表状态信息
    private var listInfos: [String: TodoListInfo]?
    
    func info(for list: TodoListRepresentable) -> TodoListInfo? {
        guard let listInfos = listInfos, let identifier = list.identifier else {
            return nil
        }
        
        return listInfos[identifier]
    }
    
    func setInfo(_ info: TodoListInfo?, for list: TodoListRepresentable) {
        guard let info = info else {
            /// 移除列表信息
            if let identifier = list.identifier {
                listInfos?.removeValue(forKey: identifier)
            }
            
            return
        }

        guard let identifier = list.identifier else {
            return
        }
        
        if listInfos == nil {
            listInfos = [String: TodoListInfo]()
        }
        
        listInfos?[identifier] = info
    }
}

public class TodoListInfo: Codable {
    
    /// 是否显示已完成
    var showCompleted: Bool? = true
    
    /// 分组类型
    var groupType: TodoGroupType? = .default
    
    /// 排列类型
    var sortType: TodoSortType? = .manually
    
    /// 排列顺序
    var sortOrder: TodoSortOrder? = .ascending
    
    /// 收起分组ID数组
    var collapsedIds: [String]?
    
    /// 收起或展开分组
    func setCollapsed(_ isCollapsed: Bool, for group: TodoGroup) {
        if isCollapsed {
            if collapsedIds == nil {
                collapsedIds = [String]()
            }
            
            let bContain = collapsedIds!.contains(group.identifier)
            if !bContain {
                collapsedIds?.append(group.identifier)
            }
        } else {
            let _ = collapsedIds?.remove(group.identifier)
        }
    }
    
    /// 分组是否收起
    func isCollapsed(_ group: TodoGroup) -> Bool {
        guard let collapsedIds = collapsedIds else {
            return false
        }
        
        return collapsedIds.contains(group.identifier)
    }
    
}
