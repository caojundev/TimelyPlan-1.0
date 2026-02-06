//
//  FocusEndSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/13.
//

import Foundation

class FocusEndSectionController: TPCollectionItemSectionController {
    
    let dataItem: FocusEndDataItem
   
    init(dataItem: FocusEndDataItem) {
        self.dataItem = dataItem
        super.init()
        self.layout.edgeMargins = UIEdgeInsets(horizontal: 16.0, vertical: 8.0)
        self.layout.minimumItemsCountPerRow = 1
        self.layout.maximumItemsCountPerRow = 1
        self.layout.lineSpacing = 15.0
        self.layout.preferredItemWidth = 560.0
        self.layout.preferredItemHeight = .greatestFiniteMagnitude
    }
    
}
