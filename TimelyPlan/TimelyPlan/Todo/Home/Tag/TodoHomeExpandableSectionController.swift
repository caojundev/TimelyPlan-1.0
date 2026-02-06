//
//  TodoHomeExpandableSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/16.
//

import Foundation

class TodoHomeExpandableSectionController: TPTableItemSectionController {
    
    var isExpanded: Bool {
        get {
            return cellItem.isExpanded
        }

        set {
            cellItem.isExpanded = newValue
        }
    }
    
    var didToggleExpand: ((Bool) -> Void)? {
        get {
            return cellItem.didToggleExpand
        }
        
        set {
            cellItem.didToggleExpand = newValue
        }
    }
    
    /// 点击添加按钮
    var didClickAdd: ((UIButton) -> Void)? {
        get {
            return cellItem.didClickRightButton
        }
        
        set {
            cellItem.didClickRightButton = newValue
        }
    }
    
    lazy var cellItem: TPExpandImageInfoRightButtonTableCellItem = {
        let  cellItem = TPExpandImageInfoRightButtonTableCellItem()
        cellItem.imageConfig.shouldRenderImageWithColor = false
        cellItem.titleConfig.font = BOLD_SYSTEM_FONT
        cellItem.rightButtonImageName = "plus_24"
        cellItem.rightButtonNormalImageColor = .secondaryLabel
        return cellItem
    }()
    
    override init() {
        super.init()
        self.cellItems = [cellItem]
    }
    
    override func didSelectRow(at index: Int) {
        TPImpactFeedback.impactWithSoftStyle()
        let isExpanded = !isExpanded
        setExpanded(isExpanded, animated: true)
        didToggleExpand?(isExpanded)
    }
    
    private func setExpanded(_ isExpanded: Bool, animated: Bool) {
        guard self.isExpanded != isExpanded else {
            return
        }

        self.isExpanded = isExpanded
        guard let cell = adapter?.cellForItem(cellItem) as? TPExpandImageInfoRightButtonTableCell else {
            return
        }
        
        cell.setExpanded(isExpanded, animated: animated)
    }
}
