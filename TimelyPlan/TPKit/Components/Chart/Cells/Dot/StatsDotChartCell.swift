//
//  StatsDotChartCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/30.
//

import Foundation

class StatsDotChartCellItem: StatsBaseChartCellItem {
    
    /// 图表条目
    var chartItem: PointChartItem?
   
    override init() {
        super.init()
        self.registerClass = StatsDotChartCell.self
    }
}

class StatsDotChartCell: StatsBaseChartCell {
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            reloadData()
        }
    }
    
    var chartView: PointChartView!
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        chartView = PointChartView()
        chartView.backgroundColor = .clear
        contentView.addSubview(chartView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = chartLayoutFrame()
    }
    
    func reloadData() {
        guard let cellItem = cellItem as? StatsDotChartCellItem,
              let chartItem = cellItem.chartItem  else {
            return
        }
        
        chartView.strokeChart(with: chartItem)
    }
}


