//
//  TodoUserListHomeSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/3.
//

import Foundation

class TodoUserListHomeSectionController: TodoUserListBaseSectionController,
                                         TodoUserListHomeCellDelegate,
                                         TodoHomeExpandHeaderViewDelegate {
    var isExpanded: Bool = true
    
    /// 列表管理器
    private var listController = TodoUserListController()
    
    private let expansionState: TodoHomeUserListExpansionState
    
    private let viewModel: TodoHomeUserListViewModel
    
    override init() {
        let expansionState = TodoHomeUserListExpansionState()
        self.expansionState = expansionState
        self.viewModel = TodoHomeUserListViewModel(expansionState: expansionState)
        super.init()
        self.viewModel.userListDidChange = { [weak self] in
            self?.userListDidChange()
        }
    }
    
    private func userListDidChange() {
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
    }
    
    // MARK: - Delegate
    override var items: [ListDiffable]? {
        guard isExpanded else {
            return nil
        }

        return viewModel.lists()
    }
    
    // MARK: - Delegate
    override func heightForHeader() -> CGFloat {
        return 50.0
    }
    
    override func classForHeader() -> AnyClass? {
        return TodoHomeExpandHeaderView.self
    }
    
    override func didDequeHeader(_ headerView: UITableViewHeaderFooterView) {
        guard let headerView = headerView as? TodoHomeExpandHeaderView else {
            return
        }
        
        headerView.contentView.backgroundColor = adapter?.cellStyle.backgroundColor
        headerView.delegate = self
        headerView.isExpanded = isExpanded
        headerView.titleConfig.font = BOLD_SYSTEM_FONT
        headerView.title = resGetString("Lists")
        headerView.imageContent = .withName("todo_list_24")
        headerView.imageConfig.color = .primary
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return TodoUserListHomeCell.self
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        super.didDequeCell(cell, forRowAt: index)
        if let cell = cell as? TodoUserListBaseCell {
            cell.contentPadding = UIEdgeInsets(left: 16.0, right: 12.0)
        }
    }

    // MARK: - TodoHomeExpandHeaderViewDelegate
    func todoHomeExpandHeaderViewDidClickAdd(_ headerView: TodoHomeExpandHeaderView) {
        listController.createList(parent: nil)
    }
    
    func todoHomeExpandHeaderView(_ headerView: TodoHomeExpandHeaderView, didToggleExpand isExpanded: Bool) {
        self.isExpanded = isExpanded
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
    }
    
    // MARK: - TodoUserListHomeCellDelegate
    override func isExpandedTableCell(_ cell: TPExpandDefaultInfoTableCell) -> Bool {
        guard let cell = cell as? TodoUserListBaseCell, let list = cell.list else {
            return false
        }
        
        return viewModel.isExpanded(list)
    }
    
    override func expandTableCell(_ cell: TPExpandDefaultInfoTableCell, didToggleExpand isExpanded: Bool) {
        guard let cell = cell as? TodoUserListBaseCell, let list = cell.list else {
            return
        }
        
        viewModel.setExpended(isExpanded, for: list)
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
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

// MARK: - 列表排序
extension TodoUserListHomeSectionController: TPTableDragInsertReorderDelegate {
    
    func tableDragReorder(_ reorder: TPTableDragReorder, canMoveRowAt indexPath: IndexPath) -> Bool {
        /// 仅在当前区块可移动
        return indexPath.section == self.section
    }
    
    func tableDragReorder(_ reorder: TPTableDragReorder, willBeginAt indexPath: IndexPath) {
        /// 收起已展开的列表
        let list = list(at: indexPath.row)
        guard list.hasSubItem, expansionState.isExpanded(list) else {
            return
        }
        
        expansionState.setExpended(false, for: list)
        
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
        
        todo.reorderList(in: lists, fromIndex: sourceIndexPath.row, toIndex: targetIndexPath.row, depth: depth)
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
        
        /// 更新列表
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
        
        /// 更新当前拖动索引
        var indexPath: IndexPath? = nil
        if let newIndex = lists.indexOf(fromList) {
            indexPath = IndexPath(row: newIndex, section: section)
        }
        
        reorder.changeDraggingIndexPath(indexPath)
    }
}
