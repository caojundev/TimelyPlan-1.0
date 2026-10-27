//
//  WSHabitSmallGridRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation
import UIKit

// MARK: - 行视图

/// 习惯·小·网格的行视图。居中展示图标、进度圆环与状态角标，底部展示任务标题。
class WSHabitSmallGridRowView: WSRowView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 按下高亮的圆角
        static let cornerRadius: CGFloat = 10.0
        
        /// 图标边长占图标可用区域短边的比例
        static let iconSideRatio: CGFloat = 0.82
        
        /// 进度圆环线宽占图标边长的比例及最小值
        static let progressLineWidthRatio: CGFloat = 0.09
        static let progressLineMinWidth: CGFloat = 2.0
        
        /// 标题字号
        static let titleFont = UIFont.systemFont(ofSize: 11.0, weight: .medium)
        
        /// 图标与标题的间距
        static let titleSpacing: CGFloat = 2.0
        
        /// 骨架块颜色
        static let skeletonColor = Color(light: 0x000000, 0.12, dark: 0xFFFFFF, 0.22)
    }
    
    /// 图标与进度、状态
    private let iconView = WSHabitTaskIconView()
    
    /// 任务标题
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.titleFont
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    /// 当前展示的习惯任务
    private(set) var dataItem: WSHabitTaskDataItem?
    
    /// 点击行的回调
    var didSelectTaskHandler: ((WSHabitTaskDataItem) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentCornerRadius = Metrics.cornerRadius
        
        var skeletonConfig = Skeleton.config
        skeletonConfig.baseColor = Metrics.skeletonColor
        self.skeletonConfig = skeletonConfig
        
        setupSkeleton()
        addSubview(iconView)
        addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 骨架
    private func setupSkeleton() {
        iconView.iconView.isSkeletonable = true
        iconView.iconView.skeletonShape = .circle
        
        iconView.progressView.isSkeletonExcluded = true
        iconView.statusView.isSkeletonExcluded = true
        
        titleLabel.isSkeletonable = true
        titleLabel.skeletonShape = .capsule
        titleLabel.skeletonWidthRatio = 0.6
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let titleHeight = ceil(titleLabel.font.lineHeight)
        titleLabel.frame = CGRect(x: 0.0,
                                  y: bounds.height - titleHeight,
                                  width: bounds.width,
                                  height: titleHeight)
        
        /// 图标占标题以上的区域，并在其中居中
        let iconHeight = max(titleLabel.top - Metrics.titleSpacing, 0.0)
        iconView.frame = CGRect(x: 0.0,
                                y: 0.0,
                                width: bounds.width,
                                height: iconHeight)
        
        let shortSide = min(bounds.width, iconHeight)
        iconView.iconSide = floor(shortSide * Metrics.iconSideRatio)
        iconView.progressLineWidth = max(floor(iconView.iconSide * Metrics.progressLineWidthRatio),
                                         Metrics.progressLineMinWidth)
    }
    
    // MARK: - 交互
    override func didSelectRow() {
        guard let dataItem = dataItem else {
            return
        }
        
        didSelectTaskHandler?(dataItem)
    }
    
    // MARK: - 渲染
    /// 更新展示的习惯任务。传 nil 时清空内容并展示骨架
    func update(with dataItem: WSHabitTaskDataItem?) {
        self.dataItem = dataItem
        
        guard let dataItem = dataItem else {
            titleLabel.text = nil
            iconView.update(icon: nil, color: nil, progress: 0.0, status: .notStarted)
            setNeedsLayout()
            layoutIfNeeded()
            sk.show(config: skeletonConfig)
            return
        }
        
        sk.hide()
        titleLabel.text = dataItem.title
        iconView.update(icon: dataItem.icon,
                        color: dataItem.color,
                        progress: dataItem.progress,
                        status: dataItem.status)
        setNeedsLayout()
    }
}
