//
//  TodoTaskBindSearchResultSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/29.
//

import Foundation
import UIKit

class TodoTaskBindSearchResultSectionController: TPTableSearchResultSectionController {
    
    /// 布局管理器
    private let layoutManager = TodoTaskLayoutManager()
    
    override func didDequeHeader(_ headerView: UITableViewHeaderFooterView) {
        super.didDequeHeader(headerView)
        guard let headerView = headerView as? TPDefaultInfoTableHeaderFooterView else {
            return
        }
        
        headerView.title = resGetString("Todo")
    }
    
    override func heightForRow(at index: Int) -> CGFloat {
        guard let task = item(at: index) as? TodoTask else {
            return 0.0
        }
        
        let layout = layout(for: task)
        return layout.height
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return TodoTaskSelectTableCell.self
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        super.didDequeCell(cell, forRowAt: index)
        guard let cell = cell as? TodoTaskBaseTableCell,
                let task = item(at: index) as? TodoTask else {
            return
        }
        
        cell.layout = layout(for: task)
        cell.reloadData(animated: false)
    }
    
    override func fetchResults(containText text: String, completion: @escaping ([ListDiffable]?) -> Void) {
        var options = TodoSearchOptions()
        options.showCompleted = false
        options.searchNote = false
        options.searchStep = false
        todo.searchTasks(matching: text, options: options, completion: completion)
    }
    
    // MARK: - Helpers
    private func layout(for task: TodoTask) -> TodoTaskInfoLayout {
        layoutManager.width = layoutWidth
        layoutManager.showDetail = false
        return layoutManager.layout(for: task)
    }
    
    var layoutWidth: CGFloat {
        guard let tableView = adapter?.tableView else {
            return 0.0
        }
        
        var width = tableView.width
        if tableView.style == .insetGrouped {
            width -= tableView.layoutMargins.horizontalLength
        }
        
        return width
    }
}
