//
//  StatsSummarySectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/9.
//

import Foundation

class StatsSummarySectionController: TPCollectionItemSectionController {
    
    var summaries: [StatsSummary] = [] {
        didSet {
            var cellItems = [StatsSummaryCellItem]()
            for summary in summaries {
                let cellItem = StatsSummaryCellItem(summary: summary)
                cellItems.append(cellItem)
            }
            
            self.cellItems = cellItems
        }
    }
    
    override init() {
        super.init()
        self.layout.interitemSpacing = 10.0
        self.layout.lineSpacing = 10.0
        self.layout.minimumItemsCountPerRow = 2
        self.layout.maximumItemsCountPerRow = 2
        self.layout.preferredItemHeight = 110.0
        self.layout.edgeMargins = UIEdgeInsets(horizontal: 16.0, vertical: 8.0)
    }
}

class StatsSummaryCellItem: TPCollectionCellItem {
    
    var summary: StatsSummary
    
    init(summary: StatsSummary) {
        self.summary = summary
        super.init()
        self.registerClass = StatsSummaryCell.self
        self.contentPadding = UIEdgeInsets(value: 15.0)
        self.canHighlight = false
    }
}
