//
//  TodoUserListHomeSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/3.
//

import Foundation

class TodoUserListHomeSectionController: TodoUserListBaseSectionController,
                                         TodoUserListHomeCellDelegate {
    
    /// 列表管理器
    private var listController = TodoUserListController()
    
    private let expansionState = TodoHomeUserListExpansionState()
    
    override init() {
        super.init()
        todo.addUpdater(self)
    }
    
    // MARK: - Delegate
    override var items: [ListDiffable]? {
        return TodoUserListOrganizer.shared.userLists(with: expansionState)
    }
    
    // MARK: - Delegate
    override func classForCell(at index: Int) -> AnyClass? {
        return TodoUserListHomeCell.self
    }

    // MARK: - TodoUserListHomeCellDelegate
    override func isExpandedTableCell(_ cell: TPExpandDefaultInfoTableCell) -> Bool {
        guard let cell = cell as? TodoUserListBaseCell, let list = cell.list else {
            return false
        }
        
        return expansionState.isExpanded(list)
    }
    
    override func expandTableCell(_ cell: TPExpandDefaultInfoTableCell, didToggleExpand isExpanded: Bool) {
        guard let cell = cell as? TodoUserListBaseCell, let list = cell.list else {
            return
        }
        
        expansionState.setExpended(isExpanded, for: list)
        adapter?.performUpdate()
    }
 
    func TodoUserListHomeCellDidClickMore(_ cell: TodoUserListHomeCell) {
        guard let list = cell.list else { return }
        let actionController = TodoListMenuActionController(list: list)
        actionController.didSelectMenuActionType = { type in
            self.performMenuActionType(type, for: list)
        }
        
        actionController.showMenu(from: cell.moreButton)
    }
    
    // MARK: - Menu Action
    func performMenuActionType(_ type: TodoListMenuActionType, for list: TodoList) {
        switch type {
        case .addSublist:
            listController.createList(parent: list)
        case .ungroup:
            listController.ungroupList(list)
        case .move:
            listController.moveList(list)
        case .edit:
            listController.editList(list)
        case .delete:
            listController.deleteList(list)
        }
    }
}

extension TodoUserListHomeSectionController: TodoListProcessorDelegate {
    
    /// 添加新组时通知
    func didCreateTodoList(_ list: TodoList) {
        expansionState.expandAllParentList(of: list)
        adapter?.reloadData()
    }
    
    /// 更新列表信息通知
    func didUpdateTodoList(_ list: TodoList) {
        adapter?.reloadData()
    }
    
    /// 删除列表时通知
    func didDeleteTodoLists(_ lists: [TodoList]) {
        adapter?.reloadData()
    }
    
    /// 列表移动通知， parent为nil时表示移动到根目录
    func didMoveTodoLists(_ lists: [TodoList], from sourceParent: TodoList?) {
        for list in lists {
            expansionState.expandAllParentList(of: list)
        }
        
        adapter?.reloadData()
    }
    
    /// 重新列表排序
    func didReorderTodoList(_ list: TodoList) {
        adapter?.reloadData()
    }
}

// MARK: - 列表排序
extension TodoUserListHomeSectionController: TPTableDragInsertReorderDelegate {
    
    func tableDragReorder(_ reorder: TPTableDragReorder, canMoveRowAt indexPath: IndexPath) -> Bool {
        /// 仅在当前区块可移动
        return indexPath.section == self.section
    }
    
    func tableDragReorder(_ reorder: TPTableDragReorder, willBeginAt indexPath: IndexPath) {
        /// 收起已展开的列表
        let list = list(at: indexPath.row)
        guard list.hasSubItem, self.expansionState.isExpanded(list) else {
            return
        }
        
        self.expansionState.setExpended(false, for: list)
        updateExpandedForCell(at: indexPath, animated: false)
        
        /// 更新列表
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .fade)
    }
    
    func tableDragReorderDidEnd(_ reorder: TPTableDragReorder) {
        /// 无操作
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, indentationLevelTo targetIndexPath: IndexPath, from sourceIndexPath: IndexPath, ratio: CGFloat) -> Int {
        return lists.indentationLevel(to: targetIndexPath.row,
                                      from: sourceIndexPath.row,
                                      ratio: ratio)
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, focusIndexPathTo targetIndexPath: IndexPath, from sourceIndexPath: IndexPath, depth: Int) -> IndexPath? {
        guard let index = lists.focusIndex(to: targetIndexPath.row,
                                           from: sourceIndexPath.row,
                                           depth: depth) else {
            return nil
        }

        return IndexPath(row: index, section: targetIndexPath.section)
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, canInsertRowTo targetIndexPath: IndexPath, from sourceIndexPath: IndexPath) -> Bool {
        guard sourceIndexPath.section == targetIndexPath.section else {
            return false
        }
        
        return lists.canInsertItem(at: sourceIndexPath.row, to: targetIndexPath.row)
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder,
                                inserRowTo targetIndexPath: IndexPath,
                                from sourceIndexPath: IndexPath,
                                depth: Int) -> IndexPath? {
        let list = list(at: sourceIndexPath.row)
        if sourceIndexPath.row == targetIndexPath.row, list.depth == depth {
            /// 行和深度都相同则不做处理
            return sourceIndexPath
        }
        
        /// 旧父清单
        let fromParentList = list.parent
        
        #warning("执行排序操作")
        /// 执行排序操作
//        todo.reorderList(in: lists, fromIndex: sourceIndexPath.row, toIndex: targetIndexPath.row, depth: depth)
        
        /// 更新列表
        adapter?.performSectionUpdate(forSectionObject: self)
        
        /// 更新影响列表的单元格
        let affectedLists = TodoList.affectedItems(for: list, fromParent: fromParentList)
        adapter?.reloadCell(forItems: affectedLists, with: .none)
        
        /// 更新深度线条层级
        updateVisibleDepthLineLevels()
        
        /// 重新排序完成返回新索引
        var newIndexPath: IndexPath? = nil
        if let newIndex = lists.indexOf(list) {
            newIndexPath = IndexPath(row: newIndex, section: targetIndexPath.section)
        }

        return newIndexPath
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, canFlashRowAt indexPath: IndexPath, from sourceIndexPath: IndexPath) -> Bool {
        let list = list(at: indexPath.row)
        guard !expansionState.isExpanded(list), list.hasSubItem else {
            return false
        }

        /// 判断是否可以移进目标清单
        return lists.canMoveItem(at: sourceIndexPath.row, intoItemAt: indexPath.row)
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, didFlashRowAt indexPath: IndexPath, from sourceIndexPath: IndexPath) {
        let fromList = list(at: sourceIndexPath.row)
        let touchList = list(at: indexPath.row)
        guard !expansionState.isExpanded(touchList) else {
            return
        }
        
        expansionState.setExpended(true, for: touchList)
        updateExpandedForCell(at: indexPath, animated: true)

        /// 更新列表
        adapter?.performSectionUpdate(forSectionObject: self)
        
        /// 更新当前拖动索引
        var indexPath: IndexPath? = nil
        if let newIndex = lists.indexOf(fromList) {
            indexPath = IndexPath(row: newIndex, section: section)
        }
        
        reorder.changeDraggingIndexPath(indexPath)
    }
    
    /// 更新单元格展开状态
    private func updateExpandedForCell(at indexPath: IndexPath, animated: Bool) {
        if let cell = adapter?.cellForRow(at: indexPath) as? TodoUserListHomeCell {
            cell.updateExpanded(animated: animated)
        }
    }
}
