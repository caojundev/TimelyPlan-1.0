//
//  TPCollectionSearchResultSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/29.
//

import Foundation
import UIKit

class TPCollectionSearchResultSectionController: TPCollectionBaseSectionController,
                                                    UISearchResultsUpdating {
    
    /// 当前结果对应的搜索文本
    private(set) var searchText: String?
    
    /// 当前搜索结果
    private(set) var searchResults: [ListDiffable]?
    
    /// 区块布局
    lazy var layout: TPCollectionSectionLayout = {
        let layout = TPCollectionSectionLayout()
        layout.edgeMargins = UIEdgeInsets(horizontal: 16.0, vertical: 10.0)
        layout.minimumItemsCountPerRow = 1
        layout.maximumItemsCountPerRow = 1
        layout.lineSpacing = 10.0
        layout.interitemSpacing = 10.0
        layout.preferredItemHeight = 70.0
        layout.preferredItemWidth = 560.0
        return layout
    }()
    
    lazy var cellStyle: TPCollectionCellStyle = {
        let style = TPCollectionCellStyle()
        style.backgroundColor = .secondarySystemGroupedBackground
        style.selectedBackgroundColor = .secondarySystemFill
        style.cornerRadius = 12.0
        return style
    }()

    override init() {
        super.init()
    }
    
    override var items: [ListDiffable]? {
        return searchResults
    }
    
    override func interitemSpacing() -> CGFloat {
        return layout.interitemSpacing
    }
    
    override func lineSpacing() -> CGFloat {
        return layout.lineSpacing
    }
    
    override func sectionInset() -> UIEdgeInsets {
        return layout.sectionInset
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        layout.collectionViewSize = adapter?.collectionViewSize()
        return layout.constraintCellSize ?? .zero
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return TPCollectionCell.self
    }

    override func didDequeCell(_ cell: UICollectionViewCell, forItemAt index: Int) {
        super.didDequeCell(cell, forItemAt: index)
        highlightSearchText(for: cell)
    }
    
    override func didSelectItem(at index: Int) {
        TPImpactFeedback.impactWithSoftStyle()
        /// 通知delegate
        delegate?.collectionSectionController(self, didSelectItemAt: index)
    }
    
    override func styleForItem(at index: Int) -> TPCollectionCellStyle? {
        return cellStyle
    }
    
    // MARK: -
    func highlightSearchText(for cell: UICollectionViewCell) {
        if let cell = cell as? SearchHighlightable {
            cell.setHighlightedText(self.searchText)
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
        self.fetchResults(containText: searchText) { [weak self] results in
            guard let self = self, searchText == self.searchText else {
                return
            }
            
            self.searchResults = results
            self.adapter?.performUpdate()
            self.updateSearchTextForVisibleCells()
        }
    }

    /// 更新可见 cell 搜索文本
    private func updateSearchTextForVisibleCells() {
        guard let cells = adapter?.visibleCells as? [FocusUserTimerInfoCell] else {
            return
        }
        
        for cell in cells {
            cell.setHighlightedText(self.searchText)
        }
    }
}
