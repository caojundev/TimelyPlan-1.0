//
//  TodoFilterSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/19.
//

import Foundation
import UIKit

class TodoFilterSectionController: TPTableBaseSectionController,
                                    TodoFilterCellDelegate {
    
    /// 头区块控制器
    lazy var headerSectionController: TodoHomeHeaderSectionController = { [weak self] in
        let sectionController = TodoHomeHeaderSectionController(sectionType: .filter)
        sectionController.didClickAdd = {
            self?.createFilter()
        }
        
        sectionController.didToggleExpanded = { isExpanded in
            self?.setExpanded(isExpanded)
        }
        
        return sectionController
    }()
    
    private(set) var isExpanded: Bool = true
    
    var didSelectFilter: ((TodoFilter) -> Void)?
    
    private let viewModel = TodoFilterViewModel()
    
    override var items: [ListDiffable]? {
        guard isExpanded else {
            return nil
        }

        return viewModel.filters
    }
    
    /// 过滤器管理器
    private let filterController = TodoFilterController()
    
    override init() {
        super.init()
        self.viewModel.filtersDidChange = { [weak self] change in
            self?.filtersDidChange(with: change)
        }

        self.viewModel.countDidChange = { [weak self] filters in
            self?.updateTaskCount(for: filters)
        }
    }
    
    /// 更新过滤器任务数目
    private func updateTaskCount(for filters: [TodoFilter]) {
        for filter in filters {
            let diffIdentifier = filter.identifier as NSString
            let cell = adapter?.cellForItem(with: diffIdentifier, inSection: self)
            if let cell = cell as? TodoFilterCell {
                cell.updateTaskCount()
            }
        }
    }
    
    private func filtersDidChange(with change: TodoFilterChange?) {
        guard let change = change else {
            adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .none)
            return
        }

        var animateFilter: TodoFilter?
        switch change {
        case .create(let filter):
            if !isExpanded {
                /// 展开过滤器
                headerSectionController.setExpanded(true)
                setExpanded(true)
            }
            
            animateFilter = filter
        case .update(let filter):
            animateFilter = filter
        }

        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
        if let animateFilter = animateFilter {
            adapter?.commitFocusAnimation(for: animateFilter)
        }
    }
    
    func createFilter() {
        filterController.createFilter()
    }
    
    // MARK: - 展开 / 收起
    func setExpanded(_ isExpanded: Bool) {
        guard self.isExpanded != isExpanded else {
            return
        }
        
        self.isExpanded = isExpanded
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
    }
    
    // MARK: - Delegate
    override func heightForRow(at index: Int) -> CGFloat {
        return 55.0
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return TodoFilterCell.self
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        super.didDequeCell(cell, forRowAt: index)
        guard let cell = cell as? TodoFilterCell else {
            return
        }
        
        cell.depth = 1
        cell.filter = item(at: index) as? TodoFilter
    }
    
    override func didSelectRow(at index: Int) {
        TPImpactFeedback.impactWithSoftStyle()
        if let filter = item(at: index) as? TodoFilter {
            self.didSelectFilter?(filter)
        }
    }
    
    // MARK: - TodoFilterCellDelegate
    func todoFilterCellDidClickMore(_ cell: TodoFilterCell) {
        guard let filter = cell.filter else {
            return
        }
        
        let menuController = TodoFilterMenuActionController()
        menuController.didSelectMenuActionType = {[weak self] type in
            self?.filterController.performMenuAction(with: type, for: filter)
        }
        
        let sourceView = cell.moreButton
        let sourceRect = sourceView.bounds.insetBy(dx: -4.0, dy: -4.0)
        menuController.showMenu(from: cell.moreButton, sourceRect: sourceRect)
    }
    
    func todoFilterCell(_ cell: TodoFilterCell, requestCount completion: @escaping (Int?) -> Void) {
        guard let filter = cell.filter else {
            completion(nil)
            return
        }
        
        viewModel.fetchUncompletedTaskCount(for: filter, completion: completion)
    }
    
    // MARK: - Helpers
    /// 当前过滤器列表
    var filters: [TodoFilter] {
        if let lists = adapter?.items(for: self) as? [TodoFilter] {
            return lists
        }

        return []
    }
}

// MARK: - 过滤器排序
extension TodoFilterSectionController: TPTableDragInsertReorderDelegate {
    
    func tableDragReorder(_ reorder: TPTableDragReorder, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == section
    }

    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, canInsertRowTo targetIndexPath: IndexPath, from sourceIndexPath: IndexPath) -> Bool {
        guard sourceIndexPath.section == targetIndexPath.section else {
            return false
        }
        
        return true
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder,
                                inserRowTo targetIndexPath: IndexPath,
                                from sourceIndexPath: IndexPath,
                                depth: Int) -> IndexPath? {
        guard targetIndexPath.row != sourceIndexPath.row,
              let filter = self.item(at: sourceIndexPath.row) as? TodoFilter else {
            return nil
        }
    
        todo.reorderFilter(in: self.filters,
                           fromIndex: sourceIndexPath.row,
                           toIndex: targetIndexPath.row)
        
        /// 重新排序完成返回新索引
        var newIndexPath: IndexPath? = nil
        if let newIndex = self.filters.indexOf(filter) {
            newIndexPath = IndexPath(row: newIndex, section: targetIndexPath.section)
        }

        return newIndexPath
    }
}

