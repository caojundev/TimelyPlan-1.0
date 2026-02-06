//
//  TodoFolderListSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/28.
//

import Foundation

class TodoFolderListSectionController: TPTableBaseSectionController,
                                         TodoFolderHomeCellDelegate,
                                         TodoListHomeCellDelegate {
    
    /// 选中列表
    var didSelectList: ((TodoList) -> Void)?
    
    /// 分区所有条目
    override var items: [ListDiffable]? {
        return todo.folderedLists { folder in
            return todo.isExpanded(folder)
        }
    }
    
    let folderController = TodoFolderController()
    
    let listController = TodoListController()
    
    // MARK: - Delegate
    override func heightForHeader() -> CGFloat {
        return 0.0
    }
    
    override func heightForFooter() -> CGFloat {
        return 0.0
    }
    
    override func heightForRow(at index: Int) -> CGFloat {
        return 55.0
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        let elementType = currentItems.elementType(at: index)
        switch elementType {
        case .folder:
            return classForFolderCell()
        case .list:
            return classForListCell()
        }
    }
    
    func classForFolderCell() -> AnyClass {
        return TodoFolderHomeCell.self
    }
        
    func classForListCell() -> AnyClass {
        return TodoListHomeCell.self
    }

    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        guard let cell = cell as? TPBaseTableCell else {
            return
        }
        
        cell.delegate = self
        cell.style = styleForRow(at: index)
        
        if let cell = cell as? TodoFolderHomeCell {
            if let folder = item(at: index) as? TodoFolder {
                didDequeFolderCell(cell, for: folder, at: index)
            }
        } else if let cell = cell as? TodoListBaseCell {
            if let list = item(at: index) as? TodoList {
                didDequeListCell(cell, for: list, at: index)
            }
        }
    }
    
    func didDequeFolderCell(_ cell: TodoFolderHomeCell, for folder: TodoFolder, at index: Int) {
        cell.folder = folder
        let isExpanded = isExpandedFolder(folder)
        cell.setExpanded(isExpanded, animated: false)
    }
    
    func didDequeListCell(_ cell: TodoListBaseCell, for list: TodoList, at index: Int) {
        cell.list = list
    }
    
    override func didSelectRow(at index: Int) {
        super.didSelectRow(at: index)
        TPImpactFeedback.impactWithSoftStyle()
        guard let item = item(at: index) else {
            return
        }
        
        if let list = item as? TodoList {
            didSelectList?(list)
        } else if let folder = item as? TodoFolder {
            toggleExpand(for: folder)
        }
    }
    
    // MARK: - TodoListHomeCellDelegate
    func todoListHomeCellDidClickMore(_ cell: TodoListHomeCell) {
        guard let list = cell.list else {
            return
        }
        
        let actionController = TodoListMenuActionController(list: list)
        actionController.didSelectMenuActionType = { type in
            self.performListMenuActionType(type, for: list)
        }
        
        actionController.showMenu(from: cell.moreButton)
    }

    // MARK: - TodoFolderHomeCellDelegate
    func expandImageInfoTableCell(_ cell: TPExpandImageInfoRightButtonTableCell, didToggleExpand isExpanded: Bool) {
        guard let cell = cell as? TodoFolderHomeCell, let folder = cell.folder else {
            return
        }
        
        setExpand(isExpanded, for: folder)
        adapter?.performSectionUpdate(forSectionObject: self)
    }
    
    func todoFolderHomeCellDidClickMore(_ cell: TodoFolderHomeCell) {
        guard let folder = cell.folder else {
            return
        }
        
        let actionController = TodoFolderMenuActionController(folder: folder)
        actionController.didSelectMenuActionType = { type in
            self.performFolderMenuActionType(type, for: folder)
        }
        
        actionController.showMenu(from: cell.rightButton)
    }
    
    // MARK: - Menu Action
    func performFolderMenuActionType(_ type: TodoFolderMenuActionType, for folder: TodoFolder) {
        switch type {
        case .addList:
            listController.createNewList(in: folder)
        case .ungroup:
            folderController.ungroupFolder(folder)
        case .edit:
            folderController.editFolder(folder)
        case .delete:
            folderController.deleteFolder(folder)
        }
    }
    
    func performListMenuActionType(_ type: TodoListMenuActionType, for list: TodoList) {
        switch type {
        case .move:
            listController.moveList(list)
        case .edit:
            listController.editList(list)
        case .delete:
            listController.deleteList(list)
        }
    }
    
    
    // MARK: - 目录操作
    func toggleExpand(for folder: TodoFolder) {
        guard let cell = adapter?.cellForItem(folder) as? TodoFolderHomeCell else {
            return
        }
        
        let isExpanded = !cell.isExpanded
        cell.setExpanded(isExpanded, animated: true)
        setExpand(isExpanded, for: folder)
        adapter?.performSectionUpdate(forSectionObject: self)
    }
    
    func setExpand(_ isExpanded: Bool, for folder: TodoFolder) {
        todo.setExpand(isExpanded, for: folder)
    }
    
    func isExpandedFolder(_ folder: TodoFolder) -> Bool {
        return todo.isExpanded(folder)
    }
}

