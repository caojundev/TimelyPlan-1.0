//
//  CountdownEventSearchResultListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/17.
//

import Foundation
import UIKit

class CountdownEventSearchResultListView: CountdownEventListView {
    
    /// 当前结果对应的搜索文本
    var searchText: String? {
        didSet {
            updateSearchTextForVisibleCells()
        }
    }
    
    override func shouldAddRefreshControl() -> Bool {
        return false
    }
    
    // MARK: - AdapterDelegate
    override func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        switch layoutType {
        case .list:
            return CountdownEventSearchResultListCell.self
        case .grid:
            return CountdownEventSearchResultGridCell.self
        }
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        super.adapter(adapter, didDequeCell: cell, at: indexPath)
        highlightSearchText(for: cell)
    }
    
    // MARK: -
    /// 更新单元格搜索文本高亮
    private func highlightSearchText(for cell: UICollectionViewCell) {
        if let cell = cell as? SearchHighlightable {
            cell.setHighlightedText(searchText)
        }
    }
    
    /// 更新可见单元格搜索文本高亮
    private func updateSearchTextForVisibleCells() {
        guard let cells = adapter.visibleCells as? [SearchHighlightable] else {
            return
        }
        
        for cell in cells {
            cell.setHighlightedText(searchText)
        }
    }
}

class CountdownEventSearchResultListCell: CountdownEventListCell, SearchHighlightable {
    
    /// 高亮文本
    var highlightedText: String?
    
    var normalAttributes: [NSAttributedString.Key: Any] {
        return [
            .foregroundColor: infoView.titleConfig.textColor ?? .label,
            .font: infoView.titleConfig.font
        ]
    }
    
    var highlightAttributes: [NSAttributedString.Key: Any] {
        return [
            .backgroundColor: Color(0xFFD60A),
            .foregroundColor: UIColor.black,
            .font: infoView.titleConfig.font
        ]
    }
    
    override func updateInfo() {
        super.updateInfo()
        
        guard let highlightedText = highlightedText,
              highlightedText.count > 0,
              let name = event?.name,
              name.count > 0 else {
            return
        }
        
        let value = name.attributedStringWithHighlight(highlightedText,
                                                       normalAttributes: normalAttributes,
                                                       highlightAttributes: highlightAttributes)
        infoView.title = ASAttributedString(value: value)
    }
    
    /// 设置搜索文本并更新高亮显示
    func setHighlightedText(_ highlightedText: String?) {
        self.highlightedText = highlightedText
        self.updateInfo()
    }
}

class CountdownEventSearchResultGridCell: CountdownEventGridCell, SearchHighlightable {
    
    /// 高亮文本
    var highlightedText: String?
    
    var normalAttributes: [NSAttributedString.Key: Any] {
        return [
            .foregroundColor: infoView.titleConfig.textColor ?? .label,
            .font: infoView.titleConfig.font
        ]
    }
    
    var highlightAttributes: [NSAttributedString.Key: Any] {
        return [
            .backgroundColor: Color(0xFFD60A),
            .foregroundColor: UIColor.black,
            .font: infoView.titleConfig.font
        ]
    }
    
    override func updateInfo() {
        super.updateInfo()
        
        guard let highlightedText = highlightedText,
              highlightedText.count > 0,
              let name = event?.name,
              name.count > 0 else {
            return
        }
        
        let value = name.attributedStringWithHighlight(highlightedText,
                                                       normalAttributes: normalAttributes,
                                                       highlightAttributes: highlightAttributes)
        infoView.title = ASAttributedString(value: value)
    }
    
    /// 设置搜索文本并更新高亮显示
    func setHighlightedText(_ highlightedText: String?) {
        self.highlightedText = highlightedText
        self.updateInfo()
    }
}
