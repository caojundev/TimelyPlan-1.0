//
//  TodoUserTagSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/25.
//

import Foundation
import UIKit

class TodoUserTagSectionController: TPTableBaseSectionController,
                                    TodoUserTagCellDelegate {
    
    /// 头区块控制器
    lazy var headerSectionController: TodoHomeHeaderSectionController = { [weak self] in
        let sectionController = TodoHomeHeaderSectionController(sectionType: .tag)
        sectionController.didClickAdd = {
            self?.createTag()
        }
        
        sectionController.didToggleExpanded = { isExpanded in
            self?.setExpanded(isExpanded)
        }
        
        return sectionController
    }()
    
    var didSelectTag: ((TodoTag) -> Void)?
    
    private let viewModel = TodoHomeUserTagViewModel()

    /// 标签管理器
    private let tagController = TodoTagController()

    override var items: [ListDiffable]? {
        guard viewModel.isExpanded else {
            return nil
        }

        return viewModel.tags
    }
    
    override init() {
        super.init()
        self.headerSectionController.setExpanded(self.viewModel.isExpanded)
        self.viewModel.tagsDidChange = { [weak self] change in
            self?.tagsDidChange(with: change)
        }
        
        self.viewModel.countDidChange = { [weak self] tags in
            self?.updateTaskCount(for: tags)
        }
    }
    
    /// 更新标签任务数目
    private func updateTaskCount(for tags: [TodoTag]) {
        for tag in tags {
            let diffIdentifier = tag.identifier as NSString
            let cell = adapter?.cellForItem(with: diffIdentifier, inSection: self)
            if let cell = cell as? TodoUserTagCell {
                cell.updateTaskCount()
            }
        }
    }
    
    private func tagsDidChange(with change: TodoUserTagChange?) {
        guard let change = change else {
            adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
            return
        }

        var animateTag: TodoTag?
        switch change {
        case .create(let tag):
            /// 展开标签
            if !viewModel.isExpanded {
                headerSectionController.setExpanded(true)
                setExpanded(true)
            }
            
            animateTag = tag
        case .update(let tag):
            animateTag = tag
        }

        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
        if let animateTag = animateTag {
            adapter?.commitFocusAnimation(for: animateTag)
        }
    }
    
    func createTag() {
        tagController.createTag()
    }
    
    // MARK: - 展开 / 收起
    func setExpanded(_ isExpanded: Bool) {
        guard viewModel.isExpanded != isExpanded else {
            return
        }
        
        viewModel.isExpanded = isExpanded
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
    }
    
    // MARK: - Delegate
    override func heightForRow(at index: Int) -> CGFloat {
        return 55.0
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return TodoUserTagCell.self
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        super.didDequeCell(cell, forRowAt: index)
        guard let cell = cell as? TodoUserTagCell else {
            return
        }
        
        cell.depth = 1
        cell.userTag = item(at: index) as? TodoTag
    }
    
    override func didSelectRow(at index: Int) {
        TPImpactFeedback.impactWithSoftStyle()
        if let tag = item(at: index) as? TodoTag {
            self.didSelectTag?(tag)
        }
    }
    
    // MARK: - TodoUserTagCellDelegate
    func todoTagCellDidClickMore(_ cell: TodoUserTagCell) {
        guard let userTag = cell.userTag else {
            return
        }
        
        let menuController = TodoTagMenuActionController()
        menuController.didSelectMenuActionType = {[weak self] type in
            self?.tagController.performMenuActionType(type, for: userTag)
        }
        
        let sourceView = cell.moreButton
        let sourceRect = sourceView.bounds.insetBy(dx: -4.0, dy: -4.0)
        menuController.showMenu(from: cell.moreButton, sourceRect: sourceRect)
    }
    
    func todoTagCell(_ cell: TodoUserTagCell, requestCount completion: @escaping (Int?) -> Void) {
        guard let userTag = cell.userTag else {
            completion(nil)
            return
        }
        
        viewModel.fetchUncompletedTaskCount(for: userTag, completion: completion)
    }

    // MARK: - Helpers
    /// 当前标签列表
    var tags: [TodoTag] {
        if let lists = adapter?.items(for: self) as? [TodoTag] {
            return lists
        }

        return []
    }
}

// MARK: - 标签排序
extension TodoUserTagSectionController: TPTableDragInsertReorderDelegate {
    
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
              let tag = self.item(at: sourceIndexPath.row) as? TodoTag else {
            return nil
        }
    
        todo.reorderTag(in: self.tags, fromIndex: sourceIndexPath.row, toIndex: targetIndexPath.row)
        
        /// 重新排序完成返回新索引
        var newIndexPath: IndexPath? = nil
        if let newIndex = self.tags.indexOf(tag) {
            newIndexPath = IndexPath(row: newIndex, section: targetIndexPath.section)
        }

        return newIndexPath
    }
}
