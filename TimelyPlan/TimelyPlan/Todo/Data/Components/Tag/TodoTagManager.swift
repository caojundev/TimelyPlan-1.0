//
//  TodoTagManager.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/3.
//

import Foundation
import CoreData

struct TodoTagKey {
    static var identifier = "identifier"
    static var name = "name"
    static let order = "order"
}

class TodoTagManager {

    /// 标签处理更新器
    let updater = TodoTagProcessorUpdater()
    
    private var userTags: [TodoTag]
    
    init() {
        self.userTags = TodoTagManager.getTags()
    }
    
    // MARK: - Providers
    /// 获取所有标签
    func getTags() -> [TodoTag] {
        return userTags
    }
    
    /// 包含特定名称的标签是否已存在
    func isTagExist(with name: String) -> Bool {
        var isExist = false
        for userTag in userTags {
            if userTag.name == name {
                isExist = true
                break
            }
        }
        
        return isExist
    }

    // MARK: - Processors
    
    /// 新建标签
    func createTag(with editTag: TodoEditTag) {
        guard let name = editTag.name?.whitespacesAndNewlinesTrimmedString, name.count > 0 else {
            return
        }
        
        if isTagExist(with: name) {
            return
        }
        
        /// 创建新标签
        let order = userTags.minOrder - kOrderedStep
        let tag = TodoTag.newTag(with: editTag, order: order)
        userTags.insert(tag, at: 0)
        updater.didCreateTodoTag(tag)
        todo.save()
    }
    
    /// 更新标签信息
    func updateTag(_ tag: TodoTag, with editTag: TodoEditTag) {
        if tag.editTag == editTag {
            return
        }
        
        /// 更新标签
        tag.update(with: editTag)
        updater.didUpdateTodoTag(tag)
        todo.save()
    }
    
    /// 删除标签
    func deleteTag(_ tag: TodoTag) {
        guard let _ = userTags.remove(tag) else {
            return
        }

        NSManagedObjectContext.defaultContext.delete(tag)
        updater.didDeleteTodoTag(tag)
        todo.save()
    }

    /// 重新排序标签
    func reorderTag(in tags: [TodoTag], fromIndex: Int, toIndex: Int) -> Bool  {
        var reorderTags = tags
        reorderTags.moveObject(fromIndex: fromIndex, toIndex: toIndex)
        reorderTags.updateOrders()
        
        /// 标签重新排序
        self.userTags = userTags.orderedElements(ascending: true)
        
        todo.save()
        updater.didReorderTodoTag(in: tags, fromIndex: fromIndex, toIndex: toIndex)
        return true
    }
    
    // MARK: - 数据库获取数据
    /// 异步获取所有名称包含特定文本的所有标签
    static func fetchTags(containText text: String, completion:(@escaping([TodoTag]?) -> Void)) {
        let condition: PredicateCondition = (TodoTagKey.name, .contains(text))
        let predicate = NSPredicate.predicate(with: condition)
        TodoTag.fetchAll(withPredicate: predicate,
                         sortedBy: TodoTagKey.order,
                         ascending: true) { results in
            if let tags = results as? [TodoTag], tags.count > 0 {
                completion(tags)
            } else {
                completion(nil)
            }
        }
    }
    
    /// 同步获取所有标签
    static func getTags() -> [TodoTag] {
        let results: [TodoTag]? = TodoTag.findAll(with: nil,
                                                  sortedBy: TodoTagKey.order,
                                                  ascending: true,
                                                  in: .defaultContext)
        if let results = results {
            return results
        }

        return []
    }
    
    /// 同步获取标识对应的标签数组
    static func getTags(with identifiers: [String]) -> [TodoTag]? {
        let condition: PredicateCondition = (TodoTagKey.identifier, .belongsTo(identifiers))
        let predicate = NSPredicate.predicate(with: condition)
        let results: [TodoTag]? = TodoTag.findAll(with: predicate,
                                                  sortedBy: TodoTagKey.order,
                                                  ascending: true,
                                                  in: .defaultContext)
        return results
    }
}
