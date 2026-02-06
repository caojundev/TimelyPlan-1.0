//
//  StatsCurveChartCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/24.
//

import Foundation

class StatsCurveChartCellItem: StatsBaseChartCellItem {
    
    /// 图表条目
    var chartItem: CurveChartItem?
   
    override init() {
        super.init()
        self.registerClass = StatsCurveChartCell.self
    }
}

class StatsCurveChartCell: StatsBaseChartCell {
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            reloadData()
        }
    }
    
    var chartView: CurveChartView!
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        chartView = CurveChartView()
        contentView.addSubview(chartView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = chartLayoutFrame()
    }
    
    func reloadData() {
        guard let cellItem = cellItem as? StatsCurveChartCellItem,let chartItem = cellItem.chartItem else {
                  return
        }
        
        chartView.strokeChart(with: chartItem)
    }
}


