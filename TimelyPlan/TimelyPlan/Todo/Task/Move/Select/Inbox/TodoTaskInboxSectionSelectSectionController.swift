//
//  TodoTaskInboxSectionSelectSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/6.
//

import Foundation
import UIKit

class TodoTaskInboxSectionSelectSectionController: TPTableItemSectionController,
                                                    TPImageInfoRightExpandCellDelegate {
    
    /// 收件箱单元格条目
    let inboxCellItem = TodoTaskMoveInboxListCellItem()
    
    var sectionCellItems: [TodoTaskMoveInboxSectionCellItem] = []
    
    var sections: [TodoSection]
    
    let viewModel: TodoTaskSectionViewModel
    
    private var selection: TodoTaskSectionSelection {
        return viewModel.selection
    }
    
    init(viewModel: TodoTaskSectionViewModel) {
        self.viewModel = viewModel
        self.sections = viewModel.inboxSections
        super.init()
        self.inboxCellItem.isExpanded = selection.isSectionExpanded(for: nil)
        self.sections.append(.none(for: nil))
        self.sectionCellItems = sections.map {TodoTaskMoveInboxSectionCellItem(section: $0)}
    }
    
    override var items: [ListDiffable]? {
        if selection.isSectionExpanded(for: nil) {
            return [inboxCellItem] + sectionCellItems
        }
        
        return [inboxCellItem]
    }

    override func shouldShowCheckmarkForRow(at index: Int) -> Bool {
        if let cellItem = item(at: index) as? TodoTaskMoveInboxSectionCellItem {
            return selection.isSelectedSection(cellItem.section)
        } else {
            return selection.isSelectedList(nil)
        }
    }

    override func didSelectRow(at index: Int) {
        TPImpactFeedback.impactWithSoftStyle()
        if let cellItem = item(at: index) as? TodoTaskMoveInboxSectionCellItem {
            selection.selectSection(cellItem.section)
        } else {
            let isExpanded = !selection.isSectionExpanded(for: nil)
            selection.setSectionExpanded(isExpanded, for: nil)
        }
        
        adapter?.updateCheckmarks()
        adapter?.performUpdate()
    }
    
    // MARK: - TPImageInfoRightExpandCellDelegate
    
    func isExpandedTableCell(_ cell: TPImageInfoRightExpandCell) -> Bool {
        return selection.isSectionExpanded(for: nil)
    }
    
    func expandTableCell(_ cell: TPImageInfoRightExpandCell, canToggleExpandStateTo isExpanded: Bool) -> Bool {
        return true
    }
    
    func expandTableCell(_ cell: TPImageInfoRightExpandCell, didToggleExpand isExpanded: Bool) {
        selection.setSectionExpanded(isExpanded, for: nil)
        adapter?.performUpdate()
    }
}
