//
//  CDTodoList+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/31.
//

import Foundation
import CoreData
import UIKit

struct TodoListKey {
    static var identifier = "identifier"
    static var order = "order"
    static var name = "name"
    static var parent = "parent"
    static var creationDate = "creationDate"
}

// MARK: - 任务操作
extension CDTodoList {
    
    /// 列表特征
    var feature: TodoListFeature {
        return TodoListFeature(identifier: identifiableKey,
                               name: name,
                               colorHex: colorHex)
    }
    
    /// 列表任务最大排序因子
    var maxTaskOrder: Int64 {
        guard let tasks = tasks?.allObjects as? [CDTodoTask] else {
            return 0
        }
        
        return tasks.maxOrder
    }
    
    /// 添加任务到列表，自动设置排序因子
    func addTask(_ task: CDTodoTask, onTop: Bool = false) {
        let tasks = tasks?.allObjects as? [CDTodoTask]
        let order: Int64
        if onTop {
            let minOrder = tasks?.minOrder ?? 0
            order = minOrder - kOrderedStep
        } else {
            let maxOrder = tasks?.maxOrder ?? 0
            order = maxOrder + kOrderedStep
        }
        
        task.order = order
        self.addToTasks(task)
    }
}

extension CDTodoList: SortableIdentifiable {
    
    // MARK: - SortableIdentifiable
    var identifiableKey: String {
        return self.identifier ?? ""
    }
    
    /// 排序
    static var sortTerms: [SortTerm] {
        return [(TodoListKey.order, true),
                (TodoListKey.creationDate, true)]
    }
    
    var hasSublist: Bool {
        guard let lists = self.sublists else {
            return false
        }
        
        return lists.count > 0
    }
    
    /// 排序的 CoreData 子列表
    func orderedCoreDataSublists() -> [CDTodoList]? {
        let sortDescriptors = NSSortDescriptor.descriptors(with: Self.sortTerms)
        let sortedSublists = sublists?.sortedArray(using: sortDescriptors) as? [CDTodoList]
        return sortedSublists
    }
    
    /// 排序的子列表
    func sortedSublists(parent: TodoList) -> [TodoList]? {
        guard let sortedSublists = orderedCoreDataSublists() else {
            return nil
        }
        
        return sortedSublists.map { content in
            let list = TodoList(content: content)
            list.parent = parent
            return list
        }
    }
}

extension CDTodoList {
    
    func update(with editingList: TodoEditingList) {
        self.emoji = editingList.emoji
        self.name = editingList.name
        self.colorHex = editingList.color?.hexString
        self.layoutRawValue = Int16(editingList.layoutType.rawValue)
    }
    
    func addSublist(_ list: CDTodoList, onTop: Bool) {
        let sublists = self.sublists?.allObjects as? [CDTodoList]
        if onTop {
            let minOrder = sublists?.minOrder ?? kOrderedStep
            list.order = minOrder - kOrderedStep
        } else {
            let maxOrder = sublists?.maxOrder ?? 0
            list.order = maxOrder + kOrderedStep
        }
        
        addToSublists(list)
    }
    
    func removeSublist(_ list: CDTodoList) {
        removeFromSublists(list)
    }
    
    func removeAllSublists() {
        guard let lists = sublists else {
            return
        }
        
        removeFromSublists(lists)
    }
}

extension CDTodoList {
    
    /// 创建默认用户列表
    static func createDefaultTopLists() -> [CDTodoList] {
        let editingList = TodoEditingList(name: resGetString("My List"))
        let defaultList = newList(with: editingList, parent: nil, onTop: true)
        return [defaultList]
    }
    
    static func newList(with editingList: TodoEditingList,
                        parent: TodoList?,
                        onTop: Bool) -> CDTodoList {
        let list = createEntity(in: .defaultContext)
        list.identifier = UUID().uuidString
        list.creationDate = .now
        list.update(with: editingList)
        if let parent = parent {
            let cdParent = coreDataList(for: parent)
            cdParent?.addSublist(list, onTop: onTop)
        } else {
            /// 设置排序因子
            if onTop {
                list.order = minimumOrder - kOrderedStep
            } else {
                list.order = maximumOrder + kOrderedStep
            }
        }
    
        return list
    }
    
    static func updateList(_ aList: TodoList, with editingList: TodoEditingList) -> Bool {
        if aList.isSameEditingList(as: editingList) {
            return false
        }

        if let cdList = coreDataList(for: aList) {
            cdList.update(with: editingList)
            return true
        }
        
        return false
    }
    
    /// 移动列表
    static func moveList(_ list: TodoList, to parent: TodoList?) -> Bool {
        if list.identifier == parent?.identifier || parent?.identifier == list.parent?.identifier {
            return false
        }
        
        guard let cdList = coreDataList(for: list) else {
            return false
        }
        
        var cdParent: CDTodoList?
        if let parent = parent {
            cdParent = coreDataList(for: parent)
        }
        
        if let cdParent = cdParent {
            cdParent.addSublist(cdList, onTop: false)
        } else {
            /// 移动到顶层
            cdList.parent = nil
            cdList.order = maximumOrder + kOrderedStep
        }
        
        return true
    }
    
