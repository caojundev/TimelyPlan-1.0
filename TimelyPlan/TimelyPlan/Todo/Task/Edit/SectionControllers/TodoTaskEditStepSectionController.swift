//
//  TodoTaskEditStepSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/30.
//

import Foundation
import UIKit

class TodoTaskEditStepSectionController: TPTableItemSectionController,
                                         TodoTaskStepEditCellDelegate {
    
    /// 步骤发生改变回调
    var stepsInfoDidChange: (() -> Void)?
    
    /// 步骤编辑管理器
    var stepEditControler: TodoStepEditController?

    private var steps: [TodoStep]?

    override var items: [ListDiffable]? {
        self.steps = self.task.orderedSteps()
        guard let steps = self.steps, steps.count > 0 else {
            return [addCellItem]
        }
        
        var cellItems = [TPBaseTableCellItem]()
        for step in steps {
            let cellItem = newCellItem(with: step)
            cellItems.append(cellItem)
        }
        
        cellItems.append(addCellItem)
        return cellItems
    }
    
    /// 添加单元格条目
    lazy var addCellItem: TodoTaskEditTableCellItem = {
        let cellItem = TodoTaskEditTableCellItem()
        cellItem.imageName = "plus_24"
        cellItem.title = resGetString("Add Step")
        cellItem.titleConfig.textColor = cellItem.activeColor
        cellItem.imageConfig.color = cellItem.activeColor
        return cellItem
    }()

    let task: TodoTask
    
    init(task: TodoTask) {
        self.task = task
        super.init()
        self.setupSeparatorFooterItem()
        todo.addUpdater(self, for: .step)
    }
    
    override func heightForHeader() -> CGFloat {
        return 0.0
    }
    
    override func didSelectRow(at index: Int) {
        if let cell = cellForRow(at: index) as? TodoTaskStepEditCell {
            cell.setTextEditing(true)
        } else {
            /// 开始编辑
            stepEditControler?.beginEditing()
        }
    }
    
    override func trailingSwipeActionsConfigurationForRow(at index: Int) -> UISwipeActionsConfiguration? {
        UIResponder.resignCurrentFirstResponder()
        guard let cellItem = item(at: index) as? TodoTaskStepEditCellItem else {
            return nil
        }
        
        /// 删除
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, completion in
            todo.deleteStep(cellItem.step)
            completion(true)
        }
                            
        deleteAction.image = resGetImage("trash_24")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    // MARK: - 任务步骤菜单操作
    func performTaskStepMenuAction(with type: TodoTaskStepMenuActionType, for step: TodoStep) {
        guard let steps = steps else {
            return
        }
        
        switch type {
        case .addPreviousStep:
            todo.addPreviousStep(of: step)
        case .addNextStep:
            todo.addNextStep(of: step)
        case .moveToTop:
            todo.moveStepToTop(step, in: steps)
        case .copyStep:
            copyStep(step)
        case .delete:
            todo.deleteStep(step)
        }
    }
    
    private func copyStep(_ step: TodoStep) {
        UIPasteboard.general.string = step.name
        let message = resGetString("The step has been copied to the clipboard.")
        TPFeedbackQueue.common.postFeedback(text: message, position: .top)
    }
    
    /// 开始或结束特定步骤的文本编辑
    func setTextEditing(_ isEditing: Bool, for step: TodoStep) {
        if let cell = stepEditCell(for: step) {
            cell.setTextEditing(isEditing)
        }
    }
    
    // MARK: - TodoTaskStepEditCellDelegate
    func stepEditCellDidClickCheckbox(_ cell: TodoTaskStepEditCell) {
        guard let step = cell.step else {
            return
        }
        
        let isCompleted = !step.isCompleted
        todo.updateStep(step, isCompleted: isCompleted)
    }
    
    func stepEditCellDidClickMore(_ cell: TodoTaskStepEditCell) {
        UIResponder.resignCurrentFirstResponder()
        guard let step = cell.step else {
            return
        }
        
        let stepIndex = steps?.indexOf(step) ?? 0
        let menuController = TodoTaskStepMenuController(step: step)
        menuController.showMoveToTop = stepIndex > 0
        menuController.didSelectMenuActionType = { type in
            self.performTaskStepMenuAction(with: type, for: step)
        }

        let sourceRect = cell.moreButton.bounds.insetBy(dx: -5.0, dy: -10.0)
        menuController.showMenu(from: cell.moreButton,
                                sourceRect: sourceRect,
                                isCovered: true)
    }
    
    func textViewTableCell(_ cell: TPTextViewTableCell, didEndEditing textView: UITextView) {
        guard let cell = cell as? TodoTaskStepEditCell, let step = cell.step else {
            return
        }

        let name = textView.text.whitespacesAndNewlinesTrimmedString
        if name.count > 0 {
            todo.updateStep(step, name: name)
        } else {
            todo.deleteStep(step)
        }
    }
    
    // MARK: - Helpers
    /// 索引处是否为步骤单元格
    func isStep(at index: Int) -> Bool {
        guard let cellItem = item(at: index) else {
            return false
        }
        
        return cellItem is TodoTaskStepEditCellItem
    }
    
    /// 根据 step 创建新的单元格条目
    private func newCellItem(with step: TodoStep) -> TodoTaskStepEditCellItem {
        let cellItem = TodoTaskStepEditCellItem(step: step)
        cellItem.font = UIFont.systemFont(ofSize: 14.0)
        return cellItem
    }
    
    /// 获取 step 对应的单元格
    private func cellItem(for step: TodoStep) -> TodoTaskStepEditCellItem? {
        guard let cellItems = adapter?.items(for: self) else {
            return nil
        }
        
        for cellItem in cellItems {
            if let cellItem = cellItem as? TodoTaskStepEditCellItem, step === cellItem.step {
                return cellItem
            }
        }
        
        return nil
    }
    
    private func stepEditCell(for step: TodoStep) -> TodoTaskStepEditCell? {
        if let cellItem = cellItem(for: step),
           let cell = adapter?.cellForItem(cellItem) as? TodoTaskStepEditCell {
            return cell
        }
        
        return nil
    }
}

