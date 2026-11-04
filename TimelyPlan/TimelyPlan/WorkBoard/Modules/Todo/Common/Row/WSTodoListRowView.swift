//
//  WSTodoListRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/3.
//

import Foundation
import UIKit

// MARK: - 行视图

/// 待办清单行视图。
///
/// 内容由 `TPIconInfoTextValueView` 承载：左侧展示清单图标，右侧展示清单名称；
/// 没有对应清单的行展示骨架。
class WSTodoListRowView: WSRowView {
    
    /// 行尺寸
    private enum Metrics {
        
        /// 内容与行边缘的间距
        static let contentInsets = UIEdgeInsets(top: 4.0, left: 8.0, bottom: 4.0, right: 8.0)
        
        /// 按下高亮的圆角
        static let cornerRadius: CGFloat = 10.0
        
        /// 名称字号
        static let titleFont = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
        
        /// 图标边长占行高的比例及范围
        static let iconHeightRatio: CGFloat = 0.6
        static let iconMinSide: CGFloat = 24.0
        static let iconMaxSide: CGFloat = 32.0
        
        /// 图标与名称的间距
        static let iconMargins = UIEdgeInsets(right: 8.0)
        
        /// 骨架块颜色。组件底色偏亮，骨架块需要更明显的对比
        static let skeletonColor = Color(light: 0x000000, 0.12, dark: 0xFFFFFF, 0.22)
    }
    
    /// 当前展示的清单
    private(set) var dataItem: WSTodoListDataItem?
    
    /// 内容与行边缘的间距
    var contentInsets: UIEdgeInsets = Metrics.contentInsets {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 点击行的回调
    var didSelectListHandler: ((WSTodoListDataItem) -> Void)?
    
    /// 图标 + 名称
    let contentView = TPIconInfoTextValueView()
    
    /// 上一次布局的图标边长，用于避免重复设置图标与字号
    private var laidOutIconSide: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentCornerRadius = Metrics.cornerRadius
        contentView.iconView.cornerRadius = .greatestFiniteMagnitude
        
        let titleConfig = TPLabelConfig.withFont(Metrics.titleFont,
                                                 textColor: .label,
                                                 adjustsFontSizeToFitWidth: true,
                                                 minimumScaleFactor: 0.8)
        contentView.titleConfig = titleConfig
        
        /// 图标不参与骨架，名称以胶囊块占位
        contentView.iconView.isSkeletonExcluded = true
        contentView.titleLabel.isSkeletonable = true
        contentView.titleLabel.skeletonShape = .capsule
        contentView.titleLabel.skeletonWidthRatio = 0.5
        
        /// 组件底色偏亮，骨架块需要更明显的对比
        var skeletonConfig = Skeleton.config
        skeletonConfig.baseColor = Metrics.skeletonColor
        self.skeletonConfig = skeletonConfig
        
        addSubview(contentView)
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
        
        contentView.frame = layoutFrame
        
        /// 图标边长随行高换算，名称由内容视图居中排布
        let iconSide = min(max(floor(layoutFrame.height * Metrics.iconHeightRatio), Metrics.iconMinSide),
                           Metrics.iconMaxSide)
        guard laidOutIconSide != iconSide else {
            return
        }
        
        laidOutIconSide = iconSide
        contentView.iconView.font = .systemFont(ofSize: floor(iconSide * 0.9))
        updateIconConfig()
    }
    
    /// 图标配置：尺寸随行高变化，图标与颜色随清单变化
    private func updateIconConfig() {
        guard laidOutIconSide > 0.0 else {
            return
        }
        
        let config = TPIconAccessoryConfig()
        config.size = CGSize(value: laidOutIconSide)
        config.margins = Metrics.iconMargins
        config.icon = dataItem?.icon
        config.foreColor = .white
        config.backColor = dataItem?.color
        contentView.iconConfig = config
    }
    
    // MARK: - 渲染
    /// 更新展示的清单。传 nil 时清空内容并展示骨架
    func update(with dataItem: WSTodoListDataItem?) {
        self.dataItem = dataItem
        
        guard let dataItem = dataItem else {
            contentView.title = nil
            
            /// 骨架态保留名称一行高度，Skeleton 才能生成文本占位块
            contentView.titleMinimumHeight = ceil(contentView.titleConfig.font.lineHeight)
            
            setNeedsLayout()
            layoutIfNeeded()
            updateIconConfig()
            sk.show(config: skeletonConfig)
            return
        }
        
        sk.hide()
        contentView.titleMinimumHeight = 0.0
        contentView.title = dataItem.title
        updateIconConfig()
        setNeedsLayout()
    }
    
    // MARK: - 交互
    /// 点击行。没有对应清单时（空白行）不响应
    override func didSelectRow() {
        guard let dataItem = dataItem else {
            return
        }
        
        didSelectListHandler?(dataItem)
    }
}
