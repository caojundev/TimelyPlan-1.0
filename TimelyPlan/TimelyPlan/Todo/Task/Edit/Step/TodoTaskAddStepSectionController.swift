//
//  TodoTaskAddStepSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/30.
//

import Foundation
import UIKit

class TodoTaskAddStepSectionController: TPTableItemSectionController {
    
    /// 选中批量菜单类型
    var didSelectActionType: ((TodoTaskStepBulkMenuActionType) -> Void)?
    
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
        cellItem.rightButtonImageName = "ellipsis_vertical_24"
        cellItem.title = resGetString("Add Step")
        cellItem.titleConfig.textColor = cellItem.activeColor
        cellItem.imageConfig.color = cellItem.activeColor
        cellItem.isActive = true
        cellItem.didClickRightButton = { [weak self] button in
            self?.showMoreMenu(from: button)
        }
        
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
    
    func showMoreMenu(from sourceView: UIView) {
        let typeLists: [[TodoTaskStepBulkMenuActionType]] = [[.importSteps, .copyStepsAsMarkdown], [.deleteCompletedSteps]]
        let menuItems = TPMenuItem.items(with: typeLists) { type, action in
            if type == .copyStepsAsMarkdown {
                action.handleBeforeDismiss = true
            }
        
            action.handler = { _ in
                self.didSelectActionType?(type)
            }
        }

        let menuList = TPMenuListViewController()
        menuList.menuContentWidth = 200.0
        menuList.menuItems = menuItems
        menuList.popoverShow(from: sourceView,
                             sourceRect: sourceView.bounds,
                             isSourceViewCovered: true,
                             preferredPosition: .bottomLeft,
                             permittedPositions: [.topLeft, .bottomLeft])
    }
    
}
