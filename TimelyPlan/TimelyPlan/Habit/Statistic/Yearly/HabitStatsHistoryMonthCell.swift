//
//  HabitStatsHistoryMonthCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/16.
//

import Foundation
import UIKit

class HabitStatsHistoryMonthCellItem: TPCollectionCellItem {
    
    /// 月份日期
    let date: Date
    
    /// 记录数目
    let recordAmount: Int64
    
    /// 完成天数
    let finishedDays: Int
    
    /// 平均分
    let avgScore: Int
    
    init(date: Date,
         recordAmount: Int64,
         finishedDays: Int,
         avgScore: Int) {
        self.date = date
        self.recordAmount = recordAmount
        self.finishedDays = finishedDays
        self.avgScore = avgScore
        super.init()
        self.registerClass = HabitStatsHistoryMonthCell.self
        self.size = CGSize(width: .greatestFiniteMagnitude, height: 130.0)
        self.contentPadding = UIEdgeInsets(horizontal: 16.0, vertical: 10.0)
    }
}

class HabitStatsHistoryMonthCell: TPCollectionCell {
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            guard let cellItem = cellItem as? HabitStatsHistoryMonthCellItem else {
                infoView.resetTitle()
                return
            }
            
            headerLabel.text = cellItem.date.yearMonthString
            infoView[0].title = "\(cellItem.recordAmount)"
            infoView[1].title = "\(cellItem.finishedDays)"
            infoView[2].title = "\(cellItem.avgScore)"
        }
    }
    
    private(set) lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14.0)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.textColor = resGetColor(.title)
        return label
    }()

    let infoViewHeight = 80.0
    lazy var infoView: TPInfoGalleryView = {
        let view = TPInfoGalleryView(frame: .zero, infoViewsCount: 3)
        view[0].titleConfig.textAlignment = .left
        view[0].subtitleConfig.textAlignment = .left
        view[0].subtitle = resGetString("Record Amount")
        view[1].subtitle = resGetString("Finished Days")
        view[2].subtitle = resGetString("Avg Score")
        return view
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(headerLabel)
        contentView.addSubview(infoView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = contentView.layoutFrame()
        let labelWidth = layoutFrame.width
        headerLabel.width = labelWidth
        headerLabel.height = 30.0
        headerLabel.origin = layoutFrame.origin
        
        infoView.width = layoutFrame.width
        infoView.height = infoViewHeight
        infoView.left = layoutFrame.minX
        infoView.top = headerLabel.bottom
    }
}
