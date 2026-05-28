//
//  BarRankListChartCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/28.
//

import Foundation
import UIKit

class BarRankListChartSectionController: TPCollectionItemSectionController {
    
    var listItem: BarRankListItem? {
        get {
            return cellItem.listItem
        }
        
        set {
            cellItem.listItem = newValue
        }
    }
    
    let cellItem = BarRankListChartCellItem()
    
    override init() {
        super.init()
        self.layout.edgeMargins = UIEdgeInsets(horizontal: 8.0, vertical: 8.0)
        self.cellItems = [cellItem]
    }
}

class BarRankListChartCellItem: StatsBaseChartCellItem {
        
    var listItem: BarRankListItem?
    
    /// 排行列表高度
    var emptyListHeight = 120.0
    var rankListHeight: CGFloat {
        guard let listItem = listItem, listItem.slices.count > 0 else {
            return emptyListHeight
        }
        
        return CGFloat(listItem.slices.count) * listItem.rowHeight
    }
    
    override init() {
        super.init()
        self.contentPadding = UIEdgeInsets(horizontal: 5.0, vertical: 10.0)
        self.registerClass = BarRankListChartCell.self
    }
    
    override var size: CGSize? {
        get {
            var height = contentPadding.verticalLength
            if !isHeaderHidden {
                height += headerHeight
            }
            
            height += rankListHeight
            return CGSize(width: .greatestFiniteMagnitude, height: height)
        }
        
        set {}
    }
}

class BarRankListChartCell: StatsBaseChartCell {
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            let cellItem = cellItem as! BarRankListChartCellItem
            rankListHeight = cellItem.rankListHeight
            rankListView.listItem = cellItem.listItem
            rankListView.reloadData()
            setNeedsLayout()
        }
    }
    
    var rankListHeight: CGFloat = 0.0
    
    /// 排行列表视图
    private lazy var rankListView: BarRankListView = {
        return BarRankListView(frame: .zero)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(self.rankListView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = chartLayoutFrame()
        rankListView.width = layoutFrame.width
        rankListView.height = rankListHeight
        rankListView.left = layoutFrame.minX
        rankListView.top = layoutFrame.minY
    }
}
