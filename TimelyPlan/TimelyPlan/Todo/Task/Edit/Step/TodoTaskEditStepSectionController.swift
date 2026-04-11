//
//  TodoTaskEditStepSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/30.
//

import Foundation
import UIKit

class TodoTaskEditStepSectionController: TodoTaskEditBaseSectionController,
                                         TodoTaskStepEditCellDelegate {
    
    lazy var steps: [TodoStep] = {
        let normalMarkdown = """
    - [ ] 项目A
      - [ ] 任务A1
      - [ ] 任务A2
        - [ ] 子任务A2.1
        - [ ] 子任务A2.2
    - [ ] 项目B
      - [ ] 任务B1
    - [ ] 项目B
    - [ ] 项目C
    - [ ] 项目D
    """
        
        let parser = IndentBasedTodoParser()
        let steps = parser.parse(normalMarkdown)
        return steps
    }()
    
    override var items: [ListDiffable]? {
        var cellItems = [TodoTaskStepEditCellItem]()
        for step in steps {
            let cellItem = TodoTaskStepEditCellItem(step: step)
            cellItems.append(cellItem)
        }
        
        return cellItems
    }
    
    override init(interactor: TodoTaskEditInteractor) {
        super.init(interactor: interactor)
        self.setupSeparatorFooterItem()
    }
    
    /// 开始或结束特定步骤的文本编辑
    func setTextEditing(_ isEditing: Bool, for step: TodoStep) {
        if let cell = stepEditCell(for: step) {
            cell.setTextEditing(isEditing)
        }
    }
    
    override func didSelectRow(at index: Int) {
        if let cell = cellForRow(at: index) as? TodoTaskStepEditCell {
            cell.setTextEditing(true)
        }
    }
    
    override func trailingSwipeActionsConfigurationForRow(at index: Int) -> UISwipeActionsConfiguration? {
        UIResponder.resignCurrentFirstResponder()
        guard let cellItem = item(at: index) as? TodoTaskStepEditCellItem else {
            return nil
        }
        
        /// 删除
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, completion in
            self.deleteStep(cellItem.step)
            completion(true)
        }
                            
        deleteAction.image = resGetImage("trash_24", color: .white)
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    // MARK: - TodoTaskStepEditCellDelegate
    func stepEditCellDidClickCheckbox(_ cell: TodoTaskStepEditCell) {
        guard let step = cell.step else {
            return
        }
        
        let isCompleted = !step.isCompleted
        updateStep(step, isCompleted: isCompleted)
    }
    
    func stepEditCellDidClickMore(_ cell: TodoTaskStepEditCell) {
        UIResponder.resignCurrentFirstResponder()
        guard let step = cell.step else {
            return
        }
        
        let menuController = TodoTaskStepMenuController(step: step)
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
            updateStep(step, name: name)
        } else {
            deleteStep(step)
        }
    }
    
    // MARK: - 任务步骤菜单操作
    func performTaskStepMenuAction(with type: TodoTaskStepMenuActionType, for step: TodoStep) {
        switch type {
        case .addPreviousStep:
            insertStep(isNext: false, relativeTo: step)
        case .addNextStep:
            insertStep(isNext: true, relativeTo: step)
        case .copyStep:
            copyStep(step)
        case .delete:
            deleteStep(step)
        }
    }
    
    private func copyStep(_ step: TodoStep) {
        UIPasteboard.general.string = step.content
        let message = resGetString("The step has been copied to the clipboard.")
        TPFeedbackQueue.common.postFeedback(text: message, position: .top)
    }

    // MARK: - 步骤操作
    func addStep(_ step: TodoStep, onTop: Bool) {
        if onTop {
            self.steps.insert(step, at: 0)
        } else {
            self.steps.append(step)
        }
        
        self.adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
        if let cellItem = cellItem(for: step) {
            self.adapter?.revealItem(cellItem, autoScroll: true)
        }
    }
    
    func updateStep(_ step: TodoStep, isCompleted: Bool) {
        guard step.isCompleted != isCompleted else {
            return
        }
        
        step.isCompleted = isCompleted
        self.stepsDidChange()
        if let cell = stepEditCell(for: step) {
            cell.updateCompleted(animated: true)
        }
    }
    
    func updateStep(_ step: TodoStep, name: String) {
        guard step.content != name else {
            return
        }
        
        step.content = name
        if let cell = stepEditCell(for: step) {
            updateText(name, forTextViewTableViewCell: cell)
        }
        
        self.stepsDidChange()
    }
    
    /// 创建特定步骤的上一步
    func insertStep(isNext: Bool, relativeTo step: TodoStep) {
        var steps: [TodoStep]
        if let parent = step.parent {
            steps = parent.subSteps
        } else {
            steps = self.steps
        }
        
        guard let index = steps.indexOf(step) else {
            return
        }
        
        let newStep = TodoStep(content: "", isCompleted: false)
        let insertIndex = isNext ? (index + 1) : index
        steps.insert(newStep, at: insertIndex)
        
        if let parent = step.parent {
            parent.subSteps = steps
        } else {
            self.steps = steps
        }
        
        self.adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
        self.setTextEditing(true, for: newStep)
    }
    
    func deleteStep(_ step: TodoStep) {
        self.steps.remove(step)
        self.adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
        self.stepsDidChange()
    }
    
    private func stepsDidChange() {
        IndentBasedTodoParser.printStepTree(self.steps)
        print("======================================\n\n")
    }
    
    // MARK: - Helpers
    /// 获取 step 对应的单元格
    private func cellItem(for step: TodoStep) -> TodoTaskStepEditCellItem? {
        guard let cellItems = adapter?.items(for: self) as? [TodoTaskStepEditCellItem] else {
            return nil
        }
        
        for cellItem in cellItems {
            if step.id == cellItem.step.id {
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


/*
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
*/