// MARK: - 列表排序
extension TodoFolderListSectionController: TPTableDragInsertReorderDelegate {
    
    func tableDragReorder(_ reorder: TPTableDragReorder, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == section
    }
    
    func tableDragReorder(_ reorder: TPTableDragReorder, willBeginAt indexPath: IndexPath) {
        guard let folder = item(at: indexPath.item) as? TodoFolder, folder.hasLists else {
            return
        }
        
        /// 收起展开的目录
        guard todo.isExpanded(folder), todo.setExpand(false, for: folder) else {
            return
        }
        
        /// 更新单元格
        if let cell = cellForRow(at: indexPath.row) as? TodoFolderHomeCell {
            cell.setExpanded(false, animated: false)
        }
        
        /// 更新列表
        adapter?.performUpdate(with: .fade)
    }
    
    func tableDragReorderDidEnd(_ reorder: TPTableDragReorder) {
        /// 无操作
    }

    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, indentationLevelTo targetIndexPath: IndexPath, from sourceIndexPath: IndexPath, ratio: CGFloat) -> Int {
        return currentItems.indentationLevel(to: targetIndexPath.row, from: sourceIndexPath.row, ratio: ratio)
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder,
                                focusIndexPathTo targetIndexPath: IndexPath,
                                from sourceIndexPath: IndexPath,
                                depth: Int) -> IndexPath? {
        guard let index = currentItems.focusIndex(to: targetIndexPath.row, from: sourceIndexPath.row, depth: depth) else {
            return nil
        }

        return IndexPath(row: index, section: targetIndexPath.section)
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, canInsertRowTo targetIndexPath: IndexPath, from sourceIndexPath: IndexPath) -> Bool {
        guard sourceIndexPath.section == targetIndexPath.section else {
            return false
        }
        
        return currentItems.canInsertItem(at: sourceIndexPath.row, to: targetIndexPath.row)
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder,
                                canFlashRowAt indexPath: IndexPath,
                                from sourceIndexPath: IndexPath) -> Bool {
        guard currentItems.elementType(at: sourceIndexPath.item) == .list else {
            return false
        }
        
        guard let folder = item(at: indexPath.item) as? TodoFolder, folder.hasLists else {
            return false
        }
        
        if todo.isExpanded(folder) {
            return false
        }

        return currentItems.canMoveItem(at: sourceIndexPath.row, intoItemAt: indexPath.row)
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, didFlashRowAt indexPath: IndexPath, from sourceIndexPath: IndexPath) {
        guard let flashFolder = item(at: indexPath.row) as? TodoFolder,
              todo.setExpand(true, for: flashFolder),
              let draggingItem = item(at: sourceIndexPath.row) as? ListDiffable else {
            return
        }
        
        adapter?.reloadCell(at: indexPath)
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .fade)
        if let draggingIndexPath = adapter?.indexPath(of: draggingItem) {
            reorder.changeDraggingIndexPath(draggingIndexPath)
        }
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder,
                                inserRowTo targetIndexPath: IndexPath,
                                from sourceIndexPath: IndexPath,
                                depth: Int) -> IndexPath? {
        guard let items = adapter?.items(for: self), let item = adapter?.item(at: sourceIndexPath) else {
            return sourceIndexPath
        }
        
        if sourceIndexPath.row == targetIndexPath.row, items.depthForItem(at: sourceIndexPath.row) == depth {
            /// 行和深度都相同则不做处理
            return sourceIndexPath
        }
        
        if item is TodoFolder {
            todo.reorderFolder(in: items, fromIndex: sourceIndexPath.row, toIndex: targetIndexPath.row)
        } else {
            todo.reorderList(in: items, fromIndex: sourceIndexPath.row, toIndex: targetIndexPath.row, depth: depth)
        }
        
        /// 更新列表
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .none)
        if let newIndexPath = adapter?.indexPath(of: item) {
            return newIndexPath
        }
        
        return nil
    }
}
