//
//  WSGoalPlanDetailRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/28.
//

import Foundation
import UIKit

// MARK: - 详情行视图

/// 目标计划详情行视图。
///
/// 在简略行基础上补回状态与进度百分比：名称右侧显示状态标签，
/// 底部进度条右侧显示百分比，用于中 / 大尺寸列表。
class WSGoalPlanDetailRowView: WSGoalPlanBriefRowView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与行边缘的间距。上下留白比简略行更小，容纳状态标签与百分比
        static let contentInsets = UIEdgeInsets(top: 2.0, left: 8.0, bottom: 2.0, right: 8.0)
        
        /// 状态标签字号与内边距
        static let statusFont = UIFont.systemFont(ofSize: 10.0, weight: .medium)
        static let statusEdgeInsets = UIEdgeInsets(horizontal: 5.0, vertical: 3.0)
        
        /// 状态标签与名称的间距
        static let statusMargins = UIEdgeInsets(left: 6.0)
        
        /// 进度百分比字号
        static let percentageFont = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        
        /// 进度条高度及其与信息视图的间距
        static let progressHeight: CGFloat = 4.0
        static let contentSpacing: CGFloat = 6.0
        
        /// 进度条与百分比标签的间距
        static let percentageSpacing: CGFloat = 6.0
    }
    
    /// 状态标签
    private lazy var statusLabel: TPLabel = {
        let label = TPLabel()
        label.font = Metrics.statusFont
        label.textColor = .white
        label.textAlignment = .center
        label.edgeInsets = Metrics.statusEdgeInsets
        label.isSkeletonExcluded = true
        return label
    }()
    
    /// 进度百分比
    private lazy var percentageLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.percentageFont
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.isSkeletonExcluded = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentInsets = Metrics.contentInsets
        
        /// 状态标签作为信息视图的右配件，名称宽度自动扣除，不遮挡文本
        infoView.rightAccessoryView = statusLabel
        infoView.rightAccessorySize = .zero
        infoView.rightAccessoryMargins = .zero
        
        addSubview(percentageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = bounds.inset(by: contentInsets)
        guard layoutFrame.width > 0.0, layoutFrame.height > 0.0 else {
            return
        }
        
        statusLabel.layer.cornerRadius = statusLabel.halfHeight
        
        /// 信息视图按名称与日期两行高度展示
        let titleHeight = max(ceil(infoView.titleConfig.font.lineHeight), infoView.titleMinimumHeight)
        let subtitleHeight = max(ceil(infoView.subtitleConfig.font.lineHeight), infoView.subtitleMinimumHeight)
        let infoHeight = titleHeight + infoView.subtitleTopMargin + subtitleHeight
        
        /// 底部行：百分比贴右，进度条占据其余宽度
        let percentageSize = percentageLabel.sizeThatFits(.unlimited)
        let percentageHeight = ceil(percentageLabel.font.lineHeight)
        let bottomHeight = max(Metrics.progressHeight, percentageHeight)
        
        /// 信息视图与底部行整体在行内垂直居中
        let blockHeight = infoHeight + Metrics.contentSpacing + bottomHeight
        let top = layoutFrame.minY + max((layoutFrame.height - blockHeight) / 2.0, 0.0)
        
        infoView.frame = CGRect(x: layoutFrame.minX,
                                y: top,
                                width: layoutFrame.width,
                                height: infoHeight)
        
        let bottomTop = infoView.bottom + Metrics.contentSpacing
        percentageLabel.size = CGSize(width: min(percentageSize.width, layoutFrame.width),
                                      height: percentageHeight)
        percentageLabel.right = layoutFrame.maxX
        percentageLabel.top = bottomTop + (bottomHeight - percentageHeight) / 2.0
        
        /// 进度条左端与信息视图文本左端对齐
        let textLeft = layoutFrame.minX + infoView.leftAccessorySize.width + infoView.leftAccessoryMargins.horizontalLength
        progressView.height = Metrics.progressHeight
        progressView.width = max(layoutFrame.maxX - textLeft - percentageLabel.width - Metrics.percentageSpacing, 0.0)
        progressView.left = textLeft
        progressView.top = bottomTop + (bottomHeight - Metrics.progressHeight) / 2.0
    }
    
    // MARK: - 渲染
    /// 更新展示的目标计划。传 nil 时由简略行清空内容与骨架，同时隐藏状态与百分比
    override func update(with dataItem: WSGoalPlanDataItem?) {
        super.update(with: dataItem)
        
        guard let dataItem = dataItem else {
            statusLabel.isHidden = true
            infoView.rightAccessorySize = .zero
            infoView.rightAccessoryMargins = .zero
            percentageLabel.text = nil
            setNeedsLayout()
            return
        }
        
        statusLabel.isHidden = dataItem.statusText.isEmpty
        statusLabel.text = dataItem.statusText
        statusLabel.layer.backgroundColor = dataItem.statusColor.cgColor
        percentageLabel.text = dataItem.progressText
        
        /// 状态文案变化会改变标签宽度，同步给信息视图，避免压缩名称
        let statusSize = dataItem.statusText.isEmpty ? .zero : statusLabel.sizeThatFits(.unlimited)
        statusLabel.size = statusSize
        infoView.rightAccessorySize = statusSize
        infoView.rightAccessoryMargins = statusSize.width > 0.0 ? Metrics.statusMargins : .zero
        
        setNeedsLayout()
    }
}
