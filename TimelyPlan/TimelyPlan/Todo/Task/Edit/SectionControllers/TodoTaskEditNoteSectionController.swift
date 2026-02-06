//
//  TodoTaskEditNoteSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/11.
//

import Foundation

class TodoTaskEditNoteSectionController: TPTableItemSectionController {

    /// 备注
    lazy var noteCellItem: TodoTaskEditTableCellItem = { [weak self] in
        let cellItem = TodoTaskEditTableCellItem()
        cellItem.imageName = "todo_task_note_24"
        cellItem.title = resGetString("Note")
        cellItem.updater = {
            self?.updateNoteCellItem()
        }
        
        cellItem.didClickRightButton = { _ in
            self?.confirmNoteDeletion()
        }
        
        return cellItem
    }()

    /// 编辑
    private lazy var editCellItem: TPAutoResizeTextViewTableCellItem = { [weak self] in
        let cellItem = TPAutoResizeTextViewTableCellItem()
        cellItem.contentPadding = UIEdgeInsets(top: 5.0, left: 35.0, bottom: 5.0, right: 15.0)
        cellItem.textContainerInset = UIEdgeInsets(top: 0.0, left: 15.0, bottom: 5.0, right: 0.0)
        cellItem.font = BOLD_SYSTEM_FONT
        cellItem.isScrollEnabled = false
        cellItem.bounces = true
        cellItem.returnKeyType = .default
        cellItem.shouldShowDismissToolbar = true
        cellItem.minimumHeight = 80.0
        cellItem.maxCount = 120
        cellItem.didEndEditing = { textView in
            self?.noteTextViewDidEndEditing(textView)
        }

        return cellItem
    }()
    
    let task: TodoTask
    
    init(task: TodoTask) {
        self.task = task
        super.init()
        self.cellItems = [noteCellItem, editCellItem]
        self.editCellItem.text = task.note
    }
    
    override func didSelectRow(at index: Int) {
        if index == 0 {
            guard let cell = adapter?.cellForItem(editCellItem) as? TPTextViewTableCell else {
                return
            }
            
            cell.textView.becomeFirstResponder()
        }
    }
    
    private func updateNoteCellItem() {
        if let note = task.note, note.count > 0 {
            noteCellItem.isActive = true
        } else {
            noteCellItem.isActive = false
        }
    }
    
    /// 备注结束编辑
    private func noteTextViewDidEndEditing(_ textView: UITextView) {
        let note = textView.text.whitespacesAndNewlinesTrimmedString
        didChangeNote(note)
    }
    
    private func confirmNoteDeletion() {
        let deleteAction = TPAlertAction(type: .destructive,
                                         title: resGetString("Delete")) { action in
            self.didChangeNote(nil)
        }
        
        let cancelAction = TPAlertAction(type: .cancel,
                                         title: resGetString("Cancel"))
        let message = resGetString("Are you sure you want to permanently delete this note?")
        let alertController = TPAlertController(title: resGetString("Delete Note"),
                                                message: message,
                                                actions: [cancelAction, deleteAction])
        alertController.show()
    }
    
    private func didChangeNote(_ note: String?) {
        todo.updateTask(task, note: note)
        reloadData()
    }
    
    /// 重新加载数据
    func reloadData() {
        editCellItem.text = task.note
        adapter?.reloadCell(forItems: [noteCellItem, editCellItem], with: .none)
    }
}
