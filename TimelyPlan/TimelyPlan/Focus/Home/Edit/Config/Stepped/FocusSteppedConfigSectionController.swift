//
//  FocusSteppedConfigSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/25.
//

import Foundation

class FocusSteppedConfigSectionController: TPTableItemSectionController,
                                            FocusTimerStepCellDelegate {
    
    /// 配置改变回调
    var didChangeConfig: ((FocusSteppedConfig) -> (Void))?
    
    /// 番茄时钟
    var config = FocusSteppedConfig()
    
    /// 是否至少有一个步骤
    var hasStep: Bool {
        return config.stepsCount > 0
    }
    
    /// 无步骤占位单元格
    lazy var noStepCellItem: TFPlaceholderTableCellItem = {
        let cellItem = TFPlaceholderTableCellItem()
        cellItem.height = 70.0
        cellItem.placeholderTitle = resGetString("No Step")
        return cellItem
    }()
    
    /// 添加步骤
    lazy var addStepCellItem: TPFullSizeButtonTableCellItem = {
        let cellItem = TPFullSizeButtonTableCellItem()
        cellItem.contentPadding = UIEdgeInsets(value: 10.0)
        cellItem.height = 76.0
        cellItem.buttonTitle = resGetString("Add Step")
        cellItem.buttonNormalTitleColor = .white
        cellItem.buttonNormalBackgroundColor = Color(0x4A4DFF)
        cellItem.buttonSelectedBackgroundColor = Color(0x4A4DFF).darkerColor
        cellItem.buttonCornerRadius = 12.0
        cellItem.updater = { [weak self] in
            guard let self = self else { return }
            self.addStepCellItem.isDisabled = !(self.config.canAddNewStep())
        }
        
        cellItem.didClickButton = { [weak self] _ in
            self?.addStep()
        }
        
        return cellItem
    }()
    
    override var cellItems: [TPBaseTableCellItem]? {
        get {
            var cellItems = [TPBaseTableCellItem]()
            if let stepCellItems = stepCellItems {
                cellItems.append(contentsOf: stepCellItems)
            } else {
                cellItems.append(noStepCellItem)
            }
            
            cellItems.append(addStepCellItem)
            return cellItems
        }
        
        set { }
    }

    private var reorder: TPTableDragInsertReorder!
    
    init(tableView: UITableView) {
        super.init()
        self.headerItem.height = 10.0
        self.reorder = TPTableDragInsertReorder(tableView: tableView)
        self.reorder.isEnabled = true
        self.reorder.delegate = self
    }
    
    func updateAddButtonEnabled() {
        self.adapter?.reloadCell(forItem: self.addStepCellItem, with: .none)
    }

    /// 添加步骤
    private func addStep() {
        let index = config.timerSteps?.count ?? 0
        createStep(at: index)
    }
    
    private func addPreviousStep(of step: FocusTimerStep) {
        guard let index = config.timerSteps?.firstIndex(of: step) else {
            return
        }
        
        createStep(at: index)
    }
    
    private func addNextStep(of step: FocusTimerStep) {
        guard let index = config.timerSteps?.firstIndex(of: step) else {
            return
        }
        
        createStep(at: index + 1)
    }
    
    /// 在索引处新建步骤
    private func createStep(at index: Int) {
        let vc = FocusTimerStepEditViewController()
        vc.didEndEditing = { step in
            self.config.insertStep(step, at: index)
            self.adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .fade)
            self.commitFocusAnimation(for: step)
            self.didChangeConfig?(self.config)
            self.updateAddButtonEnabled()
        }
        
        let navController = UINavigationController(rootViewController: vc)
//        navController.modalPresentationStyle = .formSheet
        navController.show()
    }
    
    /// 编辑步骤
    private func editStep(_ step: FocusTimerStep) {
        let vc = FocusTimerStepEditViewController(step: step)
        vc.didEndEditing = { newStep in
            guard newStep != step else {
                return
            }
            
            self.config.replaceStep(step, with: newStep)
            self.adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .automatic)
            self.commitFocusAnimation(for: newStep)
            self.didChangeConfig?(self.config)
        }
        
        let navController = UINavigationController(rootViewController: vc)
