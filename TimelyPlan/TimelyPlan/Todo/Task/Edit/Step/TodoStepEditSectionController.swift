//
//  TodoStepEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/22.
//

import Foundation
import UIKit

class TodoStepExpansionState: ExpansionStateProviding {
    
    func isExpanded(_ item: Any) -> Bool {
        let step = item as! TodoStep
        return step.isExpanded
    }
    
    func setExpended(_ isExpended: Bool, for item: Any) {
        let step = item as! TodoStep
        step.isExpanded = isExpended
    }
}

class TodoStepEditSectionController: TPTableItemSectionController,
                                         TodoTaskStepEditCellDelegate {
    
    var steps: [TodoStep] = []
    
    override var items: [ListDiffable]? {
        let flattenSteps = steps.flattenItems(with: expansionState) as! [TodoStep]
        var cellItems = [TodoTaskStepEditCellItem]()
        for step in flattenSteps {
            let cellItem = TodoTaskStepEditCellItem(step: step)
            cellItems.append(cellItem)
        }
        
        return cellItems
    }
    
    private let expansionState = TodoStepExpansionState()
    
    init(steps: [TodoStep]) {
        super.init()
        self.steps = steps
    }

    func stepsDidChange() {

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
    
    // MARK: - TodoTaskStepEditCellDelegate
    func stepEditCellDidClickCheckbox(_ cell: TodoTaskStepEditCell) {
        UIResponder.resignCurrentFirstResponder()
        guard let step = cell.step else {
            return
        }
        
        let isCompleted = !step.isCompleted
        if isCompleted {
            step.isCompleted = true /// 当前操作步骤先设置
            var stepsToUpdate = [step]
            
            /// 检查父步骤
            let autoCompleteParentTask = TodoSetting.shared.autoCompleteParentTask
            if autoCompleteParentTask,
               let parent = step.parent,
               !parent.isCompleted,
               parent.isAllSubStepsCompleted() {
                stepsToUpdate.append(parent)
            }
            
            /// 完成子步骤
            let autoCompleteSubtasks = TodoSetting.shared.autoCompleteSubtasks
            if autoCompleteSubtasks, let notCompletedSteps = step.notCompletedSubSteps() {
                stepsToUpdate.append(contentsOf: notCompletedSteps)
            }
            
            completeSteps(stepsToUpdate)
        } else {
            /// 更新当前步骤
            updateStep(step, isCompleted: isCompleted)
        }
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

        let sourceRect = cell.moreButton.bounds.insetBy(dx: -5.0, dy: -5.0)
        menuController.showMenu(from: cell.moreButton,
                                sourceRect: sourceRect,
                                isCovered: true)
    }
    
    func stepEditCell(_ cell: TodoTaskStepEditCell, didToggleExpand isExpanded: Bool) {
        UIResponder.resignCurrentFirstResponder()
        guard let step = cell.step else {
            return
        }
        
        step.isExpanded = isExpanded
        self.stepsDidChange()
        self.adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
    }
    
    func textViewTableCell(_ cell: TPTextViewTableCell, didEndEditing textView: UITextView) {
        guard let cell = cell as? TodoTaskStepEditCell, let step = cell.step else {
            return
        }

        let name = textView.text.whitespacesAndNewlinesTrimmedString
        if name.count > 0 {
            updateStep(step, name: name)
        } else if step.subSteps.count == 0{
            /// 无子步骤，删除该步骤
            deleteStep(step)
        }
    }
    
    func textViewTableCell(_ cell: TPTextViewTableCell, didEnterReturn textView: UITextView) {
        guard let cell = cell as? TodoTaskStepEditCell, let step = cell.step else {
            return
        }

        insertStep(isNext: true, relativeTo: step)
    }
    
    // MARK: - 任务步骤菜单操作
    func performTaskStepMenuAction(with type: TodoTaskStepMenuActionType, for step: TodoStep) {
        switch type {
        case .addSubStep:
            addSubStep(of: step)
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
        let message = resGetString("The step has been copied to the clipboard")
        TPFeedbackQueue.common.postFeedback(text: message, position: .top)
    }

    // MARK: - 步骤操作
    private func addSubStep(of step: TodoStep) {
        let newStep = TodoStep(content: "", isCompleted: false)
        step.addSubStep(newStep)
        step.isExpanded = true
        self.adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
        self.setTextEditing(true, for: newStep)
    }
    
    func addStep(_ step: TodoStep, onTop: Bool) {
        if onTop {
            self.steps.insert(step, at: 0)
        } else {
            self.steps.append(step)
        }
        
        self.stepsDidChange()
        self.adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
        if let cellItem = cellItem(for: step) {
            self.adapter?.revealItem(cellItem, autoScroll: true)
        }
    }
    
    private func completeSteps(_ steps: [TodoStep]) {
        for step in steps {
            step.isCompleted = true
        }
        
        if let cells = visibleCellsForSteps(steps) {
            cells.forEach { cell in
                cell.updateCompleted(animated: true)
            }
        }
        
        self.stepsDidChange()
    }
    
    private func updateStep(_ step: TodoStep, isCompleted: Bool) {
        guard step.isCompleted != isCompleted else {
            return
        }
        
        step.isCompleted = isCompleted
        self.stepsDidChange()
        if let cell = stepEditCell(for: step) {
            cell.updateCompleted(animated: true)
        }
    }
    
    private func updateStep(_ step: TodoStep, name: String) {
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
        if let parent = step.parent {
            parent.insertSubStep(newStep, at: insertIndex)
            parent.isExpanded = true
        } else {
            self.steps.insert(newStep, at: insertIndex)
        }

        self.adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
        self.setTextEditing(true, for: newStep)
    }
    
    func deleteStep(_ step: TodoStep) {
        if let parent = step.parent {
            parent.removeSubStep(step)
        } else {
            self.steps.remove(step)
        }
        
        self.adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
        self.stepsDidChange()
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        super.didDequeCell(cell, forRowAt: index)
        guard let cell = cell as? TodoTaskStepEditCell, let step = cell.step else {
            return
        }

        cell.depthLineLevels = TodoStep.depthLineLevels(for: step, in: self.displaySteps)
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
    
    private func visibleCellsForSteps(_ steps: [TodoStep]) -> [TodoTaskStepEditCell]? {
        guard let visibleCells = adapter?.visibleCells else {
            return nil
        }
        
        var visibleStepCells = [TodoTaskStepEditCell]()
        for visibleCell in visibleCells {
            if let stepCell = visibleCell as? TodoTaskStepEditCell,
               let step = stepCell.step,
                steps.contains(step) {
                visibleStepCells.append(stepCell)
            }
        }
        
        return visibleStepCells
    }
    
    private var displaySteps: [TodoStep] {
        guard let cellItems = adapter?.items(for: self) as? [TodoTaskStepEditCellItem] else {
            return []
        }
        
        return cellItems.map { $0.step }
    }

    
    func step(at index: Int) -> TodoStep {
        let cellItem = item(at: index) as! TodoTaskStepEditCellItem
        return cellItem.step
    }
    
    /// 执行插入操作
    func reorderStep(in steps: [TodoStep], fromIndex: Int, toIndex: Int, depth: Int) {
        var items = steps
        items.moveObject(fromIndex: fromIndex, toIndex: toIndex)
        guard items.count > 1 else {
            return
        }
        
        let currentStep = items[toIndex]
        var sameDepthSteps = [currentStep]
        var parentStep: TodoStep?
        let aboveItems = items.elementsAbove(at: toIndex)
        for aboveItem in aboveItems {
            let itemDepth = aboveItem.depth
            if itemDepth == depth {
                sameDepthSteps.insert(aboveItem, at: 0)
            } else if itemDepth < depth {
                parentStep = aboveItem
                break
            }
        }
        
        /// 下方条目
        let belowItems = items.elementsBelow(at: toIndex)
        for belowItem in belowItems {
            let itemDepth = belowItem.depth
            if itemDepth == depth {
                sameDepthSteps.append(belowItem)
            } else if itemDepth < depth {
                break
            }
        }
        
        let currentParent = currentStep.parent
        if let parentStep = parentStep {
            var toIndex = sameDepthSteps.indexOf(currentStep) ?? 0
            if parentStep.id != currentParent?.id {
                if !parentStep.isExpanded {
                    /// 当主步骤未展开时插入到末尾
                    toIndex = parentStep.subSteps.count
                }
                
                parentStep.insertSubStep(currentStep, at: toIndex)
            } else {
                parentStep.moveSubStep(currentStep, to: toIndex)
            }
        } else {
            /// 移动到根列表
            currentParent?.removeSubStep(currentStep)
        }

        /// 更新顶层步骤
        let topSteps = items.filter { $0.parent == nil }
        self.steps = topSteps
        self.stepsDidChange()
    }
}

// MARK: - 列表排序
extension TodoStepEditSectionController: TPTableDragInsertReorderDelegate {
    
    func tableDragReorder(_ reorder: TPTableDragReorder, canMoveRowAt indexPath: IndexPath) -> Bool {
        /// 仅在当前区块可移动
        return indexPath.section == self.section
    }
    
    func tableDragReorder(_ reorder: TPTableDragReorder, willBeginAt indexPath: IndexPath) {
        /// 收起已展开的列表
        let step = step(at: indexPath.row)
        guard step.hasSubItem, self.expansionState.isExpanded(step) else {
            return
        }
        
        self.expansionState.setExpended(false, for: step)
        
        /// 更新列表
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .fade)
    }
    
    func tableDragReorderDidEnd(_ reorder: TPTableDragReorder) {
        /// 无操作
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, indentationLevelTo targetIndexPath: IndexPath, from sourceIndexPath: IndexPath, ratio: CGFloat) -> Int {
        return self.displaySteps.indentationLevel(to: targetIndexPath.row,
                                                  from: sourceIndexPath.row,
                                                  ratio: ratio)
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, focusIndexPathTo targetIndexPath: IndexPath, from sourceIndexPath: IndexPath, depth: Int) -> IndexPath? {
        guard let index = self.displaySteps.focusIndex(to: targetIndexPath.row,
                                                       from: sourceIndexPath.row,
                                                       depth: depth) else {
            return nil
        }

        return IndexPath(row: index, section: targetIndexPath.section)
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, canInsertRowTo targetIndexPath: IndexPath, from sourceIndexPath: IndexPath) -> Bool {
        guard sourceIndexPath.section == targetIndexPath.section else {
            return false
        }
        
        return self.displaySteps.canInsertItem(at: sourceIndexPath.row, to: targetIndexPath.row)
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder,
                                inserRowTo targetIndexPath: IndexPath,
                                from sourceIndexPath: IndexPath,
                                depth: Int) -> IndexPath? {
        let step = step(at: sourceIndexPath.row)
        if sourceIndexPath.row == targetIndexPath.row, step.depth == depth {
            /// 行和深度都相同则不做处理
            return sourceIndexPath
        }
        
        reorderStep(in: displaySteps, fromIndex: sourceIndexPath.row, toIndex: targetIndexPath.row, depth: depth)
        expansionState.expandAllParent(of: step, includeCurrent: false)
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
        
        /// 重新排序完成返回新索引
        var newIndexPath: IndexPath? = nil
        if let newIndex = displaySteps.indexOf(step) {
            newIndexPath = IndexPath(row: newIndex, section: targetIndexPath.section)
        }

        return newIndexPath
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, canFlashRowAt indexPath: IndexPath, from sourceIndexPath: IndexPath) -> Bool {
        let step = step(at: indexPath.row)
        guard !expansionState.isExpanded(step), step.hasSubItem else {
            return false
        }

        /// 判断是否可以移进目标清单
        return self.displaySteps.canMoveItem(at: sourceIndexPath.row, intoItemAt: indexPath.row)
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, didFlashRowAt indexPath: IndexPath, from sourceIndexPath: IndexPath) {
        let fromStep = step(at: sourceIndexPath.row)
        let touchStep = step(at: indexPath.row)
        guard !expansionState.isExpanded(touchStep) else {
            return
        }
        
        expansionState.setExpended(true, for: touchStep)
        /// 更新列表
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
        
        /// 更新当前拖动索引
        var indexPath: IndexPath? = nil
        if let newIndex = displaySteps.indexOf(fromStep) {
            indexPath = IndexPath(row: newIndex, section: section)
        }
        
        reorder.changeDraggingIndexPath(indexPath)
    }
}
