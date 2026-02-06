//
//  TodoSmartList.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/13.
//

import Foundation
import UIKit

/// 智能清单类型
enum TodoSmartListType: String, TPMenuRepresentable {
    case inbox     /// 收件箱
    case completed /// 已完成
    case planned   /// 计划
    case trash     /// 废纸篓
    
    /// 除废纸篓之外所有类型数组
    static var typesExceptTrash: [TodoSmartListType] {
        var types = TodoSmartListType.allCases
        let _ = types.remove(.trash)
        return types
    }
    
    /// 图标名称
    var iconName: String? {
        return "todo_smartlist_" + self.rawValue + "_24"
    }
}

class TodoSmartList: NSObject, TodoListRepresentable {
    
    var identifier: String?
    
    var iconName: String? {
        return listType.iconName
    }
    
    var title: String {
        return listType.title
    }
    
    var icon: UIImage? {
        if let iconName = listType.iconName {
            return resGetImage(iconName)
        }
        
        return nil
    }
    
    /// 列表类型
    let listType: TodoSmartListType
    
    init(type: TodoSmartListType) {
        self.listType = type
        self.identifier = type.rawValue
        super.init()
    }
    
    static var inbox: TodoSmartList {
        return TodoSmartList(type: .inbox)
    }
    
    static var completed: TodoSmartList {
        return TodoSmartList(type: .completed)
    }
    
    static var trash: TodoSmartList {
        return TodoSmartList(type: .trash)
    }
    
    /// 获取所有智能清单对象
    static var allLists: [TodoSmartList] {
         return TodoSmartListType.allCases.map {
             TodoSmartList(type: $0)
         }
    }
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(listType)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? TodoSmartList else { return false }
        if self === other { return true }
        return listType == other.listType
    }
    
    // MARK: - Equatable
    static func == (lhs: TodoSmartList, rhs: TodoSmartList) -> Bool {
        return lhs.listType == rhs.listType
    }
    
    // MARK: - TodoListRepresentable
    var listMode: TodoListMode {
        return TodoListMode(rawValue: listType.rawValue)!
    }
    
    func displayTitle() -> String {
        return listType.title
    }
    
    func hasTask() -> Bool {
        let count = todo.numberOfTasks(in: self)
        return count > 0
    }
}
