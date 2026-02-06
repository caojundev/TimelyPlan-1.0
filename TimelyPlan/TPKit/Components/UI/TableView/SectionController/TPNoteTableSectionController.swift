//
//  TPNoteTableSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/28.
//

import Foundation

class TPNoteTableSectionController: TPTableItemSectionController {
    
    var placeholder: String? {
        didSet {
            noteCellItem.placeholder = placeholder
        }
    }
    
    var note: String? {
        didSet {
            noteCellItem.text = note
        }
    }
    
    var noteEditingChanged: ((String?) -> Void)?
    
    var noteDidEndEditing: ((String?) -> Void)?
    
    /// 备注单元格条目
    lazy var noteCellItem: TPAutoResizeTextViewTableCellItem = {[weak self] in
        let cellItem = TPAutoResizeTextViewTableCellItem()
        cellItem.minimumHeight = 180.0
        cellItem.contentPadding = UIEdgeInsets(horizontal: 15.0, vertical: 10.0)
        cellItem.placeholder = resGetString("Write down your thoughts")
        cellItem.isNewlineEnabled = false
        cellItem.textColor = resGetColor(.title)
        cellItem.editingChanged = { textView in
            let text = textView.text?.whitespacesAndNewlinesTrimmedString
            self?.note = text
            self?.noteEditingChanged?(text)
        }
        
        cellItem.didEndEditing = { textView in
            let text = textView.text?.whitespacesAndNewlinesTrimmedString
            self?.noteDidEndEditing?(text)
        }
        
        return cellItem
    }()
    
    override init() {
        super.init()
        self.headerItem.title = resGetString("Note")
        self.headerItem.height = 50.0
        self.cellItems = [noteCellItem]
    }
}
 
