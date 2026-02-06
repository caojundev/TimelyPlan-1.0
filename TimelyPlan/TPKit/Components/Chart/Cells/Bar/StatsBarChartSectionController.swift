//
//  StatsBarChartSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/11.
//

import Foundation

class StatsBarChartSectionController: TPCollectionItemSectionController {
    
    var chartItem: BarChartItem? {
        get {
            return cellItem.chartItem
        }
        
        set {
            cellItem.chartItem = newValue
        }
    }
    
    lazy var cellItem: StatsBarChartCellItem = {
        return StatsBarChartCellItem()
    }()
    
    override init() {
        super.init()
        self.layout.edgeMargins = UIEdgeInsets(horizontal: 16.0, vertical: 8.0)
        self.cellItems = [cellItem]
    }
}
