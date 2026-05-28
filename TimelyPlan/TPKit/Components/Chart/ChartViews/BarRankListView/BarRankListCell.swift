//
//  BarRankListCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/28.
//

import Foundation
import UIKit

class BarRankListCellItem: TPCollectionCellItem {
    
    let slice: BarRankListSlice
    
    init(slice: BarRankListSlice) {
        self.slice = slice
        super.init()
        self.contentPadding = UIEdgeInsets(top: 0.0,
                                           left: 15.0,
                                           bottom: 10.0,
                                           right: 15.0)
        self.registerClass = BarRankListCell.self
    }
}

class BarRankListCell: TPCollectionCell {
    
    let infoViewHeight = 30.0

    let barViewHeight = 10.0
    
    let maxDetailLabelWidth = 60.0
    
    lazy var infoView: TPInfoView = {
        let view = TPInfoView()
        view.titleConfig.font = .boldSystemFont(ofSize: 12.0)
        view.titleConfig.textColor = .secondaryLabel
        view.titleConfig.lineBreakMode = .byTruncatingMiddle
        return view
    }()

    lazy var detailLabel: TPLabel = {
        let label = TPLabel()
        label.font = .boldSystemFont(ofSize: 12.0)
        label.edgeInsets = UIEdgeInsets(horizontal: 8.0)
        label.textColor = .secondaryLabel
        return label
    }()
    
    lazy var barView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = barViewHeight / 2.0
        return view
    }()
    
    var slice: BarRankListSlice? {
        didSet {
            updateInfo()
        }
    }
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            let cellItem = cellItem as! BarRankListCellItem
            slice = cellItem.slice
            layoutIfNeeded()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(infoView)
        contentView.addSubview(barView)
        contentView.addSubview(detailLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateInfo() {
        guard let slice = slice else {
            return
        }
        
        barView.layer.backgroundColor = slice.barColor.cgColor
        infoView.title = slice.title
        detailLabel.text = slice.detail
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        infoView.width = layoutFrame.width
        infoView.height = infoViewHeight
        infoView.origin = layoutFrame.origin
        
        var percentage = 0.0
        if let slice = slice, slice.threshold > 0 {
            percentage = slice.value / slice.threshold
            percentage = validatedProgress(percentage)
        }
        
        let totalBarWidth = layoutFrame.width - 80.0
        barView.height = barViewHeight
        barView.width = totalBarWidth * percentage
        barView.left = layoutFrame.minX
        barView.top = infoView.bottom
        
        detailLabel.sizeToFit()
        if detailLabel.width > maxDetailLabelWidth {
            detailLabel.width = maxDetailLabelWidth
        }
        
        detailLabel.centerY = barView.centerY
        detailLabel.left = barView.right
    }
    
}
