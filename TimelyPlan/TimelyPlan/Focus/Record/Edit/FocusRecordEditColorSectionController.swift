//
//  FocusRecordEditColorSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/15.
//

import Foundation
import UIKit

class FocusRecordEditColorSectionController: TPTableItemSectionController {
    
    var color: UIColor?
    
    var didSelectColor: ((UIColor?) -> Void)?
    
    /// 颜色单元格
    lazy var colorCellItem: TPDefaultInfoColorValueTableCellItem = { [weak self] in
        let cellItem = TPDefaultInfoColorValueTableCellItem()
        cellItem.title = resGetString("Color")
        cellItem.height = 55.0
        cellItem.updater = {
            self?.colorCellItem.color = self?.color ?? kFocusSessionDefaultColor
        }
        
        cellItem.didSelectHandler = {
            self?.selectColor()
        }
        
        return cellItem
    }()
    
    override init() {
        super.init()
        self.cellItems = [colorCellItem]
    }
    
    private func selectColor() {
        guard let cell = adapter?.cellForItem(colorCellItem) else {
            return
        }
        
        let selectView = TPColorSelectPopoverView()
        selectView.colors = UIColor.focusSessionColors
        selectView.selectedColor = .focusSessionDefaultColor
        selectView.didSelectColor = { color in
            self.color = color
            self.adapter?.reloadCell(forItem: self.colorCellItem, with: .none)
            self.didSelectColor?(color)
        }
        
        selectView.reloadData()
        selectView.show(from: cell.contentView,
                        sourceRect: cell.contentView.bounds,
                        isCovered: false,
                        preferredPosition: .bottomLeft,
                        permittedPositions: [.bottomLeft],
                        animated: true)
    }
}
