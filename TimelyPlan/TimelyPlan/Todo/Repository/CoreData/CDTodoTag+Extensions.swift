//
//  CDTodoTag+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/2.
//

import Foundation
import CoreData

struct TodoTagKey {
    static var identifier = "identifier"
    static var order = "order"
    static var name = "name"
    static var creationDate = "creationDate"
}

extension CDTodoTag: SortableIdentifiable {
    
    // MARK: - SortableIdentifiable
    var identifiableKey: String {
        return self.identifier ?? ""
    }
    
    /// 更新标签
    func update(with editingTag: TodoEditingTag) {
        self.name = editingTag.name
        self.colorHex = editingTag.color.hexString
    }
    
    /// 新建标签
    static func createTag(with editingTag: TodoEditingTag, onTop: Bool) -> CDTodoTag? {
        guard let name = editingTag.name?.whitespacesAndNewlinesTrimmedString, name.count > 0 else {
            return nil
        }
        
        let tag = newTag(with: editingTag)
        if onTop {
            tag.order = minimumOrder - kOrderedStep
        } else {
            tag.order = maximumOrder + kOrderedStep
        }
        
        return tag
    }
    
    static func newTag(with editingTag: TodoEditingTag) -> CDTodoTag {
        let tag = CDTodoTag.createEntity(in: .defaultContext)
        tag.identifier = UUID().uuidString
        tag.creationDate = .now
        tag.update(with: editingTag)
        return tag
    }
    
    static func updateTag(_ tag: TodoTag, with editingTag: TodoEditingTag) -> Bool {
        if tag.editingTag == editingTag {
            return false
        }
        
        if let cdTag = getItem(with: tag.identifier) {
            cdTag.update(with: editingTag)
            return true
        }
        
        return false
    }
    
    static func deleteTag(_ tag: TodoTag) -> Bool {
        guard let cdTag = getItem(with: tag.identifier) else {
            return false
        }
        
        let context = NSManagedObjectContext.defaultContext
        context.delete(cdTag)
        return true
    }
    
    /// 重新排序标签
    static func reorderTag(in tags: [TodoTag], fromIndex: Int, toIndex: Int) -> Bool {
        var reorderTags = tags
        reorderTags.moveObject(fromIndex: fromIndex, toIndex: toIndex)
        return syncOrders(for: reorderTags)
    }
    
}

extension CDTodoTag {
    
    static var sortTerms: [SortTerm] {
        return [(TodoTagKey.order, true),
                (TodoTagKey.creationDate, true)]
    }
    
    static func getTags(for tags: Set<TodoTag> ) -> [CDTodoTag]? {
        let result = getIdentifiableItems(with: Array(tags))
        return result as? [CDTodoTag]
    }
    
    /// 同步获取所有标签
    static func getTags() -> [CDTodoTag]? {
        let results: [CDTodoTag]? = findAll(with: nil,
                                            sortedBy: ElementOrderKey,
                                            ascending: true,
                                            in: .defaultContext)
        return results
    }
    
    static func fetchTags(containText text: String, completion:(@escaping([CDTodoTag]?) -> Void)) {
        let condition: PredicateCondition = (TodoTagKey.name, .contains(text))
        let predicate = NSPredicate.predicate(with: condition)
        fetchAll(matching: predicate, sortTerms: sortTerms) { results in
            completion(results as? [CDTodoTag])
        }
    }

    static func fetchTags(completion: @escaping([CDTodoTag]?) -> Void) {
        findAll(with: nil, sortedBy: ElementOrderKey, ascending: true) { results in
            completion(results as? [CDTodoTag])
        }
    }
    
    static func isTagExist(with name: String) -> Bool {
        let condition: PredicateCondition = (TodoTagKey.name, .equal(name))
        let predicate = NSPredicate.predicate(with: condition)
        let count = countOfEntries(with: predicate, in: .defaultContext)
        return count > 0
    }
}

extension Array where Element == CDTodoTag {
    
    var tags: [TodoTag] {
        self.map{ TodoTag(content: $0) }
    }
}
