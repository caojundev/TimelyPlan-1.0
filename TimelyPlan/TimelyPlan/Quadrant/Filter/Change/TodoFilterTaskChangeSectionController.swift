//
//  TodoFilterTaskChangeSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/19.
//

import Foundation
import UIKit

class TodoFilterTaskChangeSectionController: TPTableItemSectionController {
    
    /// 类型单元格条目
    private lazy var changeCellItem: TPImageInfoCircularCheckboxTableCellItem = { [weak self] in
        let cellItem = TPImageInfoCircularCheckboxTableCellItem()
        cellItem.imageConfig.shouldRenderImageWithColor = false
        cellItem.imageConfig.size = .large
        cellItem.subtitleConfig.font = UIFont.systemFont(ofSize: 10.0)
        cellItem.imageName = filterType.iconName
        cellItem.title = filterType.title
        cellItem.updater = {
            self?.updateChangeCellItem()
        }
        
        return cellItem
    }()
    
    let filterType: TodoFilterType
    
    let change: TodoTaskChange
    
    convenience init?(change: TodoTaskChange) {
        guard let filterType = change.filterType else {
            return nil
        }
        
        self.init(filterType: filterType, change: change)
    }
    
    init(filterType: TodoFilterType, change: TodoTaskChange) {
        self.filterType = filterType
        self.change = change
        super.init()
        self.headerItem.height = 10.0
        self.cellItems = [changeCellItem]
    }

    override func shouldShowCheckmarkForRow(at index: Int) -> Bool {
        guard index == 0 else {
            return false
        }
        
        return delegate?.tableSectionController(self, shouldShowCheckmarkForRowAt: index) ?? false
    }
    
    override func didSelectRow(at index: Int) {
        delegate?.tableSectionController(self, didSelectRowAt: index)
    }
    
    func updateChangeCellItem() {
        changeCellItem.subtitle = change.attributedDescription
    }
}
