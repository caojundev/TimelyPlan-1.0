//
//  TodoParentListResultSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/9.
//

import Foundation

class TodoListSearchResultsSectionController: TPTableBaseSectionController,
                                                UISearchResultsUpdating {
    
    var didSelectList: ((TodoList?) -> Void)?
    
    /// 当前选中列表
    var selectedList: TodoList?
    
    /// 当前结果对应的搜索文本
    private var searchText: String?
    
    /// 当前搜索结果列表
    private var searchResults: [TodoList]?
    
    override var items: [ListDiffable]? {
        return searchResults
    }
    
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
        return TodoListSearchResultCell.self
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        super.didDequeCell(cell, forRowAt: index)
        let cell = cell as! TodoListSearchResultCell
        cell.list = item(at: index) as? TodoList
    }

    override func didSelectRow(at index: Int) {
        let list = item(at: index) as! TodoList
        self.didSelectList?(list)
    }
    
    override func shouldShowCheckmarkForRow(at index: Int) -> Bool {
        let list = item(at: index) as! TodoList
        return self.selectedList == list
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text?.whitespacesAndNewlinesTrimmedString
        if self.searchText == searchText {
            return
        }
        
        guard let searchText = searchText, searchText.count > 0 else {
            self.searchText = nil
            self.searchResults = nil
            self.adapter?.performUpdate()
            return
        }

        self.searchText = searchText
        todo.fetchLists(containText: searchText) { lists in
            guard searchText == self.searchText else {
                return
            }

            self.searchResults = lists
            self.adapter?.performUpdate(with: .top, completion: nil)
        }
    }
}

class TodoListSearchResultCell: TodoListSelectCell {

    override var list: TodoList? {
        didSet {
            self.depth = 0 /// 深度固定为0
            self.setNeedsLayout()
        }
    }
}
