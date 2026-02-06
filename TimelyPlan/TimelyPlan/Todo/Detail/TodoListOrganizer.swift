//
//  TodoListOrganizable.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/22.
//

import Foundation

class TodoListOrganizer {
    
    /// 是否显示已完成
    var showCompleted: Bool {
        get {
            return listUserInfo.showCompleted ?? true
        }
        
        set {
            listUserInfo.showCompleted = newValue
            saveListUserInfo()
        }
    }
    
    /// 分组类型
    var groupType: TodoGroupType {
        get {
            return list.validatedGroupType(listUserInfo.groupType)
        }
        
        set {
            listUserInfo.groupType = list.validatedGroupType(newValue)
            saveListUserInfo()
        }
    }

    /// 排列方式
    var sortType: TodoSortType {
        get {
            return list.validatedSortType(listUserInfo.sortType)
        }
        
        set {
            listUserInfo.sortType = list.validatedSortType(newValue)
            saveListUserInfo()
        }
    }
    
    /// 排列顺序
    var sortOrder: TodoSortOrder {
        get {
            return list.validatedSortOrder(listUserInfo.sortOrder, for: sortType)
        }
        
        set {
            listUserInfo.sortOrder = list.validatedSortOrder(newValue, for: sortType)
            saveListUserInfo()
        }
    }
    
    /// 由排列方式和排列顺序组合而成的排序对象
    var sort: TodoSort {
        get {
            return TodoSort(type: self.sortType, order: self.sortOrder)
        }
        
        set {
            listUserInfo.sortType = newValue.type
            listUserInfo.sortOrder = newValue.order
            saveListUserInfo()
        }
    }

    /// 用户列表
    private let list: TodoListRepresentable

    /// 列表用户信息
    private var listUserInfo: TodoListInfo
    
    init(list: TodoListRepresentable) {
        self.list = list
        self.listUserInfo = todo.listInfo(for: list) ?? TodoListInfo()
    }
    
    /// 根据分组类型、排序方式返回待办分组数组
    func getGroups() -> [TodoGroup] {
        return []
    }
    
    /// 列表中是否有任务
    func hasTask() -> Bool {
        return list.hasTask()
    }
    
    /// 列表是否可以添加任务
    func canAddTask() -> Bool {
        let mode = list.listMode
        if mode == .trash || mode == .completed  {
            return false
        }
        
        return true
    }
    
    /// 允许的分组类型
    func allowGroupTypes() -> [TodoGroupType] {
        return list.allowGroupTypes()
    }
    
    /// 允许的排序类型
    func allowSortTypes() -> [TodoSortType] {
        return list.allowSortTypes()
    }
    
    func allowSortOrders() -> [TodoSortOrder] {
        return list.allowSortOrders(for: sortType)
    }
    
    // MARK: - 列表选项
    func listOptions() -> [TodoListOption] {
        let mode = list.listMode
        switch mode {
        case .user, .inbox:
            return userListOptions()
        case .completed:
            return completedListOptions()
        case .planned:
            return []
        case .trash:
            return trashListOptions()
        }
    }
    
    /// 是否显示分组选项
    private var shouldShowGroupOption: Bool {
        let allowGroupTypes = list.allowGroupTypes()
        return allowGroupTypes.count > 1
    }
    
    /// 是否显示排列方式
    var shouldShowSortType: Bool {
        let allowSortTypes = list.allowSortTypes()
        return allowSortTypes.count > 1
    }
    
    /// 是否显示排列顺序
    var shouldShowSortOrder: Bool {
        let allowSortOrders = list.allowSortOrders(for: self.sortType)
        return allowSortOrders.count > 1
    }
    
    /// 是否显示排序选项
    private var shouldShowSortOption: Bool {
        return shouldShowSortType || shouldShowSortOrder
    }
    
    /// 分组排序选项
    private var groupAndSortOptions: [TodoListOption] {
        var options = [TodoListOption]()
        if shouldShowGroupOption {
            options.append(.group)
        }
        
        if shouldShowSortOption {
            options.append(.sort)
        }
        
        return options
    }
    
    private func userListOptions() -> [TodoListOption] {
        var options = [TodoListOption]()
        if list.hasTask() {
            options.append(.select)
        }
        
        options.append(.showCompleted)
        options.append(.layout)
        options.append(contentsOf: groupAndSortOptions)
        if list.listMode == .user {
            options.append(contentsOf: [.edit, .delete])
        }
        
        return options
    }
    
    private func completedListOptions() -> [TodoListOption] {
        var options = [TodoListOption]()
        if list.hasTask() {
            options.append(.select)
        }
        
        options.append(contentsOf: groupAndSortOptions)
        return options
    }

    private func trashListOptions() -> [TodoListOption] {
        var options = [TodoListOption]()
        if list.hasTask() {
            options.append(.select)
        }
        
        options.append(.emptyTrash)
        return options
    }
    
    // MARK: - 保存展开/收起分组状态信息
    /// 收起或展开分组
    func setCollapsed(_ isCollapsed: Bool, for group: TodoGroup) {
        listUserInfo.setCollapsed(isCollapsed, for: group)
        saveListUserInfo()
    }
    
    func saveListUserInfo() {
        /// 保存列表用户数据
        todo.setListInfo(self.listUserInfo, for: self.list)
    }
}
