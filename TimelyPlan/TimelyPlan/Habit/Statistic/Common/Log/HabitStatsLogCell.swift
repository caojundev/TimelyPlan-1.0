//
//  HabitStatsLogCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/3.
//

import Foundation
import UIKit

struct HabitStatsLog {
    
    /// 日期
    var date: Date
    
    /// 状态
    var status: HabitTaskStatus
    
    /// 内容
    var content: String?
    
    /// 评分
    var score: Int
}

class HabitStatsLogCellItem: TPCollectionCellItem {
    
    var log: HabitStatsLog
    
    init(log: HabitStatsLog) {
        self.log = log
        super.init()
        self.registerClass = HabitStatsLogCell.self
        self.size = CGSize(width: .greatestFiniteMagnitude, height: 90.0)
        self.contentPadding = UIEdgeInsets(top: 10.0,
                                           left: 16.0,
                                           bottom: 10.0,
                                           right: 10.0)
    }
}

class HabitStatsLogCell: TPCollectionCell {
    
    /// 备注
    var log: HabitStatsLog! {
        didSet {
            updateContent()
        }
    }
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            guard let cellItem = cellItem as? HabitStatsLogCellItem else {
                return
            }
            
            self.log = cellItem.log
        }
    }
    
    /// 日期标签
    private let dateLabel = TPLabel()
    
    private let infoView = TPImageInfoView()
    
    private let scoreView = TPInfoView()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        
        let textColor = resGetColor(.title)
        dateLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
        dateLabel.textAlignment = .left
        dateLabel.textColor = textColor
        dateLabel.alpha = 0.8
        contentView.addSubview(dateLabel)
        
        infoView.imageConfig.size = .size(6)
        infoView.imageConfig.shouldRenderImageWithColor = false
        infoView.titleConfig.font = .boldSystemFont(ofSize: 14.0)
        infoView.subtitleConfig.font = .systemFont(ofSize: 12.0)
        contentView.addSubview(infoView)
        
        scoreView.titleConfig.font = .boldSystemFont(ofSize: 20.0)
        scoreView.subtitleConfig.font = .boldSystemFont(ofSize: 10.0)
        scoreView.titleConfig.textAlignment = .center
        scoreView.subtitleConfig.textAlignment = .center
        scoreView.subtitle = resGetString("Score")
        scoreView.addSeparator(position: .left, color: Color(0xaaaaaa, 0.1))
        scoreView.separatorEdgeInset = UIEdgeInsets(vertical: 8.0)
        contentView.addSubview(scoreView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = contentView.layoutFrame()
        dateLabel.width = layoutFrame.width
        dateLabel.height = 20.0
        dateLabel.origin = layoutFrame.origin
   
        scoreView.width = 60.0
        scoreView.height = layoutFrame.height - dateLabel.height
        scoreView.top = dateLabel.bottom
        scoreView.right = layoutFrame.maxX
        
        infoView.width = layoutFrame.width - scoreView.width
        infoView.height = scoreView.height
        infoView.top = dateLabel.bottom
        infoView.left = layoutFrame.minX
        
//        dateLabel.backgroundColor = .random
//        scoreView.backgroundColor = .random
//        infoView.backgroundColor = .random
//        scoreView.subtitleLabel.backgroundColor = .random
    }
    
    func updateContent() {
        dateLabel.text = log.date.yearMonthDayWeekdaySymbolString()
        scoreView.title = "\(log.score)"

        let imageName = log.status.iconName(with: 24)
        infoView.imageContent = .withName(imageName)
        infoView.title = log.status.title
        infoView.subtitle = log.content
    }
}
