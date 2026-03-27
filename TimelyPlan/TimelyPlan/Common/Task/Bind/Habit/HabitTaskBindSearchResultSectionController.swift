//
//  HabitTaskBindSearchResultSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/27.
//

import Foundation
import UIKit

class HabitTaskBindSearchResultSectionController: HabitTaskBindSectionController,
                                                  UISearchResultsUpdating {
    
    /// 当前结果对应的搜索文本
    private(set) var searchText: String?
    
    override func didDequeCell(_ cell: UICollectionViewCell, forItemAt index: Int) {
        super.didDequeCell(cell, forItemAt: index)
        if let searchCell = cell as? HabitTaskBindCell {
            searchCell.setHighlightedText(self.searchText)
        }
    }
    
    /// 更新可见 cell 搜索文本
    private func updateSearchTextForVisibleCells() {
        guard let cells = adapter?.visibleCells(forSectionObject: self) as? [HabitTaskBindCell] else {
            return
        }
        
        for cell in cells {
            cell.setHighlightedText(self.searchText)
        }
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
            self.tasks = nil
            self.adapter?.performUpdate()
            self.updateSearchTextForVisibleCells()
            return
        }

        self.searchText = searchText
        habit.searchActiveTasks(containText: searchText) { tasks in
            guard searchText == self.searchText else {
                return
            }
            
            self.tasks = tasks
            self.adapter?.performUpdate()
            self.updateSearchTextForVisibleCells()
        }
    }
}

