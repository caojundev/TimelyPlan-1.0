//
//  StatsDotChartSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/12.
//

import Foundation

class StatsDotChartSectionController: TPCollectionItemSectionController {
    
    var chartItem: PointChartItem? {
        get {
            return cellItem.chartItem
        }
        
        set {
            cellItem.chartItem = newValue
        }
    }
    
    lazy var cellItem: StatsDotChartCellItem = {
        return StatsDotChartCellItem()
    }()
    
    override init() {
        super.init()
        self.layout.edgeMargins = UIEdgeInsets(horizontal: 16.0, vertical: 8.0)
        self.cellItems = [cellItem]
    }
}
