//
//  TodoTaskSectionSelectSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/5.
//

import Foundation
import UIKit

class TodoTaskSectionSelectSectionController: TPTableBaseSectionController,
                                              TodoTaskMoveUserListCellDelegate,
                                              TPExpandDefaultInfoTableCellDelegate {
    
    private let expansionState: TodoParentListSelectExpansionState
    
    private let viewModel: TodoUserListViewModel
    
    var lists: [TodoList] = []
    
    var expandedSectionList: TodoList?
    
    override init() {
        let expansionState = TodoParentListSelectExpansionState(allowMaxDepth: kTodoListMaxDepth)
        self.expansionState = expansionState
        self.viewModel = TodoUserListViewModel(expansionState: expansionState)
        super.init()
        self.viewModel.userListDidChange = { [weak self] change in
            self?.userListChanged(change)
        }

        self.viewModel.loadTopLists()
    }
    
    private func updateLists() {
        self.lists = self.viewModel.lists()
    }
    
    private func userListChanged(_ change: TodoUserListChange? = nil) {
        DispatchQueue.main.async {
            var rowAnimation: UITableView.RowAnimation = .none
            if change != nil {
                rowAnimation = .top
            }
            
            self.updateLists()
            self.adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: rowAnimation)
        }
    }
    
    override var items: [ListDiffable]? {
        var items = [ListDiffable]()
        for list in lists {
            items.append(list)
            if list == expandedSectionList, let sections = list.sections {
                items.append(contentsOf: sections)
            }
        }
    
        return items
    }

    override func heightForHeader() -> CGFloat {
        return 0.0
    }
    
    override func heightForFooter() -> CGFloat {
        return 0.0
    }
    
    override func heightForRow(at index: Int) -> CGFloat {
        return 50.0
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        let item = item(at: index)
        if item is TodoList {
            return TodoTaskMoveUserListCell.self
        }
        
        return TodoTaskMoveSectionCell.self
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        if let cell = cell as? TodoTaskMoveUserListCell {
            didDequeListCell(cell, forRowAt: index)
        } else if let cell = cell as? TodoTaskMoveSectionCell {
            didDequeSectionCell(cell, forRowAt: index)
        }
    }

    private func didDequeListCell(_ cell: TodoTaskMoveUserListCell, forRowAt index: Int) {
        guard let list = item(at: index) as? TodoList else {
            return
        }

        cell.delegate = self
        cell.style = styleForRow(at: index)
        cell.list = list
        cell.isDisabled = expansionState.isDisabledList(list)
        cell.depthLineLevels = TodoList.depthLineLevels(for: list, in: lists)
        
        let isExpanded = list == expandedSectionList
        cell.setSectionExpanded(isExpanded, animated: true)
    }
    
    private func didDequeSectionCell(_ cell: TodoTaskMoveSectionCell, forRowAt index: Int) {
        guard let section = item(at: index) as? TodoSection else {
            return
        }

        if let list = section.list {
            cell.depthLineLevels = sectionDepthLineLevels(for: list, in: lists)
        }
        
        cell.section = section
    }
    
    override func didSelectRow(at index: Int) {
        TPImpactFeedback.impactWithSoftStyle()
        if let list = item(at: index) as? TodoList {
            selectList(list)
        }
    }

    override func shouldHighlightRow(at index: Int) -> Bool {
        if let list = item(at: index) as? TodoList {
            return !expansionState.isDisabledList(list)
        }
        
        return true
    }
    
    private func selectList(_ list: TodoList) {
        if expandedSectionList == list {
            expandedSectionList = nil
        } else {
            expandedSectionList = list
            if !expansionState.isExpanded(list) {
                expansionState.setExpended(true, for: list)
                updateLists()
            }
        }
        
        adapter?.performUpdate()
    }
    
    // MARK: - TodoTaskMoveUserListCellDelegate
    func taskMoveUserListCell(_ cell: TodoTaskMoveUserListCell, didToggleSectionExpand isExpanded: Bool) {
        guard let list = cell.list else {
            return
        }
        
        selectList(list)
    }
    
    // MARK: - TPExpandDefaultInfoTableCellDelegate
    func expandTableCell(_ cell: TPExpandDefaultInfoTableCell, canToggleExpandStateTo isExpanded: Bool) -> Bool {
        guard let cell = cell as? TodoTaskMoveUserListCell, let list = cell.list else {
            return false
        }
        
        return expansionState.canSetExpended(isExpanded, for: list)
    }
    
    func isExpandedTableCell(_ cell: TPExpandDefaultInfoTableCell) -> Bool {
        guard let cell = cell as? TodoTaskMoveUserListCell, let list = cell.list else {
            return false
        }
        
        return expansionState.isExpanded(list)
    }
    
    func expandTableCell(_ cell: TPExpandDefaultInfoTableCell, didToggleExpand isExpanded: Bool) {
        guard let cell = cell as? TodoUserListBaseCell, let list = cell.list else {
            return
        }
        
        expansionState.setExpended(isExpanded, for: list)
        updateLists()
        adapter?.performUpdate()
    }
    
    // MARK: - Helpers
    private func sectionDepthLineLevels(for item: TodoList, in items: [TodoList]) -> [Int]? {
        guard let index = items.firstIndex(of: item) else {
            return nil
        }
    
        let fromIndex = index + 1
        guard fromIndex < items.count else {
            return nil
        }
        
        let currentDepth = item.depth
        var depths = [Int]()
        var minDepth = Int.max
        for i in fromIndex..<items.count {
            let depth = items[i].depth
            if depth == 0 {
                /// 检查到下一个根列表，跳出循环
                break
            }

            if depth > currentDepth {
                depths.append(depth)
                /// 深度大于当前深度，检查下一个列表
                continue
            }
            
            if depth <= minDepth {
                depths.append(depth)
                minDepth = depth
            }
        }
        
        return depths
    }
}
