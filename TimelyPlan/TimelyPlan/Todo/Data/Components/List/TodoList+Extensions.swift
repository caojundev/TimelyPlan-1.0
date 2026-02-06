//
//  TodoList+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/2.
//

import Foundation

extension TodoList {
    
    /// 列表编辑信息
    var editList: TodoEditList {
        return TodoEditList(emoji: emoji,
                            name: name,
                            color: color,
                            layoutType: layoutType)
    }
    
    /// 当前编辑列表是否与特定列表信息对象相同
    func isSame(as editList: TodoEditList) -> Bool {
        return self.editList == editList
    }
    
    /// 新建列表
    static func newList(with editList: TodoEditList, folder: TodoFolder? = nil) -> TodoList {
        let list = TodoList.createEntity(in: .defaultContext)
        list.identifier = NSUUID().uuidString
        list.folder = folder
        list.update(with: editList)
        return list
    }
    
    /// 更新列表属性
    func update(with editList: TodoEditList) {
        self.emoji = editList.emoji
        self.name = editList.name
        self.colorHex = editList.color?.hexString
        self.layoutRawValue = Int32(editList.layoutType.rawValue)
    }
    
}

extension TodoList: Sortable,
                    TPHexColorConvertible,
                    TodoListRepresentable {

    /// 列表类型
    var listMode: TodoListMode {
        return .user
    }
    
    var layoutType: TodoListLayoutType {
        let type = TodoListLayoutType(rawValue: Int(layoutRawValue))
        return type ?? .list
    }
    
    /// 显示标题（包含emoji）
    func displayTitle() -> String {
        var title: String = ""
        if let emoji = self.emoji, emoji.count == 1 {
            title += emoji
        }
        
        let name = self.name ?? resGetString("Untitled")
        title += name
        return title
    }
    
    func getTasks() -> Set<TodoTask> {
        let tasks = self.tasks as? Set<TodoTask> ?? []
        return tasks
    }
    
    /// 列表中是否有任务
    func hasTask() -> Bool {
        let count = tasks?.count ?? 0
        return count > 0
    }

    var defaultColor: UIColor {
        return resGetColor(.title)
    }
    
    /// 标题名称
    var title: String {
        return self.name ?? resGetString("Untitled")
    }
    
    func orderedTasks() -> [TodoTask] {
        if let tasks = tasks?.orderedElements() as? [TodoTask] {
            return tasks
        }
        
        return []
    }
    
    var icon: TPIcon? {
        if let emoji = emoji {
            return TPIcon(text: emoji)
        }
            
        let iconName = layoutType.miniIconName
        return TPIcon(name: iconName)
    }
    
    
    /// 新建列表
    static func newList(with editList: TodoEditList) -> TodoList {
        let list = TodoList.createEntity(in: .defaultContext)
        list.identifier = NSUUID().uuidString
        list.update(with: editList)
        return list
    }
    
    /// 添加任务到列表，自动设置排序因子
    func addTask(_ task: TodoTask, onTop: Bool = false) {
        let tasks = tasks?.allObjects as? [TodoTask]
        let order: Int64
        if onTop {
            let minOrder = tasks?.minOrder ?? 0
            order = minOrder - kOrderedStep
        } else {
            let maxOrder = tasks?.maxOrder ?? 0
            order = maxOrder + kOrderedStep
        }
        
        task.order = order
        addToTasks(task)
    }
}


extension Array where Element == TodoList {
    
    /// 添加列表，自动更新排序因子
    mutating func addList(_ list: TodoList) {
        list.order = self.maxOrder + kOrderedStep
        self.append(list)
    }
}
