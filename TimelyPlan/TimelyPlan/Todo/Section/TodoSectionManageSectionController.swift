//
//  TodoSectionManageSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/3.
//

import Foundation

class TodoSectionManageSectionController: TPTableBaseSectionController,
                                          TPTableDragInsertReorderDelegate {

    var sections: [TodoSection]?
    
    let viewModel: TodoSectionViewModel
    
    let cellStyle = TPTableCellStyle()
    
    init(viewModel: TodoSectionViewModel) {
        self.viewModel = viewModel
        super.init()
        self.sections = viewModel.sections
        self.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.cellStyle.selectedBackgroundColor = .tertiarySystemFill
    }
    
    override var items: [ListDiffable]? {
        return sections
    }
    
    override func heightForHeader() -> CGFloat {
        return 15.0
    }
    
    override func heightForRow(at index: Int) -> CGFloat {
        return 60.0
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return TodoSectionManageCell.self
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        guard let cell = cell as? TodoSectionManageCell,
              let section = item(at: index) as? TodoSection else {
                  return
              }
        
        cell.style = cellStyle
        cell.section = section
    }
    
    override func didSelectRow(at index: Int) {
        guard let section = item(at: index) as? TodoSection else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        editSection(section)
    }
    
    override func trailingSwipeActionsConfigurationForRow(at index: Int) -> UISwipeActionsConfiguration? {
        guard let section = item(at: index) as? TodoSection else {
            return nil
        }
        
        ///< 编辑
        let editAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            TPImpactFeedback.impactWithSoftStyle()
            self.editSection(section)
            completion(true)
        }
        
        editAction.backgroundColor = Color(0x0091FF)
        editAction.image = resGetImage("edit_24", color: .white)
        
        ///< 删除
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, completion in
            TPImpactFeedback.impactWithSoftStyle()
            self.deleteSection(section)
            completion(true)
        }
                            
        deleteAction.image = resGetImage("trash_24", color: .white)
        
        let actions = [deleteAction, editAction]
        return UISwipeActionsConfiguration(actions: actions)
    }

    func createNewSection() {
        let title = resGetString("New Section")
        let vc = TPTextFieldAlertController(title: title) { name in
            if let name = name, name.count > 0 {
                self.viewModel.createSection(with: name)
            }
        }
        
        vc.selectAllAtBeginning = false
        vc.textField.textAlignment = .left
        vc.textField.font = BOLD_SYSTEM_FONT
        vc.textField.textColor = .label
        vc.show()
    }
    
    func editSection(_ section: TodoSection) {
        let title = resGetString("Edit Section")
        let vc = TPTextFieldAlertController(title: title) { name in
            if let name = name, name.count > 0 {
                self.viewModel.updateSection(section, with: name)
            }
        }
        
        vc.text = section.name
        vc.selectAllAtBeginning = false
        vc.textField.textAlignment = .left
        vc.textField.font = BOLD_SYSTEM_FONT
        vc.textField.textColor = .label
        vc.show()
    }
    
    func deleteSection(_ section: TodoSection) {
        let deleteAction = TPAlertAction(type: .destructive, title: resGetString("Delete")) { action in
            self.viewModel.deleteSection(section)
        }
        
        let cancelAction = TPAlertAction(type: .cancel, title: resGetString("Cancel"))
        let format = resGetString("\"%@\" will be permanently deleted.")
        let taskName = section.name ?? resGetString("Untitled Section")
        let message = String(format: format, taskName)
        let alertController = TPAlertController(title: resGetString("Delete Section"),
                                                message: message,
                                                actions: [cancelAction, deleteAction])
        alertController.show()
    }
    
    // MARK: - TPTableDragInsertReorderDelegate
    func tableDragReorder(_ reorder: TPTableDragReorder, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableDragReorder(_ reorder: TPTableDragReorder, willBeginAt indexPath: IndexPath) {
        reorder.tableView.setEditing(false, animated: false)
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder,
                                canInsertRowTo targetIndexPath: IndexPath,
                                from sourceIndexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder,
                                inserRowTo targetIndexPath: IndexPath,
                                from sourceIndexPath: IndexPath,
                                depth: Int) -> IndexPath? {
        guard targetIndexPath.row != sourceIndexPath.row else {
            return nil
        }
        
        if viewModel.reorderSection(fromIndex: sourceIndexPath.row,
                                    toIndex: targetIndexPath.row) {
            adapter?.moveRow(at: sourceIndexPath, to: targetIndexPath)
            return targetIndexPath
        }
        
        return sourceIndexPath
    }
}

class TodoSectionManageCell: TPImageInfoTableCell {
    
    var section: TodoSection? {
        didSet {
            self.title = section?.name ?? resGetString("Untitled Section")
        }
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.imageConfig.shouldRenderImageWithColor = true
        self.imageConfig.color = resGetColor(.title)
        self.imageContent = .init(imageName: "todo_section_24")
    }
    
}
