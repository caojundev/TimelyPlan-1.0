//
//  TodoParentListNoneSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/15.
//

import Foundation
import UIKit

class TodoParentListNoneSectionController: TPTableItemSectionController {
    
    /// 无父列表单元格条目
    lazy var noParentCellItem: TPCheckmarkTableCellItem = {
        let cellItem = TPCheckmarkTableCellItem()
        cellItem.contentPadding = UIEdgeInsets(left: 16.0, right: 10.0)
        cellItem.imageConfig.margins = UIEdgeInsets(right: 5.0)
        cellItem.imageName = "todo_list_noParent_24"
        cellItem.title = resGetString("No Parent List")
        cellItem.height = 50.0
        return cellItem
    }()
    
    override var items: [ListDiffable]? {
        return [noParentCellItem]
    }
    
    override init() {
        super.init()
        self.cellItems = [noParentCellItem]
        self.footerItem.height = 15.0
    }
    
    override func shouldShowCheckmarkForRow(at index: Int) -> Bool {
        return self.delegate?.tableSectionController(self, shouldShowCheckmarkForRowAt: index) ?? false
    }
}
