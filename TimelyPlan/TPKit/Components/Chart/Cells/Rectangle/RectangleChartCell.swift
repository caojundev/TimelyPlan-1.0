//
//  RectangleChartCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/4.
//

import Foundation

class RectangleChartSectionController: TPCollectionItemSectionController {
    
    var chartItem: RectangleChartItem? {
        get {
            return cellItem.chartItem
        }
        
        set {
            cellItem.chartItem = newValue
        }
    }
    
    var cellItem = RectangleChartCellItem()
    
    override init() {
        super.init()
        self.layout.edgeMargins = UIEdgeInsets(horizontal: 16.0, vertical: 8.0)
        self.cellItems = [cellItem]
    }
}

class RectangleChartCellItem: StatsBaseChartCellItem {
    
    /// 图表条目
    var chartItem: RectangleChartItem?
   
    override init() {
        super.init()
        self.registerClass = RectangleChartCell.self
    }
}

class RectangleChartCell: StatsBaseChartCell {
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            reloadData()
        }
    }
    
    var chartView: RectangleChartView!

    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.contentView.clipsToBounds = false
        self.clipsToBounds = false
        self.chartView = RectangleChartView()
        self.chartView.backgroundColor = .clear
        self.contentView.addSubview(self.chartView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = chartLayoutFrame()
    }
    
    func reloadData() {
        guard let cellItem = cellItem as? RectangleChartCellItem,
              let chartItem = cellItem.chartItem else {
            return
        }
    
        chartView.strokeChart(with: chartItem)
    }
}
