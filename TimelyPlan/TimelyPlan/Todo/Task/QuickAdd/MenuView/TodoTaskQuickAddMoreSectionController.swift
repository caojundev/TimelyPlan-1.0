//
//  TodoTaskQuickAddMoreSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/14.
//

import Foundation
import UIKit

class TodoTaskQuickAddMoreSectionController: TPCollectionItemSectionController {
    
    lazy var moreCellItem: TPImageCollectionCellItem = { [weak self] in
        let cellItem = TPImageCollectionCellItem()
        cellItem.imageContent = .withName("ellipsis_24")
        cellItem.imageConfig.color = Color(light: 0x646566, dark: 0xabacad)
        cellItem.size = .size(8)
        
        let style = TPCollectionCellStyle()
        style.backgroundColor = .clear
        style.selectedBackgroundColor = .clear
        cellItem.style = style
        return cellItem
    }()

    override init() {
        super.init()
        self.layout.edgeMargins = .zero
        self.layout.lineSpacing = 0.0
        self.layout.interitemSpacing = 0.0
        self.cellItems = [moreCellItem]
    }
    
    override func didSelectItem(at index: Int) {
        super.didSelectItem(at: index)
        guard let cell = cellForItem(at: index) else {
            return
        }
        
        let settingView = TodoTaskQuickAddSettingView()
        settingView.show(from: cell,
                         sourceRect: cell.bounds.insetBy(dx: -10.0, dy: -10.0),
                         isCovered: false,
                         preferredPosition: .topRight,
                         permittedPositions: TPPopoverPosition.topPopoverPositions,
                         animated: true)
        
    }
    
}
