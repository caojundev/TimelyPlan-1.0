//
//  Todo+Tag.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/3.
//

import Foundation

extension Todo {
    
    // MARK: - Providers
    func getTags() -> [TodoTag] {
        return tagManager.getTags()
    }
    
    func getTags(with identifiers: [String]) -> [TodoTag]? {
        return TodoTagManager.getTags(with: identifiers)
    }
    
    /// 判断标签名称是否已存在
    func isTagExist(with name: String) -> Bool {
        return tagManager.isTagExist(with: name)
    }
    
    /// 搜索标签
    func searchTags(containText text: String,
                     completion:(@escaping([TodoTag]?) -> Void)) {
        TodoTagManager.fetchTags(containText: text, completion: completion)
    }
    
    // MARK: - Processors    
    /// 新建标签
    func createTag(with editTag: TodoEditTag) {
        tagManager.createTag(with: editTag)
    }
    
    /// 删除标签
    func deleteTag(_ tag: TodoTag) {
        tagManager.deleteTag(tag)
    }
    
    /// 更新标签信息
    func updateTag(_ tag: TodoTag, with editTag: TodoEditTag) {
        tagManager.updateTag(tag, with: editTag)
    }

    /// 重新排序标签
    func reorderTag(in tags: [TodoTag], fromIndex: Int, toIndex: Int) -> Bool {
        return tagManager.reorderTag(in: tags, fromIndex: fromIndex, toIndex: toIndex)
    }
    
}
