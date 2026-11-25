//
//  WSQuadrantMediumCountsRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/30.
//

import Foundation
import UIKit

// MARK: - 象限行视图

/// 四象限·中·数量的行视图。承载象限图标、象限名称与未完成任务数。
class WSQuadrantMediumCountsRowView: WSQuadrantCountsRowView {
    
    /// 象限卡片
    private let itemView = WSQuadrantMediumCountsItemView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        /// 卡片不参与交互，点击统一由行视图处理
        itemView.isUserInteractionEnabled = false
        addSubview(itemView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        itemView.frame = bounds
    }
    
    // MARK: - 渲染
    override func updateContent(with dataItem: WSQuadrantCountsItem?) {
        itemView.update(with: dataItem)
    }
}

// MARK: - 象限卡片

/// 四象限·中·数量的象限卡片。左上角为象限图标，图标下方为象限名称，左下角为未完成任务数。
class WSQuadrantMediumCountsItemView: UIView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与卡片边缘的间距
        static let padding = UIEdgeInsets(value: 6.0)
        
        /// 图标尺寸占内容高度的比例及上限
        static let iconSizeRatio: CGFloat = 0.2
        static let iconMaximumSize: CGFloat = 24.0
        
        /// 名称字体
        static let titleFont = UIFont.boldSystemFont(ofSize: 11.0)
        
        /// 名称最多展示的行数
        static let titleMaximumLines: Int = 2
        
        /// 图标与名称的间距
        static let titleSpacing: CGFloat = 4.0
        
        /// 名称与数目的间距
        static let countSpacing: CGFloat = 2.0
        
        /// 数目字号占数目区域高度的比例及上限
        static let countFontRatio: CGFloat = 0.95
        static let countMaximumFontSize: CGFloat = 44.0
    }
    
    /// 象限图标
    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    /// 象限名称
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.titleFont
        label.numberOfLines = Metrics.titleMaximumLines
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    /// 未完成任务数
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.padding = Metrics.padding
        
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(countLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentFrame = layoutFrame()
        guard contentFrame.width > 0.0, contentFrame.height > 0.0 else {
            return
        }
        
        /// 图标贴左上，尺寸按内容高度等比换算
        let iconSize = min(contentFrame.height * Metrics.iconSizeRatio, Metrics.iconMaximumSize)
        iconView.size = CGSize(value: iconSize)
        iconView.origin = contentFrame.origin
        
        /// 名称在图标下方，按固定行数预留高度
        let lineHeight = ceil(Metrics.titleFont.lineHeight)
        let titleMaximumHeight = lineHeight * CGFloat(Metrics.titleMaximumLines)
        let titleTop = iconView.bottom + Metrics.titleSpacing
        let titleHeight = min(ceil(titleLabel.sizeThatFits(CGSize(width: contentFrame.width,
                                                                 height: titleMaximumHeight)).height),
                              titleMaximumHeight)
        
        titleLabel.size = CGSize(width: contentFrame.width, height: titleHeight)
        titleLabel.left = contentFrame.minX
        titleLabel.top = titleTop
        
        /// 数目在名称下方，字号按剩余高度换算
        let countTop = titleTop + titleMaximumHeight + Metrics.countSpacing
        let countHeight = max(contentFrame.maxY - countTop, 0.0)
        countLabel.size = CGSize(width: contentFrame.width, height: countHeight)
        countLabel.left = contentFrame.minX
        countLabel.top = countTop
        
        let fontSize = min(floor(countHeight * Metrics.countFontRatio), Metrics.countMaximumFontSize)
        countLabel.font = UIFont.monospacedDigitSystemFont(ofSize: max(fontSize, 1.0), weight: .bold)
    }
    
    // MARK: - 渲染
    /// 更新象限与未完成任务数。传 nil 时清空内容
    func update(with dataItem: WSQuadrantCountsItem?) {
        guard let dataItem = dataItem else {
            iconView.image = nil
            titleLabel.text = nil
            countLabel.text = nil
            setNeedsLayout()
            return
        }
        
        let color = dataItem.quadrant.color
        iconView.image = iconImage(for: dataItem.quadrant)
        iconView.tintColor = color
        titleLabel.textColor = color
        titleLabel.text = dataItem.quadrant.title
        countLabel.textColor = color
        countLabel.text = "\(dataItem.count)"
        
        setNeedsLayout()
    }
    
    /// 象限图标按象限颜色渲染
    private func iconImage(for quadrant: Quadrant) -> UIImage? {
        guard let iconName = quadrant.iconName else {
            return nil
        }
        
        return resGetImage(iconName)?.withRenderingMode(.alwaysTemplate)
    }
}
