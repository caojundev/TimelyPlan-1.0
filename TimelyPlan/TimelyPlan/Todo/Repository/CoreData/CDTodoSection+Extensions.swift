//
//  CDTodoSection+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/3.
//

import Foundation
import CoreData

struct TodoSectionKey {
    static var list = "list"
    static var order = "order"
}

extension CDTodoSection: SortableIdentifiable {
    
    /// 板块特征值
    var feature: TodoSectionFeature {
        return TodoSectionFeature(identifier: identifier ?? "",
                                  name: name,
                                  order: order,
                                  list: list?.feature)
    }
    
    // MARK: - SortableIdentifiable
    var identifiableKey: String {
        return self.identifier ?? ""
    }
    
    /// 同步获取所有标签
    static func getSections(in list: TodoList?) -> [CDTodoSection]? {
        if let list = list {
            let cdList = CDTodoList.getItem(with: list.identifier)
            return cdList?.sections?.orderedElements() as? [CDTodoSection]
        }
        
        /// 获取收件箱板块
        let condition: PredicateCondition = (TodoSectionKey.list, .isEmpty)
        let predicate = NSPredicate.predicate(with: condition)
        let results: [CDTodoSection]? = getAll(matching: predicate,
                                                sortBy: ElementOrderKey,
                                                ascending: true,
                                                in: .defaultContext)
        return results
    }
    
    /// 新建标签
    static func createSection(with name: String, in list: TodoList?) -> CDTodoSection? {
        let name = name.whitespacesAndNewlinesTrimmedString
        guard name.count > 0 else {
            return nil
        }
        
        var cdList: CDTodoList?
        if let list = list {
            cdList = CDTodoList.getItem(with: list.identifier)
        }

        let section = newSection(with: name)
        cdList?.addSection(section)
        return section
    }
    
    static func newSection(with name: String) -> CDTodoSection {
        let section = CDTodoSection.createEntity(in: .defaultContext)
        section.identifier = UUID().uuidString
        section.name = name
        return section
    }
    
    static func updateSection(_ section: TodoSection, with name: String) -> Bool {
        if section.name == name {
            return false
        }
        
        if let cdSection = getItem(with: section.identifier) {
            cdSection.name = name
            return true
        }
        
        return false
    }
    
    static func deleteSection(_ section: TodoSection) -> Bool {
        guard let cdSection = getItem(with: section.identifier) else {
            return false
        }
        
        let context = NSManagedObjectContext.defaultContext
        context.delete(cdSection)
        return true
    }
    
    /// 重新排序标签
    static func reorderSection(in sections: [TodoSection], fromIndex: Int, toIndex: Int) -> Bool {
        var sections = sections
        if sections.moveObject(fromIndex: fromIndex, toIndex: toIndex) {
            return syncOrders(for: sections)
        }
        
        return false
    }
    
}

extension Array where Element == CDTodoSection {
    
    func sections(with list: TodoList?) -> [TodoSection] {
        var results = [TodoSection]()
        for content in self {
            if content.identifier != nil {
                let section = TodoSection(content: content)
                section.list = list
                results.append(section)
            }
        }
        
        return results
    }
}
