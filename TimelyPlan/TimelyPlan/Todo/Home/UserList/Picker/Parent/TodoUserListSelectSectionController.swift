//
//  TodoUserListSelectSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/15.
//

import Foundation

class TodoUserListSelectSectionController: TodoUserListBaseSectionController {
    
    var userListDidChange: (() -> Void)?
    
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
    
    private let viewModel: TodoUserListViewModel
    
    init(allowMaxDepth: Int = kTodoListMaxDepth) {
        self.allowMaxDepth = allowMaxDepth
        let expansionState = TodoParentListSelectExpansionState(allowMaxDepth: allowMaxDepth)
        self.expansionState = expansionState
        self.viewModel = TodoUserListViewModel(expansionState: expansionState)
        super.init()
        self.viewModel.userListDidChange = { [weak self] change in
            self?.userListChanged(change)
            self?.userListDidChange?()
        }

        self.viewModel.loadTopLists()
    }
    
    private func userListChanged(_ change: TodoUserListChange? = nil) {
        var rowAnimation: UITableView.RowAnimation = .none
        if change != nil {
            rowAnimation = .top
        }
        
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: rowAnimation)
    }
    
    private func updateUserList() {
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
    }

    // MARK: - Delegate
    override var items: [ListDiffable]? {
        return self.viewModel.lists()
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
