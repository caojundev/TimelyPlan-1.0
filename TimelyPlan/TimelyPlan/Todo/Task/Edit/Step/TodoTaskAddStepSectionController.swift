//
//  TodoTaskAddStepSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/30.
//

import Foundation
import UIKit

class TodoTaskAddStepSectionController: TPTableItemSectionController {
    
    var didClickAdd: (() -> Void)? {
        didSet {
            addCellItem.didSelectHandler = didClickAdd
        }
    }
    
    override var cellItems: [TPBaseTableCellItem]? {
        get {
            if isEditing { return nil }
            return [addCellItem]
        }
        
        set {}
    }
    
    /// 添加单元格条目
    lazy var addCellItem: TodoTaskEditTableCellItem = {
        let cellItem = TodoTaskEditTableCellItem()
        cellItem.imageName = "plus_24"
        cellItem.title = resGetString("Add Step")
        cellItem.titleConfig.textColor = cellItem.activeColor
        cellItem.imageConfig.color = cellItem.activeColor
        return cellItem
    }()
    
    override init() {
        super.init()
        self.setupSeparatorFooterItem()
    }
    
    private var isEditing: Bool = false
    
    func setEditing(_ isEditing: Bool) {
        guard self.isEditing != isEditing else {
            return
        }
        
        self.isEditing = isEditing
        self.adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .fade)
    }
}
