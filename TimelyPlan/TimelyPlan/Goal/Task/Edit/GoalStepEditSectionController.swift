//
//  GoalStepEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/3.
//

import Foundation
import UIKit

class GoalStepEditSectionController: TodoStepEditSectionController {
    
    override var items: [ListDiffable]? {
        var cellItems = super.items ?? []
        cellItems.append(addCellItem)
        return cellItems
    }
    
    /// 添加单元格条目
    lazy var addCellItem: TPImageInfoRightButtonTableCellItem = {
        let cellItem = TPImageInfoRightButtonTableCellItem()
        cellItem.imageName = "plus_24"
        cellItem.title = resGetString("Add Step")
        cellItem.titleConfig.textColor = .primary
        cellItem.imageConfig.color = .primary
        cellItem.didSelectHandler = { [weak self] in
            self?.createNewStep()
        }
        
        return cellItem
    }()
    
    /// add 单元格所在行号（区块最后一行）
    private var addCellRowIndex: Int {
        return displaySteps.count
    }
    
    override func allowMenuActionTypes() -> [TodoTaskStepMenuActionType] {
        return [.addSubStep, .addPreviousStep, .addNextStep, .copyStep , .delete]
    }
    
    // MARK: - 列表排序
    override func tableDragReorder(_ reorder: TPTableDragReorder, canMoveRowAt indexPath: IndexPath) -> Bool {
        /// 仅在当前区块、且非 add 单元格时可移动
        guard indexPath.section == self.section else {
            return false
        }
        
        /// add 单元格不可移动
        return indexPath.row < addCellRowIndex
    }
    
    override func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, canInsertRowTo targetIndexPath: IndexPath, from sourceIndexPath: IndexPath) -> Bool {
        guard sourceIndexPath.section == targetIndexPath.section else {
            return false
        }
        
        /// step 单元格不可移动到 add 单元格处
        guard targetIndexPath.row < addCellRowIndex else {
            return false
        }
        
        return self.displaySteps.canInsertItem(at: sourceIndexPath.row, to: targetIndexPath.row)
    }
    
    override func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, canFlashRowAt indexPath: IndexPath, from sourceIndexPath: IndexPath) -> Bool {
        /// add 单元格不可作为闪烁目标
        guard indexPath.row < addCellRowIndex else {
            return false
        }
        
        return super.tableDragInsertReorder(reorder, canFlashRowAt: indexPath, from: sourceIndexPath)
    }
}
