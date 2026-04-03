//
//  TodoTagManager.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/3.
//

import Foundation
import CoreData

class TodoTagManager {

    /// 标签处理更新器
    let updater = TodoTagProcessorUpdater()
    
    // MARK: - Providers
    /// 获取所有标签
    func getTags() -> [TodoTag] {
        return CDTodoTag.getTags()?.tags ?? []
    }
    
    /// 包含特定名称的标签是否已存在
    func isTagExist(with name: String) -> Bool {
        let name = name.whitespacesAndNewlinesTrimmedString
        return CDTodoTag.isTagExist(with: name)
    }
    
    func fetchTags(containText text: String, completion:(@escaping([TodoTag]?) -> Void)) {
        CDTodoTag.fetchTags(containText: text) { results in
            completion(results?.tags)
        }
    }

    // MARK: - Processors
    
    /// 新建标签
    func createTag(with editingTag: TodoEditingTag) {
        guard let content = CDTodoTag.createTag(with: editingTag) else {
            return
        }
        
        let tag = TodoTag(content: content)
        HandyRecord.save()
        updater.didCreateTodoTag(tag)
    }
    
    /// 更新标签信息
    func updateTag(_ tag: TodoTag, with editingTag: TodoEditingTag) {
        guard CDTodoTag.updateTag(tag, with: editingTag) else {
            return
        }
        
        HandyRecord.save()
        updater.didUpdateTodoTag(tag)
    }
    
    /// 删除标签
    func deleteTag(_ tag: TodoTag) {
        guard CDTodoTag.deleteTag(tag) else {
            return
        }
        
        HandyRecord.save()
        updater.didDeleteTodoTag(tag)
    }

    /// 重新排序标签
    func reorderTag(in tags: [TodoTag], fromIndex: Int, toIndex: Int) {
        guard CDTodoTag.reorderTag(in: tags, fromIndex: fromIndex, toIndex: toIndex) else {
            return
        }
        
        HandyRecord.save()
        updater.didRecorderTodoTag(in: tags, fromIndex: fromIndex, toIndex: toIndex)
    }
    

}
