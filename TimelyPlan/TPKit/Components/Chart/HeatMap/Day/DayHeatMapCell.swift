//
//  DayHeatMapCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/12.
//

import Foundation

class DayHeatMapSectionController: TPCollectionItemSectionController,
                                   DayHeatMapViewDelegate {
    
    var levelIndexForDate: ((Date) -> Int)?
    
    let cellItem = DayHeatMapCellItem()
    
    var levelsCount: Int {
        return cellItem.levels.count
    }
    
    override init() {
        super.init()
        self.layout.edgeMargins = UIEdgeInsets(horizontal: 16.0, vertical: 8.0)
        self.cellItem.contentPadding = UIEdgeInsets(value: 10.0)
        self.cellItem.delegate = self
        self.cellItems = [cellItem]
    }
    
    // MARK: - HeatMapViewDelegate
    func dayHeatMapView(_ view: DayHeatMapView, levelOnDate date: Date) -> Int {
        let levelIndex = levelIndexForDate?(date) ?? 0
        return levelIndex
    }
}

class DayHeatMapCellItem: StatsBaseChartCellItem {
    
    /// 热力图显示该日期所在年
    var date: Date = Date()
    
    /// 分级
    lazy var levels: [HeatMapLevel] = {
        return DayHeatMapView.defaultLevels()
    }()
    
    /// 描述
    lazy var mapInfo: HeatMapInfo? = {
        return DayHeatMapView.defaultMapInfo()
    }()
    
    override init() {
        super.init()
        self.registerClass = DayHeatMapCell.self
        self.canHighlight = false
        self.isHeaderHidden = true
        self.headerHeight = 0.0
        self.height = 240.0
    }
}

class DayHeatMapCell: StatsBaseChartCell {
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            reloadData()
        }
    }
    
    var heatMapView: DayHeatMapView!
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.isHeaderHidden = true
        self.headerHeight = 0.0
        self.heatMapView = DayHeatMapView(frame: contentView.bounds)
        contentView.addSubview(self.heatMapView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        heatMapView.frame = chartLayoutFrame()
    }
    
    func reloadData() {
        let cellItem = cellItem as! DayHeatMapCellItem
        heatMapView.delegate = cellItem.delegate as? DayHeatMapViewDelegate
        heatMapView.date = cellItem.date
        heatMapView.levels = cellItem.levels
        heatMapView.mapInfo = cellItem.mapInfo
        heatMapView.reloadData()
        
        /// 滚动到当前月份
        heatMapView.scrollToCurrentMonth(animated: false)
    }
}
