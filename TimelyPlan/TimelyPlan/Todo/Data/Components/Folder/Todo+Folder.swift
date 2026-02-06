//
//  Todo+Folder.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/1.
//

import Foundation

extension Todo {
    
    /// 获取用户列表数组
    func folderedLists(shouldExpand: ((TodoFolder) -> Bool)? = nil) -> [ListDiffable]? {
        var items: [Sortable] = folderManager.folders
        if let lists = listManager.rootLists {
            items.append(contentsOf: lists)
        }
        
        let orderedItems = items.sorted { $0.order < $1.order }
        guard let shouldExpand = shouldExpand else {
            return orderedItems as? [ListDiffable]
        }
        
        var results: [ListDiffable] = []
        for item in orderedItems {
            results.append(item as! ListDiffable)
            guard let folder = item as? TodoFolder else {
                continue
            }
            
            if shouldExpand(folder), let lists = folder.orderedLists {
                results.append(contentsOf: lists)
            }
        }

        return results
    }
    
    /// 目录是否展开
    func isExpanded(_ folder: TodoFolder) -> Bool {
        return folderManager.isExpanded(folder)
    }
  
    /// 展开 / 收起目录
    @discardableResult
    func setExpand(_ isExpanded: Bool, for folder: TodoFolder) -> Bool {
        if isExpanded {
            return folderManager.expandFolder(folder)
        } else {
            return folderManager.collapseFolder(folder)
        }
    }
    
    /// 切换目录展开状态
    func toggleExpand(for folder: TodoFolder) {
        let isExpanded = isExpanded(folder)
        let _ = setExpand(!isExpanded, for: folder)
    }
    
    /// 获取用户目录数组
    func folders() -> [TodoFolder] {
        return folderManager.folders
    }

    /// 新建目录
    func createFolder(with name: String?) {
        folderManager.createFolder(with: name)
    }
    
    /// 新建目录
    func updateFolder(_ folder: TodoFolder, with name: String?) {
        folderManager.updateFolder(folder, with: name)
    }
    
    func ungroupFolder(_ folder: TodoFolder) {
        folderManager.ungroupFolder(folder)
    }
    
    func deleteFolder(_ folder: TodoFolder) {
        folderManager.deleteFolder(folder)
    }
    
    func reorderFolder(in items: [ListDiffable], fromIndex: Int, toIndex: Int) {
        folderManager.reorderFolder(in: items, fromIndex: fromIndex, toIndex: toIndex)
    }
}
