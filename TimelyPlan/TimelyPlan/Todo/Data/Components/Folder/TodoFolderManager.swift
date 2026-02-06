//
//  TodoFolderManager.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/28.
//

import Foundation
import CoreData

struct TodoFolderKey {
    static let name = "name"
    static let order = "order"
}

class TodoFolderManager {
    
    /// 目录处理更新器
    let updater = TodoFolderProcessorUpdater()
    
    /// 目录数组
    private(set) var folders: [TodoFolder]
    
    /// 收起目录标识数组
    private var collapsedFolderIdentifiers: Set<String> = []
    
    init() {
        self.folders = TodoFolderManager.getFolders()
    }
    
    // MARK: - 展开 / 收起文件夹
    func isExpanded(_ folder: TodoFolder) -> Bool {
        guard let identifier = folder.identifier else  {
            return false
        }
        
        let isCollapsed = collapsedFolderIdentifiers.contains(identifier)
        return !isCollapsed
    }
    
    /// 展开目录
    func expandFolder(_ folder: TodoFolder) -> Bool {
        guard !isExpanded(folder), let identifier = folder.identifier else {
            return false
        }
        
        if let _ = collapsedFolderIdentifiers.remove(identifier) {
            return true
        }
        
        return false
    }
    
    /// 收起目录
    func collapseFolder(_ folder: TodoFolder) -> Bool {
        guard isExpanded(folder), let identifier = folder.identifier else {
            return false
        }
        
        collapsedFolderIdentifiers.insert(identifier)
        return true
    }
    
    /// 切换目录展开状态
    func toggleExpand(for folder: TodoFolder) {
        if isExpanded(folder) {
            let _ = collapseFolder(folder)
        } else {
            let _ = expandFolder(folder)
        }
    }
    
    // MARK: - Data Processors
    
    /// 新建目录
    func createFolder(with name: String?) {
        let folder = TodoFolder.newFolder(with: name)
        folders.append(folder)
        folders.updateOrders()
        updater.didCreateTodoFolder(folder)
        todo.save()
    }
    
    /// 更新目录
    func updateFolder(_ folder: TodoFolder, with name: String?) {
        guard folder.name != name else {
            return
        }

        folder.updateName(with: name)
        updater.didUpdateTodoFolder(folder)
        todo.save()
    }

    /// 删除目录
    func deleteFolder(_ folder: TodoFolder) {
        let listsCount = folder.lists?.count ?? 0
        guard listsCount == 0 else {
            return
        }
        
        let _ = folders.remove(folder)
        todo.delete(folder)
        updater.didDeleteTodoFolder(folder)
        todo.save()
    }
    
    /// 解散目录
    func ungroupFolder(_ folder: TodoFolder) {
        guard let orderedLists = folder.lists?.orderedElements() as? [TodoList] else {
            return
        }
        
        folder.removeAllLists()
        updater.didUngroupTodoFolder(folder, with: orderedLists)
        todo.save()
    }
    
    func reorderFolder(in items: [ListDiffable], fromIndex: Int, toIndex: Int) {
        guard var items = items as? [Sortable], let folder = items[fromIndex] as? TodoFolder  else {
            return
        }
        
        items.moveObject(fromIndex: fromIndex, toIndex: toIndex)
        items.updateOrders()
        
        /// 更新目录数组
        folders = folders.orderedElements()
        updater.didReorderTodoFolder(folder)
        todo.save()
    }
    
    // MARK: - Data Provider
    
    /// 异步搜索名称包含特定文本的文件夹
    static func fetchFolders(containText text: String,
                             completion:(@escaping([TodoFolder]?) -> Void)) {
        let predicate = NSPredicate.predicate(with: (TodoFolderKey.name, .contains(text)))
        TodoFolder.fetchAll(withPredicate: predicate,
                            sortedBy: ElementOrderKey,
                            ascending: true) { results in
            completion(results as? [TodoFolder])
        }
    }
    
    /// 同步获取所有文件夹
    static func getFolders() -> [TodoFolder] {
        let results: [TodoFolder]? = TodoFolder.findAll(with: nil,
                                                        sortedBy: TodoFolderKey.order,
                                                        ascending: true,
                                                        in: .defaultContext)
        return results ?? []
    }
    
}
