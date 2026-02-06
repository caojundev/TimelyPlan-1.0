//
//  HourHeatMapCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/12.
//

import Foundation
import UIKit

class HourHeatMapSectionController: TPCollectionItemSectionController,
                                    HourHeatMapViewDelegate {
    
    var levelIndexForDateRange: ((DateRange) -> Int)?
    
    let cellItem = HourHeatMapCellItem()
    
    override init() {
        super.init()
        self.layout.edgeMargins = UIEdgeInsets(horizontal: 16.0, vertical: 8.0)
        self.cellItem.contentPadding = UIEdgeInsets(value: 10.0)
        self.cellItem.delegate = self
        self.cellItems = [cellItem]
    }
    
    // MARK: - HeatMapViewDelegate
    func hourHeatMapView(_ view: HourHeatMapView, levelForDateRange range: DateRange) -> Int {
        let levelIndex = levelIndexForDateRange?(range) ?? 0
        return levelIndex
    }
}

class HourHeatMapCellItem: StatsBaseChartCellItem {
    
    /// 热力图显示该日期所在日
    var date: Date = .now
    
    /// 分级
    lazy var levels: [HeatMapLevel] = {
        return HourHeatMapView.defaultLevels()
    }()
    
    /// 描述
    lazy var mapInfo: HeatMapInfo? = {
        return HourHeatMapView.defaultMapInfo()
    }()
    
    override init() {
        super.init()
        self.registerClass = HourHeatMapCell.self
        self.canHighlight = false
        self.height = 280.0
    }
}

class HourHeatMapCell: StatsBaseChartCell {
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            reloadData()
        }
    }
    
    var heatMapView: HourHeatMapView!

    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.isHeaderHidden = false
        self.headerHeight = 40.0
        self.headerHeight = 0.0
        self.heatMapView = HourHeatMapView(frame: contentView.bounds)
        contentView.addSubview(self.heatMapView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        heatMapView.frame = chartLayoutFrame()
    }
    
    func reloadData() {
        let cellItem = cellItem as! HourHeatMapCellItem
        heatMapView.date = cellItem.date
        heatMapView.delegate = cellItem.delegate as? HourHeatMapViewDelegate
        heatMapView.levels = cellItem.levels
        heatMapView.mapInfo = cellItem.mapInfo
        heatMapView.reloadData()
        
        heatMapView.scrollToCurrentHour(animated: false)
    }
}
