//
//  StatsCurveChartSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/24.
//

import Foundation

class StatsCurveChartSectionController: TPCollectionItemSectionController {
    
    var chartItem: CurveChartItem? {
        get {
            return cellItem.chartItem
        }
        
        set {
            cellItem.chartItem = newValue
        }
    }
    
    var cellItem = StatsCurveChartCellItem()
    
    override init() {
        super.init()
        self.layout.edgeMargins = UIEdgeInsets(horizontal: 16.0, vertical: 8.0)
        self.cellItems = [cellItem]
    }
}
