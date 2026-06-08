//
//  TodoTaskMoveInboxListCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/6.
//

import Foundation

class TodoTaskMoveInboxListCellItem: TPImageInfoRightExpandCellItem {

    override init() {
        super.init()
        self.registerClass = TodoTaskMoveInboxCell.self
        self.contentPadding = UIEdgeInsets(left: 16.0, right: 16.0)
        self.height = 50.0
        self.title = resGetString("Inbox")
        self.imageName = "todo_list_inbox_24"
        self.imageConfig.color = .primary
        self.imageConfig.margins = UIEdgeInsets(right: 5.0)
    }
}

class TodoTaskMoveInboxCell: TPImageInfoRightExpandCell {
    
    override func updateCellStyle() {
        super.updateCellStyle()
        let titleConfig = titleConfig
        if isChecked {
            titleConfig.textColor = .primary
        } else {
            titleConfig.textColor = resGetColor(.title)
        }
        
        imageInfoView.titleConfig = titleConfig
    }
    
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        updateCellStyle()
    }
}
