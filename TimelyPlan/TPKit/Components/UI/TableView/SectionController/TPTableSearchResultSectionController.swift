//
//  TPTableSearchResultSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/1.
//

import Foundation
import UIKit

class TPTableSearchResultSectionController: TPTableBaseSectionController,
                                                UISearchResultsUpdating {
    
    
    var normalHeaderHeight = 40.0
    
    var headerPadding = UIEdgeInsets(top: 10, left: 6.0, bottom: 0.0, right: 6.0)
    
    /// 当前结果对应的搜索文本
    private(set) var searchText: String?
    
    /// 当前搜索结果
    private(set) var searchResults: [ListDiffable]?
    
    var hasResult: Bool {
        if let searchResults = searchResults, searchResults.count > 0 {
            return true
        }
        
        return false
    }
    
    lazy var cellStyle: TPTableCellStyle = {
        let style = TPTableCellStyle()
        style.backgroundColor = .secondarySystemGroupedBackground
        style.selectedBackgroundColor = .tertiarySystemFill
        return style
    }()

    override init() {
        super.init()
    }
    
    override var items: [ListDiffable]? {
        return searchResults
    }
    
    override func heightForRow(at index: Int) -> CGFloat {
        return 55.0
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return TPBaseTableCell.self
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        super.didDequeCell(cell, forRowAt: index)
        highlightSearchText(for: cell)
    }
    
    override func didSelectRow(at index: Int) {
        TPImpactFeedback.impactWithSoftStyle()
        delegate?.tableSectionController(self, didSelectRowAt: index)
    }
    
    override func styleForRow(at index: Int) -> TPTableCellStyle? {
        return cellStyle
    }

    override func heightForHeader() -> CGFloat {
        return hasResult ? normalHeaderHeight : 0.0
    }
    
    override func classForHeader() -> AnyClass? {
        return TPDefaultInfoTableHeaderFooterView.self
    }
    
    override func didDequeHeader(_ headerView: UITableViewHeaderFooterView) {
        super.didDequeHeader(headerView)
        guard let headerView = headerView as? TPDefaultInfoTableHeaderFooterView else {
            return
        }
        
        headerView.contentPadding = headerPadding
    }
    
    // MARK: -
    func highlightSearchText(for cell: UITableViewCell) {
        if let cell = cell as? SearchHighlightable {
            cell.setHighlightedText(searchText)
        }
    }
    
    func fetchResults(containText text: String, completion: @escaping([ListDiffable]?) -> Void) {
        completion(nil)
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
            self.updateSearchTextForVisibleCells()
            return
        }

        self.searchText = searchText
        performSearch(with: searchText)
    }

    func refreshSearchResults() {
        guard let searchText = self.searchText, searchText.count > 0 else {
            return
        }
        
        performSearch(with: searchText)
    }

    private func performSearch(with searchText: String) {
        self.searchText = searchText
        self.fetchResults(containText: searchText) { [weak self] results in
            guard let self = self, searchText == self.searchText else {
                return
            }
            
            self.searchResults = results
            self.adapter?.performSectionUpdate(forSectionObject: self,
                                               rowAnimation: .fade,
                                               completion: nil)
            self.updateSearchTextForVisibleCells()
        }
    }
    
    /// 更新可见 cell 搜索文本
    func updateSearchTextForVisibleCells() {
        guard let cells = adapter?.visibleCells as? [SearchHighlightable] else {
            return
        }
        
        for cell in cells {
            cell.setHighlightedText(searchText)
        }
    }
}
