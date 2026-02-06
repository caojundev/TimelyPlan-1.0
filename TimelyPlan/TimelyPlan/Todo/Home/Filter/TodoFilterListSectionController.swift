//
//  TodoFilterListSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/16.
//

import Foundation

class TodoFilterListSectionController: TPTableBaseSectionController,
                                       TodoFilterHomeCellDelegate {
    
    var isExpanded: Bool = true
    
    override var items: [ListDiffable]? {
        guard isExpanded else {
            return nil
        }
        
        return todo.getFilters()
    }
    
    private let filterController = TodoFilterController()
    
    override init() {
        super.init()
        todo.addUpdater(self, for: .filter)
    }
    
    // MARK: - Delegate
    override func heightForHeader() -> CGFloat {
        return 0.0
    }
    
    override func heightForFooter() -> CGFloat {
        return 0.0
    }
    
    override func heightForRow(at index: Int) -> CGFloat {
        return 55.0
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return TodoFilterHomeCell.self
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        super.didDequeCell(cell, forRowAt: index)
        guard let cell = cell as? TodoFilterHomeCell else {
            return
        }
        
        cell.depth = 1
        cell.contentPadding = UIEdgeInsets(left: 1.0, right: 10.0)
        cell.filter = item(at: index) as? TodoFilter
    }
    
    override func didSelectRow(at index: Int) {
        TPImpactFeedback.impactWithSoftStyle()
        
    }
    
    // MARK: - TodoFilterHomeCellDelegate
    func todoFilterHomeCellDidClickMore(_ cell: TodoFilterHomeCell) {
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
}

extension TodoFilterListSectionController: TodoFilterProcessorDelegate {
    
    func didCreateTodoFilter(_ filter: TodoFilter) {
        guard isExpanded else {
            return
        }

        adapter?.performSectionUpdate(forSectionObject: self) { _ in
            self.adapter?.commitFocusAnimation(for: filter)
        }
    }
    
    func didDeleteTodoFilter(_ filter: TodoFilter) {
        adapter?.performSectionUpdate(forSectionObject: self)
    }

    func didUpdateTodoFilter(_ filter: TodoFilter) {
        adapter?.reloadCell(forItems: [filter],
                            inSection: self,
                            rowAnimation: .automatic,
                            animateFocus: true)
    }

    func didReorderTodoFilter(in filters: [TodoFilter], fromIndex: Int, toIndex: Int) {
        
    }
}

// MARK: - 标签排序
extension TodoFilterListSectionController: TPTableDragInsertReorderDelegate {
    
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
        guard let filters = adapter?.items(for: self) as? [TodoFilter],
                targetIndexPath.row != sourceIndexPath.row else {
            return nil
        }
        
        if todo.reorderFilter(in: filters, fromIndex: sourceIndexPath.row, toIndex: targetIndexPath.row) {
            adapter?.performSectionUpdate(forSectionObject: self)
            return targetIndexPath
        }
        
        return sourceIndexPath
    }
}