extension TodoTaskEditStepSectionController: TodoStepProcessorDelegate {
    
    func didAddTodoStep(_ step: TodoStep) {
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top, completion: { [weak self] _ in
            guard let self = self else { return }
            if let name = step.name, name.count > 0 {
                guard let cellItem = self.cellItem(for: step) else {
                    return
                }
                
                /// 滚动到可视位置
                self.adapter?.scrollToItem(cellItem, at: .middle, animated: true, completion: { _ in
                    self.adapter?.commitFocusAnimation(for: cellItem)
                })
            } else {
                self.setTextEditing(true, for: step)
            }
        })
        
        stepsInfoDidChange?()
    }

    func didUpdateTodoStep(_ step: TodoStep, with change: TodoStepChange){
        guard let cell = stepEditCell(for: step) else {
            return
        }
        
        switch change {
        case .name(_, let newValue):
            updateText(newValue, forTextViewTableViewCell: cell)
        case .completed(_):
            cell.updateCompleted(animated: true)
            stepsInfoDidChange?()
        }
    }

    func didDeleteTodoStep(_ step: TodoStep, of task: TodoTask){
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
        stepsInfoDidChange?()
    }
    
    func didReorderTodoStep(in steps: [TodoStep], fromIndex: Int, toIndex: Int) {
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
    }
}

extension TodoTaskEditStepSectionController: TPTableDragInsertReorderDelegate {
    
    func tableDragReorder(_ reorder: TPTableDragReorder, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == self.section, isStep(at: indexPath.row) {
            return true
        }
        
        return false
    }
    
    func tableDragReorder(_ reorder: TPTableDragReorder, willBeginAt indexPath: IndexPath) {
        UIResponder.resignCurrentFirstResponder()
        reorder.tableView.setEditing(false, animated: false)
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder,
                                canInsertRowTo targetIndexPath: IndexPath,
                                from sourceIndexPath: IndexPath) -> Bool {
        guard sourceIndexPath.section == targetIndexPath.section,
              sourceIndexPath.row != targetIndexPath.row,
              isStep(at: targetIndexPath.row)  else {
            return false
        }
        
        return true
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder,
                                inserRowTo targetIndexPath: IndexPath,
                                from sourceIndexPath: IndexPath,
                                depth: Int) -> IndexPath? {
        guard let steps = steps, sourceIndexPath != targetIndexPath else {
            return sourceIndexPath
        }
        
        todo.reorderStep(in: steps, fromIndex: sourceIndexPath.row, toIndex: targetIndexPath.row)
        adapter?.performUpdate()
        return targetIndexPath
    }
}

