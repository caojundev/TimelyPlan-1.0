//
//  TodoUserTagSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/25.
//

import Foundation
import UIKit

class TodoUserTagSectionController: TPTableBaseSectionController,
                                    TodoUserTagCellDelegate,
                                    TodoHomeExpandHeaderViewDelegate {
    var isExpanded: Bool = true
    
    var didSelectTag: ((TodoTag) -> Void)?
    
    private let viewModel = TodoUserTagViewModel()
    
    override var items: [ListDiffable]? {
        guard isExpanded else {
            return nil
        }

        return viewModel.tags
    }
    
    /// 标签管理器
    private let tagController = TodoTagController()
    
    override init() {
        super.init()
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
            setExpanded(true, animated: true)
            animateTag = tag
        case .update(let tag):
            animateTag = tag
        }

        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
        if let animateTag = animateTag {
            adapter?.commitFocusAnimation(for: animateTag)
        }
    }
    
    // MARK: - Delegate
    override func heightForHeader() -> CGFloat {
        return 50.0
    }
    
    override func classForHeader() -> AnyClass? {
        return TodoHomeExpandHeaderView.self
    }
    
    override func didDequeHeader(_ headerView: UITableViewHeaderFooterView) {
        guard let headerView = headerView as? TodoHomeExpandHeaderView else {
            return
        }
        
        headerView.contentView.backgroundColor = adapter?.cellStyle.backgroundColor
        headerView.delegate = self
        headerView.isExpanded = isExpanded
        headerView.title = resGetString("Tag")
        headerView.imageContent = .withName("todo_home_tag_24")
    }
    
    override func heightForFooter() -> CGFloat {
        return 0.0
    }
    
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
    
    // MARK: - 展开 / 收起
    private func setExpanded(_ isExpanded: Bool, animated: Bool) {
        guard self.isExpanded != isExpanded else {
            return
        }
        
        self.isExpanded = isExpanded
        guard let headerView = adapter?.headerView(in: section) as? TodoHomeExpandHeaderView else {
            return
        }
        
        headerView.setExpanded(isExpanded, animated: animated)
    }
    
    private func didToggleExpand() {
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
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

    // MARK: - TodoHomeExpandHeaderViewDelegate
    func todoHomeExpandHeaderViewDidClickAdd(_ headerView: TodoHomeExpandHeaderView) {
        tagController.createTag()
    }
    
    func todoHomeExpandHeaderView(_ headerView: TodoHomeExpandHeaderView, didToggleExpand isExpanded: Bool) {
        self.isExpanded = isExpanded
        didToggleExpand()
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