    /// 解散列表
    static func ungroupList(_ aList: TodoList) -> Bool {
        guard let list = coreDataList(for: aList), list.hasSublist else {
            return false
        }
        
        let parentList = list.parent
        var parentSublists: [CDTodoList]
        if let parentList = parentList {
            /// 但前清单同层级的列表数组
            parentSublists = parentList.orderedCoreDataSublists() ?? []
        } else {
            /// 顶层清单数组
            parentSublists = getTopLists() ?? []
        }
        
        guard let index = parentSublists.firstIndex(of: list) else {
            return false
        }
        
        let orderedSublists = list.orderedCoreDataSublists() ?? []
        
        /// 移除当前列表所有子列表
        list.removeAllSublists()
        
        /// 添加到当前列表父列表
        if let parentList = parentList {
            parentList.addToSublists(Set(orderedSublists) as NSSet)
        }
        
        parentSublists.insert(contentsOf: orderedSublists, at: index + 1)
        parentSublists.updateOrders() /// 更新顺序因子
        return true
    }
    
    /// 执行插入操作
    static func reorderList(in lists: [TodoList], fromIndex: Int, toIndex: Int, depth: Int) -> Bool {
        var items = lists
        items.moveObject(fromIndex: fromIndex, toIndex: toIndex)
        guard items.count > 1 else {
            return false
        }
        
        let currentList = items[toIndex]
        var sameDepthLists = [currentList]
        var parentList: TodoList?
        let aboveItems = items.elementsAbove(at: toIndex)
        for aboveItem in aboveItems {
            let itemDepth = aboveItem.depth
            if itemDepth == depth {
                sameDepthLists.insert(aboveItem, at: 0)
            } else if itemDepth < depth {
                parentList = aboveItem
                break
            }
        }
        
        /// 下方条目
        let belowItems = items.elementsBelow(at: toIndex)
        for belowItem in belowItems {
            let itemDepth = belowItem.depth
            if itemDepth == depth {
                sameDepthLists.append(belowItem)
            } else if itemDepth < depth {
                break
            }
        }
        
        var bChanged = false
        let currentParent = currentList.parent
        if let parentList = parentList {
            if parentList.identifiableKey != currentParent?.identifiableKey {
                /// 非相同父列表，移动到当前父条目
                let bMoved = moveList(currentList, to: parentList)
                parentList.addSublist(currentList) 
                bChanged = bChanged || bMoved
            }
        } else {
            /// 移动到根列表
            let bMoved = moveList(currentList, to: nil)
            bChanged = bChanged || bMoved
        }
   
        /// 更新排序因子
        if sameDepthLists.count > 1 {
            let bSynced = syncOrders(for: sameDepthLists)
            bChanged = bChanged || bSynced
        }
        
        return bChanged
    }
    
    /// 删除列表
    static func deleteList(_ aList: TodoList) -> Bool {
        guard let list = coreDataList(for: aList), !list.hasSublist else {
            return false
        }
    
        let context = NSManagedObjectContext.defaultContext
        context.delete(list)
        return true
    }
    
    /// 将所有任务移到废纸篓
    static func moveAllTasksToTrash(in aList: TodoList) -> Set<CDTodoTask>? {
        guard let list = coreDataList(for: aList),
                let tasks = list.tasks as? Set<CDTodoTask>,
                tasks.count > 0 else {
            return nil
        }
    
        for task in tasks {
            task.isRemoved = true
        }
        
        return tasks
    }
}

extension CDTodoList {
    
    static func coreDataList(for list: TodoList) -> CDTodoList? {
        return getItem(with: list.identifier)
    }
    
    /// 搜索清单
    static func fetchLists(containText text: String, completion:(@escaping([CDTodoList]?) -> Void)) {
        let condition: PredicateCondition = (TodoListKey.name, .contains(text))
        let predicate = NSPredicate.predicate(with: condition)
        fetchAll(matching: predicate, sortTerms: sortTerms) { results in
            completion(results as? [CDTodoList])
        }
    }
    
    /// 获取根列表
    static func fetchTopLists(completion: @escaping([CDTodoList]?) -> Void) {
        fetchAll(matching: topListPredicate, sortTerms: sortTerms) { results in
            completion(results as? [CDTodoList])
        }
    }
    
    static func getTopLists() -> [CDTodoList]? {
        let results: [CDTodoList]? = findAll(with: topListPredicate,
                                             sortTerms: sortTerms,
                                             in: .defaultContext)
        return results
    }

    static var topListPredicate: NSPredicate {
        let condition: PredicateCondition = (TodoListKey.parent, .isEmpty)
        return NSPredicate.predicate(with: condition)
    }
}

extension Array where Element == CDTodoList {
    
    var userLists: [TodoList] {
        return self.map { TodoList(content: $0) }
    }
}
