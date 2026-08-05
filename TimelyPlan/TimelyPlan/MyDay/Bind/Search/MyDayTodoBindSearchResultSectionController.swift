//
//  MyDayTodoBindSearchResultSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/29.
//

import Foundation
import UIKit

class MyDayTodoBindSearchResultSectionController: TPTableSearchResultSectionController,
                                                    TodoTaskProcessorDelegate {
    
    override init() {
        super.init()
        TodoRepository.addUpdater(self, for: [.task])
    }
    
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
        return MyDayTodoTaskBindCell.self
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        super.didDequeCell(cell, forRowAt: index)
        guard let cell = cell as? MyDayTodoTaskBindCell,
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
        TodoRepository.searchTasks(matching: text, options: options, completion: completion)
    }
    
    override func shouldShowCheckmarkForRow(at index: Int) -> Bool {
        guard let task = item(at: index) as? TodoTask else {
            return false
        }
        
        return task.isAddedToMyDay
    }
    
    override func didSelectRow(at index: Int) {
        guard let task = item(at: index) as? TodoTask else {
            return
        }
        
        let isAddedToMyDay = !task.isAddedToMyDay
        TodoRepository.updateTask(task, isAddedToMyDay: isAddedToMyDay)
    }
    
    // MARK: - Helpers
    private lazy var layoutConfig: TodoTaskLayoutConfig = {
        var config = TodoTaskLayoutConfig()
        config.checkboxMargins = UIEdgeInsets(left: 4.0, right: 8.0)
        return config
    }()
    
    private func layout(for task: TodoTask) -> TodoTaskInfoLayout {
        layoutManager.width = layoutWidth
        layoutManager.showDetail = true
        layoutManager.config = layoutConfig
        return layoutManager.layout(for: task)
    }
    
    private var layoutWidth: CGFloat {
        guard let tableView = adapter?.tableView else {
            return 0.0
        }
        
        var width = tableView.width
        if tableView.style == .insetGrouped {
            width -= tableView.layoutMargins.horizontalLength
        }
        
        return width
    }
    
    // MARK: - TodoTaskProcessorDelegate
    func didUpdateTodoTask(_ task: TodoTask, with change: TodoTaskChange) {
        refreshSearchResults()
    }
}

class MyDayTodoTaskBindCell: TodoTaskSelectTableCell {
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.selectInfoView.leftView = nil
        self.selectInfoView.leftViewSize = .zero
        self.selectInfoView.leftViewMargins = .zero
        self.selectInfoView.rightView = selectInfoView.checkbox
        self.selectInfoView.rightViewSize = selectInfoView.checkboxSize
        self.selectInfoView.rightViewMargins = selectInfoView.checkboxMargins
    }
    
    override func reloadData(animated: Bool) {
        super.reloadData(animated: animated)
        if let layout = layout {
            selectInfoView.leftViewSize = .zero
            selectInfoView.leftViewMargins = .zero
            
            selectInfoView.rightViewSize = layout.config.checkboxConfig.size
            selectInfoView.rightViewMargins = layout.config.checkboxMargins
            selectInfoView.setNeedsLayout()
        }
        
        setNeedsLayout()
    }
}
