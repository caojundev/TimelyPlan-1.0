//
//  TodoListSelectInboxSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/15.
//

import Foundation
import UIKit

class TodoListSelectInboxSectionController: TPTableItemSectionController {
    
    var didSelectInbox: (() -> Void)? {
        didSet {
            inboxCellItem.didSelectHandler = didSelectInbox
        }
    }
    
    /// 收件箱单元格条目
    lazy var inboxCellItem: TPCheckmarkTableCellItem = {
        let cellItem = TPCheckmarkTableCellItem()
        cellItem.contentPadding = UIEdgeInsets(left: 20.0, right: 10.0)
        cellItem.height = 50.0
        cellItem.title = resGetString("Inbox")
        cellItem.imageName = "todo_list_inbox_24"
        cellItem.imageConfig.color = .primary
        cellItem.imageConfig.margins = UIEdgeInsets(value: 5.0)
        return cellItem
    }()
    
    override init() {
        super.init()
        self.cellItems = [inboxCellItem]
    }
    
    override func shouldShowCheckmarkForRow(at index: Int) -> Bool {
        let bShow = delegate?.tableSectionController(self, shouldShowCheckmarkForRowAt: index)
        return bShow ?? false
    }
}
