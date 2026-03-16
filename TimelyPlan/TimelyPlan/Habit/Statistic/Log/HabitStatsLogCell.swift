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
        self.size = CGSize(width: .greatestFiniteMagnitude, height: 80.0)
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
    
    /// 单元格内间距
    let statsNoteCellPadding = UIEdgeInsets(horizontal: 16.0, vertical: 10.0)

    /// 日期区域尺寸
    let statsNoteDateAreaSize = CGSize(width: 50.0, height: 50.0)

    let statsNoteSeparatorSize = CGSize(width: 2.0, height: 40.0)

    let statsNoteLabelLeftMargin = 10.0

    /// 日期标签
    private var dateLabel: UILabel!
    
    /// 星期符号标签
    private var weekdayLabel: UILabel!
    
    /// 分割线
    private var separator: CALayer!
    
    private var noteLabel: UILabel!
    
    private var scoreInfoView = TPInfoView()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        
        /// 分割线
        separator = CALayer()
        contentView.layer.addSublayer(separator)
        
        let textColor = resGetColor(.title)
        
        /// 日期标签
        dateLabel = UILabel()
        dateLabel.font = UIFont.boldSystemFont(ofSize: 24.0)
        dateLabel.textAlignment = .center
        dateLabel.textColor = textColor
        contentView.addSubview(dateLabel)
        
        /// 星期符号标签
        weekdayLabel = UILabel()
        weekdayLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
        weekdayLabel.textAlignment = .center
        weekdayLabel.textColor = textColor
        contentView.addSubview(weekdayLabel)
    
        noteLabel = UILabel()
        noteLabel.numberOfLines = 0
        noteLabel.textAlignment = .left
        noteLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        noteLabel.textColor = textColor
        contentView.addSubview(noteLabel)
        
        scoreInfoView.titleConfig.font = .boldSystemFont(ofSize: 24.0)
        scoreInfoView.subtitleConfig.font = .boldSystemFont(ofSize: 12.0)
        scoreInfoView.titleConfig.textAlignment = .center
        scoreInfoView.subtitleConfig.textAlignment = .center
        scoreInfoView.subtitle = resGetString("Score")
        scoreInfoView.addSeparator(position: .left, color: Color(0xcccccc, 0.2))
        scoreInfoView.separatorEdgeInset = UIEdgeInsets(vertical: 8.0)
        scoreInfoView.padding = UIEdgeInsets(value: 8.0)
        contentView.addSubview(scoreInfoView)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = bounds.inset(by: statsNoteCellPadding)
        let topMargin = (layoutFrame.height - statsNoteDateAreaSize.height) / 2.0
        dateLabel.width = statsNoteDateAreaSize.width
        dateLabel.height = statsNoteDateAreaSize.width * 0.6
        dateLabel.left = layoutFrame.minX
        dateLabel.top = layoutFrame.minY + topMargin
        
        weekdayLabel.width = statsNoteDateAreaSize.width
        weekdayLabel.height = statsNoteDateAreaSize.width * 0.4
        weekdayLabel.left = layoutFrame.minX
        weekdayLabel.top = dateLabel.bottom

        separator.backgroundColor = Color(0x888888, 0.1).cgColor
        let separatorY = (bounds.height - statsNoteSeparatorSize.height) / 2.0
        let separatorRect = CGRect(x: dateLabel.right,
                                   y: separatorY,
                                   width: statsNoteSeparatorSize.width,
                                   height: statsNoteSeparatorSize.height)
        separator.frame = separatorRect
        separator.cornerRadius = 2.0
        
        let noteLabelX = dateLabel.right + statsNoteLabelLeftMargin
        let noteLabelW = layoutFrame.maxX - noteLabelX
        let noteLabelFrame = CGRect(x: noteLabelX,
                                    y: layoutFrame.minY,
                                    width: noteLabelW,
                                    height: layoutFrame.height)
        noteLabel.frame = noteLabelFrame
        
        scoreInfoView.width = 80.0
        scoreInfoView.height = layoutFrame.height
        scoreInfoView.top = layoutFrame.minY
        scoreInfoView.right = layoutFrame.maxX
    }
    
    func updateContent() { 
        dateLabel.text = "\(log.date.day)"
        weekdayLabel.text = log.date.shortWeekdaySymbol()
        noteLabel.text = log.content
        scoreInfoView.title = "\(log.score)"
    }
}
