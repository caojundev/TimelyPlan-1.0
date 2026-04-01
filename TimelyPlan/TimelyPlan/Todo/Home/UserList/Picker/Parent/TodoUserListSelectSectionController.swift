//
//  TodoUserListSelectSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/15.
//

import Foundation

class TodoUserListSelectSectionController: TodoUserListBaseSectionController {
    
    /// 允许的最大列表深度
    let allowMaxDepth: Int
    
    /// 禁止选择列表数组
    var disabledLists: [TodoList]? {
        get {
            return expansionState.disabledLists
        }
        
        set {
            expansionState.disabledLists = newValue
        }
    }
    
    private let expansionState: TodoParentListSelectExpansionState
    
    init(allowMaxDepth: Int = kTodoListMaxDepth) {
        self.allowMaxDepth = allowMaxDepth
        self.expansionState = TodoParentListSelectExpansionState(allowMaxDepth: allowMaxDepth)
        super.init()
    }

    // MARK: - Delegate
    override var items: [ListDiffable]? {
        return TodoUserListOrganizer.shared.userLists(with: expansionState)
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
        return TodoUserListSelectCell.self
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        super.didDequeCell(cell, forRowAt: index)
        let cell = cell as! TodoUserListSelectCell
        let list = list(at: index)
        cell.isDisabled = expansionState.isDisabledList(list)
    }

    override func shouldHighlightRow(at index: Int) -> Bool {
        let list = item(at: index) as! TodoList
        return !expansionState.isDisabledList(list)
    }
    
    // MARK: - TPExpandDefaultInfoTableCellDelegate
    override func expandTableCell(_ cell: TPExpandDefaultInfoTableCell, canToggleExpandStateTo isExpanded: Bool) -> Bool {
        guard let cell = cell as? TodoUserListSelectCell, let list = cell.list else {
            return false
        }
        
        return expansionState.canSetExpended(isExpanded, for: list)
    }
    
    override func isExpandedTableCell(_ cell: TPExpandDefaultInfoTableCell) -> Bool {
        guard let cell = cell as? TodoUserListSelectCell, let list = cell.list else {
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
}

class TodoParentListSelectExpansionState: ExpansionStateProviding {
    
    /// 允许的最大列表深度
    let allowMaxDepth: Int
    
    /// 禁止选择列表数组
    var disabledLists: [TodoList]?
    
    private var collapsedLists = Set<TodoList>()
    
    init(allowMaxDepth: Int) {
        self.allowMaxDepth = allowMaxDepth
    }
    
    func canSetExpended(_ isExpended: Bool, for item: Nestable) -> Bool {
        let list = item as! TodoList
        return list.depth < allowMaxDepth
    }

    func isExpanded(_ item: Nestable) -> Bool {
        let list = item as! TodoList
        if list.depth >= allowMaxDepth || collapsedLists.contains(list) {
            return false
        }
        
        guard let disabledLists = disabledLists else {
            return true
        }
        
        return !disabledLists.contains(list)
    }
    
    func setExpended(_ isExpended: Bool, for item: Nestable) {
        let list = item as! TodoList
        if isExpended {
            collapsedLists.remove(list)
        } else {
            collapsedLists.insert(list)
        }
    }
    
    /// 是否为禁用列表
    func isDisabledList(_ list: TodoList) -> Bool {
        if list.depth > allowMaxDepth {
            return true
        }
        
        if let disabledLists = disabledLists {
            return disabledLists.contains(list)
        }
        
        return false
    }
    
}
