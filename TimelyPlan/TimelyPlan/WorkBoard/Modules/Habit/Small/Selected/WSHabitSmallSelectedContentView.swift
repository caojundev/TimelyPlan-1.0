//
//  WSHabitSmallSelectedContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/26.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 习惯·小·自选的内容视图。
///
/// 自上而下依次为任务标题、图标（叠加进度圆环与状态角标）、完成详情。
class WSHabitSmallSelectedContentView: WSPluginContentView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 12.0)
        
        /// 标题字号
        static let titleFont = UIFont.boldSystemFont(ofSize: 15.0)
        
        /// 详情字号
        static let detailFont = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        
        /// 标题 / 详情与图标区域的间距
        static let contentSpacing: CGFloat = 4.0
        
        /// 图标边长占图标区域短边的比例及范围
        static let iconSideRatio: CGFloat = 0.84
        static let iconMinSide: CGFloat = 36.0
        static let iconMaxSide: CGFloat = 78.0
        
        /// 进度圆环线宽占图标边长的比例及最小值
        static let progressLineWidthRatio: CGFloat = 0.09
        static let progressLineMinWidth: CGFloat = 3.0
    }
    
    /// 标题
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.titleFont
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        return label
    }()
    
    /// 图标与进度、状态
    private let iconView = WSHabitTaskIconView()
    
    /// 完成详情，与习惯列表行展示的内容一致
    private let detailLabel = TPLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.padding = Metrics.padding
        
        let detailConfig = TPLabelConfig.withFont(Metrics.detailFont,
                                                  textColor: .secondaryLabel,
                                                  textAlignment: .center,
                                                  adjustsFontSizeToFitWidth: true,
                                                  minimumScaleFactor: 0.7)
        detailConfig.alpha = 0.8
        detailLabel.updateConfig(detailConfig)
        
        addSubview(titleLabel)
        addSubview(iconView)
        addSubview(detailLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = layoutFrame()
        guard layoutFrame.width > 0.0, layoutFrame.height > 0.0 else {
            return
        }
        
        let titleHeight = ceil(titleLabel.font.lineHeight)
        titleLabel.frame = CGRect(x: layoutFrame.minX,
                                  y: layoutFrame.minY,
                                  width: layoutFrame.width,
                                  height: titleHeight)
        
        let detailHeight = ceil(detailLabel.font.lineHeight)
        detailLabel.frame = CGRect(x: layoutFrame.minX,
                                   y: layoutFrame.maxY - detailHeight,
                                   width: layoutFrame.width,
                                   height: detailHeight)
        
        /// 图标在标题与详情之间的剩余区域居中
        let iconTop = titleLabel.bottom + Metrics.contentSpacing
        let iconHeight = max(detailLabel.top - Metrics.contentSpacing - iconTop, 0.0)
        iconView.frame = CGRect(x: layoutFrame.minX,
                                y: iconTop,
                                width: layoutFrame.width,
                                height: iconHeight)
        
        let shortSide = min(layoutFrame.width, iconHeight)
        iconView.iconSide = min(max(floor(shortSide * Metrics.iconSideRatio), Metrics.iconMinSide),
                                Metrics.iconMaxSide)
        iconView.progressLineWidth = max(floor(iconView.iconSide * Metrics.progressLineWidthRatio),
                                         Metrics.progressLineMinWidth)
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        guard let dataItem = dataItem as? WSHabitTaskDataItem else {
            titleLabel.text = nil
            detailLabel.updateContent(nil)
            iconView.isHidden = true
            iconView.update(icon: nil, color: nil, progress: 0.0, status: .notStarted)
            setNeedsLayout()
            return
        }
        
        iconView.isHidden = false
        titleLabel.text = dataItem.title
        detailLabel.updateContent(.withText(dataItem.subtitle))
        iconView.update(icon: dataItem.icon,
                        color: dataItem.color,
                        progress: dataItem.progress,
                        status: dataItem.status)
        setNeedsLayout()
    }
}
