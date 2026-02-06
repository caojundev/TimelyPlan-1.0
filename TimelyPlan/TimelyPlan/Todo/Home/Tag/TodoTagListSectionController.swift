//
//  TodoTagListSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/25.
//

import Foundation
import UIKit

class TodoTagListSectionController: TPTableBaseSectionController,
                                    TodoTagHomeCellDelegate {
    
    var isExpanded: Bool = true
    
    override var items: [ListDiffable]? {
        guard isExpanded else {
            return nil
        }
        
        return todo.getTags()
    }
    
    /// 标签管理器
    private let tagController = TodoTagController()
    
    override init() {
        super.init()
        todo.addUpdater(self, for: .tag)
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
        return TodoTagHomeCell.self
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        super.didDequeCell(cell, forRowAt: index)
        guard let cell = cell as? TodoTagHomeCell else {
            return
        }
        
        cell.depth = 1
        cell.contentPadding = UIEdgeInsets(left: 1.0, right: 10.0)
        cell.userTag = item(at: index) as? TodoTag
    }
    
    override func didSelectRow(at index: Int) {
        TPImpactFeedback.impactWithSoftStyle()
    }
    
    // MARK: - TodoTagHomeCellDelegate
    func todoTagHomeCellDidClickMore(_ cell: TodoTagHomeCell) {
        guard let userTag = cell.userTag else {
            return
        }
        
        let menuController = TodoTagMenuActionController()
        menuController.didSelectMenuActionType = {[weak self] type in
            self?.tagController.performMenuAction(with: type, for: userTag)
        }
        
        let sourceView = cell.moreButton
        let sourceRect = sourceView.bounds.insetBy(dx: -4.0, dy: -4.0)
        menuController.showMenu(from: cell.moreButton, sourceRect: sourceRect)
    }
}

// MARK: - 标签处理代理
extension TodoTagListSectionController: TodoTagProcessorDelegate {
    
    func didCreateTodoTag(_ tag: TodoTag) {
        guard isExpanded else {
            return
        }
        
        adapter?.performSectionUpdate(forSectionObject: self) { _ in
            self.adapter?.commitFocusAnimation(for: tag)
        }
    }
    
    func didDeleteTodoTag(_ tag: TodoTag) {
        adapter?.performSectionUpdate(forSectionObject: self)
    }
    
    func didUpdateTodoTag(_ tag: TodoTag) {
        adapter?.reloadCell(forItems: [tag],
                           inSection: self,
                           rowAnimation: .automatic,
                           animateFocus: true)
    }
    
    func didReorderTodoTag(in tags: [TodoTag], fromIndex: Int, toIndex: Int) {
        
    }
}

// MARK: - 标签排序
extension TodoTagListSectionController: TPTableDragInsertReorderDelegate {
    
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
        guard let tags = adapter?.items(for: self) as? [TodoTag],
                targetIndexPath.row != sourceIndexPath.row else {
            return nil
        }
        
        if todo.reorderTag(in: tags, fromIndex: sourceIndexPath.row, toIndex: targetIndexPath.row) {
            adapter?.performSectionUpdate(forSectionObject: self)
            return targetIndexPath
        }
        
        return sourceIndexPath
    }
}
