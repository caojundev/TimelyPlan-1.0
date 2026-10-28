//
//  WSGoalPlanBriefRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/28.
//

import Foundation
import UIKit

// MARK: - 简略行视图

/// 目标计划简略行视图。
///
/// 上方复用 `GoalPlanListInfoView` 展示色条、名称与日期，下方为进度条。
/// 用于小尺寸及后续网格等空间有限的场景，尺寸由外部决定。
class WSGoalPlanBriefRowView: WSGoalPlanRowView {
    
    /// 布局尺寸。整体比目标计划列表更紧凑，适配组件内的行高
    private enum Metrics {
        
        /// 名称字号
        static let titleFont = UIFont.boldSystemFont(ofSize: 14.0)
        
        /// 日期字号
        static let subtitleFont = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        
        /// 名称与日期的间距
        static let subtitleTopMargin: CGFloat = 4.0
        
        /// 左侧色块尺寸及其与文本的间距
        static let colorDotSize = CGSize(value: 8.0)
        static let colorDotMargins = UIEdgeInsets(right: 8.0)
        
        /// 进度条高度及其与信息视图的间距
        static let progressHeight: CGFloat = 4.0
        static let contentSpacing: CGFloat = 10.0
    }
    
    /// 信息视图（色条 + 名称 + 日期）
    private let infoView = GoalPlanListInfoView()
    
    /// 进度条
    private lazy var progressView: TPBarProgressView = {
        let view = TPBarProgressView(frame: .zero, style: .horizontal)
        view.isUserInteractionEnabled = false
        view.cornerRadius = .greatestFiniteMagnitude
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        /// 名称与日期配置与目标计划列表一致，字号按行高收紧
        let titleConfig = TPLabelConfig.withFont(Metrics.titleFont,
                                                 textColor: .label,
                                                 adjustsFontSizeToFitWidth: true,
                                                 minimumScaleFactor: 0.9)
        infoView.titleConfig = titleConfig
        
        let subtitleConfig = TPLabelConfig.withFont(Metrics.subtitleFont,
                                                    textColor: .secondaryLabel,
                                                    adjustsFontSizeToFitWidth: true,
                                                    minimumScaleFactor: 0.8)
        subtitleConfig.alpha = 0.8
        infoView.subtitleConfig = subtitleConfig
        infoView.subtitleTopMargin = Metrics.subtitleTopMargin
        infoView.leftAccessorySize = Metrics.colorDotSize
        infoView.leftAccessoryMargins = Metrics.colorDotMargins
        
        setupSkeleton()
        
        addSubview(infoView)
        addSubview(progressView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 骨架
    /// 标记骨架块：名称与日期；色块与进度条不参与骨架
    private func setupSkeleton() {
        infoView.leftAccessoryView?.isSkeletonExcluded = true
        progressView.isSkeletonExcluded = true
        
        infoView.titleLabel.isSkeletonable = true
        infoView.titleLabel.skeletonShape = .capsule
        infoView.titleLabel.skeletonWidthRatio = 0.5
        
        infoView.subtitleLabel.isSkeletonable = true
        infoView.subtitleLabel.skeletonShape = .capsule
        infoView.subtitleLabel.skeletonWidthRatio = 0.35
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = bounds.inset(by: contentInsets)
        guard layoutFrame.width > 0.0, layoutFrame.height > 0.0 else {
            return
        }
        
        /// 信息视图按名称与日期两行高度展示
        let titleHeight = max(ceil(infoView.titleConfig.font.lineHeight), infoView.titleMinimumHeight)
        let subtitleHeight = max(ceil(infoView.subtitleConfig.font.lineHeight), infoView.subtitleMinimumHeight)
        let infoHeight = titleHeight + infoView.subtitleTopMargin + subtitleHeight
        
        /// 信息视图与进度条整体在行内垂直居中
        let blockHeight = infoHeight + Metrics.contentSpacing + Metrics.progressHeight
        let top = layoutFrame.minY + max((layoutFrame.height - blockHeight) / 2.0, 0.0)
        
        infoView.frame = CGRect(x: layoutFrame.minX,
                                y: top,
                                width: layoutFrame.width,
                                height: infoHeight)
        
        /// 进度条在信息视图下方，左端与文本左端对齐
        let textLeft = layoutFrame.minX + Metrics.colorDotSize.width + Metrics.colorDotMargins.horizontalLength
        progressView.height = Metrics.progressHeight
        progressView.width = max(layoutFrame.maxX - textLeft, 0.0)
        progressView.left = textLeft
        progressView.top = infoView.bottom + Metrics.contentSpacing
    }
    
    // MARK: - 渲染
    /// 更新展示的目标计划。传 nil 时清空内容并展示骨架
    override func update(with dataItem: WSGoalPlanDataItem?) {
        super.update(with: dataItem)
        
        guard let dataItem = dataItem else {
            progressView.isHidden = true
            infoView.color = nil
            infoView.title = nil
            infoView.subtitle = nil
            
            /// 骨架态保留名称 / 日期一行高度，Skeleton 才能生成文本占位块
            infoView.titleMinimumHeight = ceil(infoView.titleConfig.font.lineHeight)
            infoView.subtitleMinimumHeight = ceil(infoView.subtitleConfig.font.lineHeight)
            
            setNeedsLayout()
            layoutIfNeeded()
            sk.show(config: skeletonConfig)
            return
        }
        
        sk.hide()
        progressView.isHidden = false
        infoView.titleMinimumHeight = 0.0
        infoView.subtitleMinimumHeight = 0.0
        infoView.color = dataItem.color
        infoView.title = dataItem.title
        infoView.subtitle = dataItem.intervalText
        progressView.barForeColor = dataItem.color
        progressView.barBackColor = dataItem.color.withAlphaComponent(0.2)
        progressView.setProgress(dataItem.progress, animated: false)
        setNeedsLayout()
    }
}
