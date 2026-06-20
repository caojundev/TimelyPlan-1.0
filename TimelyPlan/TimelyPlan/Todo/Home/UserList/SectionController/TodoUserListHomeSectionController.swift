//
//  TodoUserListHomeSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/3.
//

import Foundation

class TodoUserListHomeSectionController: TodoUserListBaseSectionController,
                                         TodoUserListHomeCellDelegate {
    
    /// 头区块控制器
    lazy var headerSectionController: TodoHomeHeaderSectionController = { [weak self] in
        let sectionController = TodoHomeHeaderSectionController(sectionType: .list)
        sectionController.didClickAdd = {
            self?.createList()
        }
        
        sectionController.didToggleExpanded = { isExpanded in
            self?.setExpanded(isExpanded)
        }
        
        return sectionController
    }()

    /// 列表管理器
    private var listController = TodoUserListController()
    
    private let viewModel: TodoHomeUserListViewModel

    init(viewModel: TodoHomeUserListViewModel) {
        self.viewModel = viewModel
        super.init()
        self.headerSectionController.setExpanded(self.viewModel.isExpanded)
        self.viewModel.userListDidChange = { [weak self] change in
            self?.userListChanged(change)
        }
        
        self.viewModel.countDidChange = { [weak self] lists in
            self?.updateTaskCount(for: lists)
        }
    }
    
    private func userListChanged(_ change: TodoUserListChange? = nil) {
        DispatchQueue.main.async {
            let rowAnimation: UITableView.RowAnimation = .top
            self.adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: rowAnimation)
            guard let change = change else {
                return
            }
        
            var list: TodoList?
            switch change {
            case .create(let todoList):
                if !self.viewModel.isExpanded {
                    self.setExpanded(true)
                    self.headerSectionController.setExpanded(true)
                }
                
                list = todoList
            case .update(let todoList):
                list = todoList
            }
            
            if let list = list {
                self.adapter?.revealItemAutoScrollIfNeeded(list, at: .middle)
            }
        }
    }

    /// 更新列表任务数目
    func updateTaskCount(for lists: [TodoListFeature]) {
        for list in lists {
            let diffIdentifier = list.identifier as NSString
            let cell = adapter?.cellForItem(with: diffIdentifier, inSection: self)
            if let cell = cell as? TodoUserListHomeCell {
                cell.updateTaskCount()
            }
        }
    }
    
    func setExpanded(_ isExpanded: Bool) {
        guard viewModel.isExpanded != isExpanded else {
            return
        }
        
        viewModel.isExpanded = isExpanded
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
    }
    
    func createList() {
        listController.createList(parent: nil)
    }
    
    // MARK: - Delegate
    override var items: [ListDiffable]? {
        guard self.viewModel.isExpanded else {
            return nil
        }

        return viewModel.lists()
    }
    
    // MARK: - Delegate
    override func heightForHeader() -> CGFloat {
        return 0.0
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
 
    func todoUserListHomeCellDidClickMore(_ cell: TodoUserListHomeCell) {
        guard let list = cell.list else { return }
        let actionController = TodoListMenuActionController(list: list)
        actionController.didSelectMenuActionType = { type in
            self.performMenuActionType(type, for: list)
        }
        
        actionController.showMenu(from: cell.moreButton)
    }
    
    func todoUserListHomeCell(_ cell: TodoUserListHomeCell, requestCount completion: @escaping (Int?) -> Void) {
        guard let list = cell.list else {
            completion(nil)
            return
        }
        
        viewModel.fetchUncompletedTaskCount(for: list, completion: completion)
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
        guard list.hasSubItem, viewModel.isExpanded(list) else {
            return
        }
        
        viewModel.setExpended(false, for: list)
        
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
        
        TodoRepository.reorderList(in: lists, fromIndex: sourceIndexPath.row, toIndex: targetIndexPath.row, depth: depth)
        /// 重新排序完成返回新索引
        var newIndexPath: IndexPath? = nil
        if let newIndex = lists.indexOf(list) {
            newIndexPath = IndexPath(row: newIndex, section: targetIndexPath.section)
        }

        return newIndexPath
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, canFlashRowAt indexPath: IndexPath, from sourceIndexPath: IndexPath) -> Bool {
        let list = list(at: indexPath.row)
        guard !viewModel.isExpanded(list), list.hasSubItem else {
            return false
        }

        /// 判断是否可以移进目标清单
        return lists.canMoveItem(at: sourceIndexPath.row, intoItemAt: indexPath.row)
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, didFlashRowAt indexPath: IndexPath, from sourceIndexPath: IndexPath) {
        let fromList = list(at: sourceIndexPath.row)
        let touchList = list(at: indexPath.row)
        guard !viewModel.isExpanded(touchList) else {
            return
        }
        
        viewModel.setExpended(true, for: touchList)
        
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
