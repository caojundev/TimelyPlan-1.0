//
//  TodoTagSearchResultsSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/9.
//

import Foundation


class TodoTagSearchResultsSectionController: TodoTagSelectSectionController,
                                                UISearchResultsUpdating {

    /// 当前结果对应的搜索文本
    private var searchText: String?
    
    /// 当前搜索结果列表
    private var searchResults: [TodoTag]?
    
    override var items: [ListDiffable]? {
        return searchResults
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
        todo.searchTags(containText: searchText) { tags in
            guard searchText == self.searchText else {
                return
            }

            self.searchResults = tags
            self.adapter?.performUpdate(with: .top, completion: nil)
        }
    }
}
