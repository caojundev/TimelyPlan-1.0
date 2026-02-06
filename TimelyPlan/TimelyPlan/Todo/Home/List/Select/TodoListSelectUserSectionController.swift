//
//  TodoListSelectUserSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/15.
//

import Foundation

class TodoListSelectUserSectionController: TodoFolderListSectionController {
    
    /// 当前收起的列表
    private var collapsedFolders = Set<TodoFolder>()

    override var items: [ListDiffable]? {
        return todo.folderedLists { folder in
            return self.isExpandedFolder(folder)
        }
    }
    
    override func isExpandedFolder(_ folder: TodoFolder) -> Bool {
       return !collapsedFolders.contains(folder)
    }
    
    override func setExpand(_ isExpanded: Bool, for folder: TodoFolder) {
        if isExpanded {
            collapsedFolders.remove(folder)
        } else {
            collapsedFolders.insert(folder)
        }
    }
    
    override func classForListCell() -> AnyClass {
        return TodoListSelectCell.self
    }
    
    override func didDequeFolderCell(_ cell: TodoFolderHomeCell, for folder: TodoFolder, at index: Int) {
        super.didDequeFolderCell(cell, for: folder, at: index)
        
        cell.rightViewSize = .zero
        cell.rightView?.isUserInteractionEnabled = false
        cell.rightView?.isHidden = true
    }
}

