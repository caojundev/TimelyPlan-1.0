//
//  TPSeparatorSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/8.
//

import Foundation

class TPSeparatorSectionController: TPTableItemSectionController {
    
    let separatorCellItem = TPSeparatorTableCellItem()
    
    override init() {
        super.init()
        self.cellItems = [separatorCellItem]
    }
}
