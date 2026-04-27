//
//  TodoTaskEditNoteSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/11.
//

import Foundation

class TodoTaskEditNoteSectionController: TodoTaskEditBaseSectionController {

    /// 编辑
    private lazy var editCellItem: TPAutoResizeTextViewTableCellItem = { [weak self] in
        let cellItem = TPAutoResizeTextViewTableCellItem()
        cellItem.placeholder = resGetString("Add Note")
        cellItem.contentPadding = UIEdgeInsets(top: 15.0, left: 35.0, bottom: 10.0, right: 15.0)
        cellItem.textContainerInset = UIEdgeInsets(top: 0.0, left: 15.0, bottom: 5.0, right: 0.0)
        cellItem.font = BOLD_SYSTEM_FONT
        cellItem.isScrollEnabled = false
        cellItem.bounces = true
        cellItem.returnKeyType = .default
        cellItem.shouldShowDismissToolbar = true
        cellItem.minimumHeight = 240.0
        cellItem.maxCount = 960
        cellItem.didEndEditing = { textView in
            self?.noteTextViewDidEndEditing(textView)
        }

        return cellItem
    }()
    
    override init(interactor: TodoTaskEditInteractor) {
        super.init(interactor: interactor)
        self.cellItems = [editCellItem]
        self.editCellItem.text = task.note
    }
    
    /// 备注结束编辑
    private func noteTextViewDidEndEditing(_ textView: UITextView) {
        let note = textView.text.whitespacesAndNewlinesTrimmedString
        didChangeNote(note)
    }
    
    private func didChangeNote(_ note: String?) {
        interactor.setNote(note)
        reloadData()
    }
    
    /// 重新加载数据
    func reloadData() {
        editCellItem.text = task.note
        adapter?.reloadCell(forItems: [editCellItem], with: .none)
    }
}
