//
//  FocusTimerSearchResultBaseSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/5.
//

import Foundation

class FocusTimerSearchResultSectionController: FocusUserTimerSelectSectionController,
                                               UISearchResultsUpdating {
    
    /// 当前结果对应的搜索文本
    private var searchText: String?
    
    /// 当前搜索结果列表
    private var searchResults: [FocusTimer]?
    
    override var items: [ListDiffable]? {
        return searchResults
    }
 
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        updateSearchResults(with: searchController.searchBar.text)
    }
    
    func updateSearchResults(with searchText: String?) {
        let searchText = searchText?.whitespacesAndNewlinesTrimmedString
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
        focus.searchActiveTimers(containText: searchText) { timers in
            guard searchText == self.searchText else {
                return
            }
            
            self.searchResults = timers
            self.adapter?.performUpdate()
        }
    }
}

