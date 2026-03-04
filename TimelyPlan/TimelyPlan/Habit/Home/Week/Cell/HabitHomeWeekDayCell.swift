//
//  HabitHomeWeekDayCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/7.
//

import Foundation
import UIKit

class HabitHomeWeekDayCell: HabitTaskStatusSymbolProgressValueCell {
    
    /// 日期
    var date: Date! {
        didSet {
            updateDateInfo()
        }
    }
    
    /// 今日指示视图
    private let todayIndicator = UIView()
    
    /// 非计划日状态图片
    private lazy var notScheduledImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = resGetImage("HabitDayNotScheduled_40pt")
        imageView.alpha = 0.2
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        insertSubview(notScheduledImageView, belowSubview: statusProgressView)
        addSubview(todayIndicator)
        notScheduledImageView.isHidden = true
        symbolLabel.textColor = Color(0xf1f1f1)
        symbolLabel.alpha = 0.6
        valueLabel.alpha = 0.8
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        todayIndicator.size = CGSize(width: 5.0, height: 5.0)
        todayIndicator.layer.cornerRadius = todayIndicator.halfHeight
        todayIndicator.alignHorizontalCenter()
        
        notScheduledImageView.frame = statusProgressView.frame
    }

    /// 更新日期信息
    func updateDateInfo() {
        /// 未来日灰度显示
        self.contentView.alpha = date.isFutureDay ? 0.4 : 1.0
        self.todayIndicator.isHidden = !date.isToday
        self.symbolLabel.text = date.shortWeekdaySymbol()
        self.statusProgressView.infoLabel.text = "\(date.day)"
    }
    
    /// 更新任务信息
    func updateStyleWithColor(_ color: UIColor) {
        self.todayIndicator.backgroundColor = color
        self.valueLabel.textColor = color
        self.statusProgressView.progressColor = color
    }
    
    /// 加载数据
    func reloadData() {
        
    }
}
