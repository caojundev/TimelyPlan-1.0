//
//  TodoDateInfoEditor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/6.
//

import Foundation

protocol TodoDateInfoEditable: AnyObject  {
    
    var dateInfo: TaskDateInfo {get set}
    
    func setDate(_ date: Date, editType: DateRangeEditType)
}

class TodoDateInfoEditor: TodoDateInfoEditable {
    
    var dateInfo: TaskDateInfo {
        get {
            return editor.dateInfo
        }
        
        set {}
    }
    
    private let editor: TodoDateInfoEditable
    
    init(dateInfo: TaskDateInfo) {
        if dateInfo.style == .singleDay {
            self.editor = TodoSingleDateInfoEditor(dateInfo: dateInfo)
        } else {
            self.editor = TodoMultiDateInfoEditor(dateInfo: dateInfo)
        }
    }
    
    func setDate(_ date: Date, editType: DateRangeEditType) {
        self.editor.setDate(date, editType: editType)
    }
}
