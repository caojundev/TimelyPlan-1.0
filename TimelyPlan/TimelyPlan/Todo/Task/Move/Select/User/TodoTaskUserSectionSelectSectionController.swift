//
//  TodoTaskUserSectionSelectSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/5.
//

import Foundation
import UIKit

class TodoTaskUserSectionSelectSectionController: TPTableBaseSectionController,
                                              TodoTaskMoveUserListCellDelegate,
                                              TPExpandDefaultInfoTableCellDelegate {

    var lists: [TodoList] = []
    
    private let expansionState: TodoParentListSelectExpansionState
    
    let viewModel: TodoTaskSectionViewModel
    
    private var selection: TodoTaskSectionSelection {
        return viewModel.selection
    }
    
    init(viewModel: TodoTaskSectionViewModel) {
        self.viewModel = viewModel
        self.expansionState = TodoParentListSelectExpansionState(allowMaxDepth: kTodoListMaxDepth)
        super.init()
        self.updateLists()
    }
    
    private func updateLists() {
        guard let topLists = viewModel.topLists else {
            self.lists = []
            return
        }
        
        let lists = topLists.flattenItems(with: expansionState) as? [TodoList]
        self.lists = lists ?? []
    }
    
    override var items: [ListDiffable]? {
        var items = [ListDiffable]()
        for list in lists {
            items.append(list)
            if selection.isSectionExpanded(for: list), expansionState.isExpanded(list) {
                items.append(contentsOf: list.allSections)
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
        
        var isExpanded = false
        if expansionState.isExpanded(list), selection.isSectionExpanded(for: list) {
           isExpanded = true
        }
        
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
        let item = item(at: index)
        if let list = item as? TodoList {
            selectList(list)
        } else if let section = item as? TodoSection {
            selectSection(section)
        }
    }

    override func shouldHighlightRow(at index: Int) -> Bool {
        if let list = item(at: index) as? TodoList {
            return !expansionState.isDisabledList(list)
        }
        
        return true
    }
    
    override func shouldShowCheckmarkForRow(at index: Int) -> Bool {
        let item = item(at: index)
        if let list = item as? TodoList {
            return selection.isSelectedList(list)
        } else if let section = item as? TodoSection {
            return selection.isSelectedSection(section)
        }
        
        return false
    }

    private func selectList(_ list: TodoList) {
        guard let sections = list.sections, sections.count > 0 else {
            /// 直接选中列表的无板块
            selectSection(.none(for: list))
            return
        }
                
        if selection.isSectionExpanded(for: list) {
            selection.setSectionExpanded(false, for: list)
        } else {
            selection.setSectionExpanded(true, for: list)
            
            if !expansionState.isExpanded(list) {
                expansionState.setExpended(true, for: list)
                updateLists()
            }
        }

        adapter?.updateCheckmarks()
        adapter?.performUpdate()
    }
    
    private func selectSection(_ section: TodoSection) {
        selection.selectSection(section)
        adapter?.updateCheckmarks()
        adapter?.performUpdate()
    }
    
    // MARK: - TodoTaskMoveUserListCellDelegate
    func taskMoveUserListCell(_ cell: TodoTaskMoveUserListCell, didToggleSectionExpand isExpanded: Bool) {
        if let list = cell.list {
            selection.setSectionExpanded(isExpanded, for: list)
        }
        
        adapter?.performUpdate()
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