//        navController.modalPresentationStyle = .formSheet
        navController.show()
    }
    
    private func deleteStep(_ step: FocusTimerStep) {
        self.config.deleteStep(step)
        self.didChangeConfig?(config)
        self.adapter?.performUpdate(with: .fade, completion: nil)
        self.updateAddButtonEnabled()
    }
    
    // MARK: - FocusTimerStepCellDelegate
    func focusTimerStepCellDidClickMore(_ cell: FocusTimerStepCell) {
        guard let step = cell.step else {
            return
        }
        
        let menuController = FocusTimerStepMenuController()
        menuController.didSelectMenuActionType = { actionType in
            self.performMenuAction(actionType, for: step)
        }

        menuController.showMenu(from: cell.moreButton)
    }
        
    private func performMenuAction(_ type: FocusTimerStepMenuType, for step: FocusTimerStep) {
        switch type {
        case .addPreviousStep:
            self.addPreviousStep(of: step)
        case .addNextStep:
            self.addNextStep(of: step)
        case .edit:
            self.editStep(step)
        case .delete:
            self.deleteStep(step)
        }
    }
    
    override func trailingSwipeActionsConfigurationForRow(at index: Int) -> UISwipeActionsConfiguration? {
        guard let step = step(at: index) else {
            return nil
        }
        
        /// 编辑
        let editAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            self?.editStep(step)
            completion(true)
        }
           
        editAction.backgroundColor = .primary
        editAction.image = resGetImage("edit_24")
        
        /// 删除
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            self?.deleteStep(step)
            completion(true)
        }
                            
        deleteAction.image = resGetImage("trash_24")
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    // MARK: - Helpers
    /// 判断索引处是否为步骤计时器的步骤
    private func isStep(at index: Int) -> Bool {
        let indexPath = IndexPath(row: index, section: section)
        return isStep(at: indexPath)
    }
    
    private func isStep(at indexPath: IndexPath) -> Bool {
        let cellItem = adapter?.item(at: indexPath)
        return cellItem is FocusTimerStepCellItem
    }
    
    private func step(at index: Int) -> FocusTimerStep? {
        let indexPath = IndexPath(row: index, section: section)
        if let cellItem = adapter?.item(at: indexPath) as? FocusTimerStepCellItem {
            return cellItem.step
        }
        
        return nil
    }
    
    /// 步骤单元格条目数组
    private var stepCellItems: [FocusTimerStepCellItem]? {
        guard let steps = config.timerSteps, steps.count > 0 else {
            return nil
        }
        
        var cellItems: [FocusTimerStepCellItem] = []
        for step in steps {
            let cellItem = FocusTimerStepCellItem(step: step)
            cellItem.didSelectHandler = { [weak self] in
                self?.editStep(step)
            }
            
            cellItems.append(cellItem)
        }

        return cellItems
    }
    
    /// 获取step对应的单元格条目
    private func stepCellItem(for step: FocusTimerStep) -> FocusTimerStepCellItem? {
        guard let cellItems = adapter?.items(for: self), cellItems.count > 0 else {
            return nil
        }
         
        for cellItem in cellItems {
            if let cellItem = cellItem as? FocusTimerStepCellItem, cellItem.step == step {
                return cellItem
            }
        }
        
        return nil
    }
    
    private func commitFocusAnimation(for step: FocusTimerStep) {
        if let cellItem = self.stepCellItem(for: step) {
            self.adapter?.commitFocusAnimation(for: cellItem)
        }
    }
    
}

extension FocusSteppedConfigSectionController: TPTableDragInsertReorderDelegate {
    
    func tableDragReorder(_ reorder: TPTableDragReorder, canMoveRowAt indexPath: IndexPath) -> Bool {
        guard let sectionController = adapter?.object(at: indexPath.section) as? TPTableItemSectionController,
                sectionController === self else {
            return false
        }
        
        return isStep(at: indexPath.row)
    }
    
    func tableDragReorder(_ reorder: TPTableDragReorder, willBeginAt indexPath: IndexPath) {
        reorder.tableView.setEditing(false, animated: true)
    }
   
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, canInsertRowTo targetIndexPath: IndexPath, from sourceIndexPath: IndexPath) -> Bool {
        guard sourceIndexPath.section == targetIndexPath.section else {
            return false
        }
        
        return isStep(at: targetIndexPath.row)
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, inserRowTo targetIndexPath: IndexPath, from sourceIndexPath: IndexPath, depth: Int) -> IndexPath?{
        let bMoved = self.config.moveStep(fromIndex: sourceIndexPath.row, toIndex: targetIndexPath.row)
        if bMoved {
            adapter?.performUpdate()
            self.didChangeConfig?(self.config)
            return targetIndexPath
        } else {
            return sourceIndexPath
        }
    }
}

