//
//  CDTodoList+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/31.
//

import Foundation

struct TodoListKey {
    static var identifier = "identifier"
    static var order = "order"
    static var name = "name"
    static var parent = "parent"
    static var creationDate = "creationDate"
}

extension CDTodoList: Sortable {
    
    /// 排序
    static var sortTerms: [SortTerm] {
        return [(TodoListKey.order, true),
                (TodoListKey.creationDate, true)]
    }
    
    
    func sortedSublists(parent: TodoList) -> [TodoList]? {
        let sortDescriptors = NSSortDescriptor.descriptors(with: Self.sortTerms)
        let sortedSublists = sublists?.sortedArray(using: sortDescriptors) as? [CDTodoList]
        guard let sortedSublists = sortedSublists else {
            return nil
        }
        
        return sortedSublists.map { content in
            let list = TodoList(content: content)
            list.parent = parent
            return list
        }
    }
    
    func update(with editingList: TodoEditingList) {
        self.emoji = editingList.emoji
        self.name = editingList.name
        self.colorHex = editingList.color?.hexString
        self.layoutRawValue = Int16(editingList.layoutType.rawValue)
    }
    
    func addSublist(_ list: CDTodoList) {
        let sublists = self.sublists?.allObjects as? [CDTodoList]
        let maxOrder = sublists?.maxOrder ?? 0
        list.order = maxOrder + kOrderedStep
        self.addToSublists(list)
    }
    
    func removeSublist(_ list: CDTodoList) {
        self.removeFromSublists(list)
    }
}

extension CDTodoList {
    
    static func coreDataList(for list: TodoList) -> CDTodoList? {
        return getList(withIdentifier: list.identifier)
    }
    
    static func newList(with editingList: TodoEditingList, parent: TodoList?) -> CDTodoList {
        let list = CDTodoList.createEntity(in: .defaultContext)
        list.identifier = UUID().uuidString
        list.creationDate = .now
        list.update(with: editingList)
        if let parent = parent {
            let cdParent = coreDataList(for: parent)
            cdParent?.addSublist(list)
        } else {
            /// 设置排序因子
            list.order = CDTodoList.maximumOrder + kOrderedStep
            print("添加到根列表： \(list.name): order = \(list.order)")
        }
    
        return list
    }
    
    static func update(list: TodoList, with editingList: TodoEditingList) -> Bool {
        if let cdList = coreDataList(for: list) {
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
            cdParent.addSublist(cdList)
        } else {
            /// 移动到顶层
            cdList.parent = nil
            cdList.order = CDTodoList.maximumOrder + kOrderedStep
            
            print("move 移动到根列表： \(list.name): order = \(list.order)")
        }
        
        return true
    }
}

extension CDTodoList {

    /// 获取特定标识的列表
    static func getList(withIdentifier identifier: String) -> CDTodoList? {
        let condition: PredicateCondition = (TodoListKey.identifier, .equal(identifier))
        let predicate = NSPredicate.predicate(with: condition)
        return CDTodoList.findFirst(withPredicate: predicate, in: .defaultContext)
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
    
    /// 创建默认用户列表
    static func createDefaultTopLists() -> [CDTodoList] {
        let editingList = TodoEditingList(name: resGetString("My List"))
        let defaultList = CDTodoList.newList(with: editingList, parent: nil)
        return [defaultList]
    }
}

extension Array where Element == CDTodoList {
    
    var userLists: [TodoList] {
        return self.map { TodoList(content: $0) }
    }
}
