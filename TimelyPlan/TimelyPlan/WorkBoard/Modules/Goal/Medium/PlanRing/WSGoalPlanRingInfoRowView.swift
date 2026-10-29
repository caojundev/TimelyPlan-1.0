//
//  WSGoalPlanRingInfoRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

// MARK: - 计划信息行

/// 目标·中·自选三环右侧的计划信息行。
///
/// 承载色块、名称与完成百分比的信息视图，整行响应点击并回调对应计划。
class WSGoalPlanRingInfoRowView: WSRowView {
    
    /// 信息视图（色块 + 名称 + 完成百分比）
    private let infoView = WSGoalPlanRingInfoView()
    
    /// 当前展示的目标计划
    private(set) var dataItem: WSGoalPlanDataItem?
    
    /// 点击行的回调
    var didSelectPlanHandler: ((WSGoalPlanDataItem) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentCornerRadius = 8.0
        addSubview(infoView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        infoView.frame = bounds
    }
    
    // MARK: - 交互
    /// 点击行：回调当前展示的目标计划
    override func didSelectRow() {
        guard let dataItem = dataItem else {
            return
        }
        
        didSelectPlanHandler?(dataItem)
    }
    
    // MARK: - 渲染
    /// 更新展示的目标计划。传 nil 时由信息视图展示骨架
    func update(with dataItem: WSGoalPlanDataItem?) {
        self.dataItem = dataItem
        infoView.update(with: dataItem)
    }
}

// MARK: - 计划信息视图

/// 计划信息：色块、名称与完成百分比。
///
/// 使用 `TPColorInfoView` 承载色块与两行文本，无数据时展示骨架。
private class WSGoalPlanRingInfoView: TPColorInfoView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 色块尺寸及其与文本的间距
        static let colorBarSize = CGSize(width: 6.0, height: 28.0)
        static let colorBarMargins = UIEdgeInsets(horizontal: 8.0)
        
        /// 名称字号
        static let titleFont = UIFont.systemFont(ofSize: 13.0, weight: .medium)
        
        /// 百分比字号
        static let valueFont = UIFont.monospacedDigitSystemFont(ofSize: 15.0, weight: .bold)
        
        /// 百分号字号
        static let valueUnitFont = UIFont.monospacedDigitSystemFont(ofSize: 10.0, weight: .bold)
        
        /// 名称与百分比的间距
        static let subtitleTopMargin: CGFloat = 4.0
        
        /// 骨架块颜色。组件底色偏亮，骨架块需要更明显的对比
        static let skeletonColor = Color(light: 0x000000, 0.12, dark: 0xFFFFFF, 0.22)
    }
    
    /// 骨架块配置
    private let skeletonConfig: SkeletonConfig = {
        var config = Skeleton.config
        config.baseColor = Metrics.skeletonColor
        return config
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleConfig = .withFont(Metrics.titleFont,
                                textColor: .secondaryLabel,
                                adjustsFontSizeToFitWidth: true,
                                minimumScaleFactor: 0.7)
        subtitleConfig = .withFont(Metrics.valueFont,
                                   textColor: .label,
                                   adjustsFontSizeToFitWidth: true,
                                   minimumScaleFactor: 0.5)
        subtitleTopMargin = Metrics.subtitleTopMargin
        
        let colorConfig = TPColorAccessoryConfig.withColor(nil, size: Metrics.colorBarSize)
        colorConfig.margins = Metrics.colorBarMargins
        self.colorConfig = colorConfig
        
        setupSkeleton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 标记骨架块：名称与百分比；色块不参与骨架
    private func setupSkeleton() {
        colorView.isSkeletonExcluded = true
        
        titleLabel.isSkeletonable = true
        titleLabel.skeletonShape = .capsule
        titleLabel.skeletonWidthRatio = 0.5
        
        subtitleLabel.isSkeletonable = true
        subtitleLabel.skeletonShape = .capsule
        subtitleLabel.skeletonWidthRatio = 0.3
    }
    
    /// 更新展示的目标计划。传 nil 时清空内容并展示骨架
    func update(with dataItem: WSGoalPlanDataItem?) {
        guard let dataItem = dataItem else {
            colorView.backgroundColor = nil
            title = nil
            subtitle = nil
            
            /// 骨架态保留名称 / 百分比一行高度，Skeleton 才能生成文本占位块
            titleMinimumHeight = ceil(titleConfig.font.lineHeight)
            subtitleMinimumHeight = ceil(subtitleConfig.font.lineHeight)
            
            setNeedsLayout()
            layoutIfNeeded()
            sk.show(config: skeletonConfig)
            return
        }
        
        sk.hide()
        titleMinimumHeight = 0.0
        subtitleMinimumHeight = 0.0
        colorView.backgroundColor = dataItem.color
        title = dataItem.title
        subtitle = Float(dataItem.progress).attributedPercentageString(decimalPlaces: 0,
                                                                       percentSignFont: Metrics.valueUnitFont)
        setNeedsLayout()
    }
}
