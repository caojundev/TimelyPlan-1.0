//
//  StatsBarChartCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/28.
//

import Foundation

class StatsBarChartCellItem: StatsBaseChartCellItem {
    
    /// 图表条目
    var chartItem: BarChartItem?
   
    override init() {
        super.init()
        self.registerClass = StatsBarChartCell.self
    }
}

class StatsBarChartCell: StatsBaseChartCell {
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            reloadData()
        }
    }
    
    var chartView: BarChartView!
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.contentView.clipsToBounds = false
        self.clipsToBounds = false
        self.chartView = BarChartView()
        self.chartView.backgroundColor = .clear
        self.contentView.addSubview(self.chartView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = chartLayoutFrame()
    }
    
    func reloadData() {
        guard let cellItem = cellItem as? StatsBarChartCellItem,
              let chartItem = cellItem.chartItem else {
            return
        }
        
        chartView.strokeChart(with: chartItem)
    }
}
