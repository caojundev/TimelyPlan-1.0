//
//  PieChartCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/27.
//

import Foundation
import UIKit

class PieChartSectionController: TPCollectionItemSectionController {
    
    var visual: PieVisual {
        get {
            return cellItem.visual
        }
        
        set {
            cellItem.visual = newValue
        }
    }

    var cellItem = PieChartCellItem()
    
    override init() {
        super.init()
        self.layout.edgeMargins = UIEdgeInsets(horizontal: 16.0, vertical: 8.0)
        self.cellItems = [cellItem]
    }
}

class PieChartCellItem: StatsBaseChartCellItem {
    
    /// 圆环内部标题
    var innerTitle: TextRepresentable?
    var innerTitleConfig: TPLabelConfig = TPLabelConfig.titleConfig
    
    var innerSubtitle: TextRepresentable?
    var innerSubtitleConfig = TPLabelConfig.subtitleConfig
    
    /// 可视对象
    var visual: PieVisual = PieVisual(slices: [])

    /// 图表尺寸
    var chartHeight: CGFloat = 240.0
    
    /// 排行列表行高
    var rankListRowHeight = 60.0
    
    /// 排行列表高度
    var rankListHeight: CGFloat {
        let slicesCount = visual.slices?.count ?? 0
        var linesCount = slicesCount / 2
        if slicesCount % 2 != 0 {
            linesCount += 1
        }
        
        return CGFloat(linesCount) * rankListRowHeight
    }
    
    override init() {
        super.init()
        self.contentPadding = UIEdgeInsets(horizontal: 5.0, vertical: 10.0)
        self.registerClass = PieChartCell.self
        self.canHighlight = false
        
        self.innerTitleConfig.textColor = resGetColor(.title)
        self.innerTitleConfig.textAlignment = .center
        self.innerTitleConfig.adjustsFontSizeToFitWidth = true
        self.innerTitleConfig.font = UIFont.boldSystemFont(ofSize: 24.0)
        
        self.innerSubtitleConfig.textAlignment = .center
        self.innerSubtitleConfig.adjustsFontSizeToFitWidth = true
        self.innerSubtitleConfig.font = UIFont.boldSystemFont(ofSize: 12.0)
    }
    
    override var size: CGSize? {
        get {
            var height = contentPadding.verticalLength
            if !isHeaderHidden {
                height += headerHeight
            }
            
            height += chartHeight
            height += rankListHeight
            return CGSize(width: .greatestFiniteMagnitude, height: height)
        }
        
        set {}
    }
}

class PieChartCell: StatsBaseChartCell {
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            let cellItem = cellItem as! PieChartCellItem
            chartView.innerTitle = cellItem.innerTitle
            chartView.innerTitleConfig = cellItem.innerTitleConfig
            
            chartView.innerSubtitle = cellItem.innerSubtitle
            chartView.innerSubtitleConfig = cellItem.innerSubtitleConfig
            
            chartHeight = cellItem.chartHeight
            chartView.visual = cellItem.visual
            
            rankListHeight = cellItem.rankListHeight
            rankListView.rowHeight = cellItem.rankListRowHeight
            rankListView.visual = cellItem.visual
            rankListView.reloadData()
            setNeedsLayout()
        }
    }
    
    /// 图标尺寸
    var chartHeight: CGFloat = 240.0
    
    var rankListHeight: CGFloat = 0.0
    
    /// 饼状视图
    var chartView: PieChartView!
    
    /// 排行列表视图
    var rankListView: PieRankListView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.chartView = PieChartView()
        contentView.addSubview(self.chartView)
        
        self.rankListView = PieRankListView(frame: .zero)
        self.rankListView.didSelectSlice = {[weak self] slice in
            self?.selectPieSlice(slice)
        }
        
        contentView.addSubview(self.rankListView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = chartLayoutFrame()
        chartView.width = layoutFrame.width
        chartView.height = chartHeight
        chartView.top = layoutFrame.minY
        chartView.alignHorizontalCenter()
        
        rankListView.width = layoutFrame.width
        rankListView.height = rankListHeight
        rankListView.left = layoutFrame.minX
        rankListView.top = chartView.bottom
    }
    
    func selectPieSlice(_ slice: PieSlice) {
        guard let visual = chartView.visual, let index = visual.slices?.firstIndex(of: slice) else {
            return
        }
        
        
        if let highlightedIndex = chartView.highlightedSliceIndex,
           highlightedIndex == index {
            chartView.clearHighlight()
        } else {
            chartView.highlightSlice(at: index)
        }
    }
    
}
