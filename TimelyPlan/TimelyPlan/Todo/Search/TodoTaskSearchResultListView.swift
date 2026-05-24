//
//  TodoTaskSearchResultListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/24.
//

import Foundation

class TodoTaskSearchResultListView: TodoTaskListView {
    
    /// 当前结果对应的搜索文本
    var searchText: String?
    
    override func adapter(_ adapter: TPTableViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return TodoTaskSearchResultCell.self
    }
    
    override func adapter(_ adapter: TPTableViewAdapter, didDequeCell cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.adapter(adapter, didDequeCell: cell, forRowAt: indexPath)
        highlightSearchText(for: cell)
    }
    
    // MARK: -
    func highlightSearchText(for cell: UITableViewCell) {
        if let cell = cell as? SearchHighlightable {
            cell.setHighlightedText(searchText)
        }
    }
    
    /// 更新可见 cell 搜索文本
    private func updateSearchTextForVisibleCells() {
        guard let cells = adapter.visibleCells as? [SearchHighlightable] else {
            return
        }
        
        for cell in cells {
            cell.setHighlightedText(searchText)
        }
    }
}
