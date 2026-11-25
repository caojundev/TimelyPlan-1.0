//
//  WSPluginModuleCollectionCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/11.
//

import Foundation
import UIKit

// MARK: - 模块网格条目

/// 模块网格条目
class WSPluginModuleCollectionCellItem: TPCollectionCellItem {
    
    /// 标题
    var title: TextRepresentable?
    
    /// 标题配置
    lazy var titleConfig: TPLabelConfig = {
        let config = TPLabelConfig()
        config.font = WSPluginModuleCollectionCell.Metrics.titleFont
        config.textColor = .secondaryLabel
        config.textAlignment = .center
        config.lineBreakMode = .byTruncatingMiddle
        return config
    }()
    
    /// 图标：名称、渲染色、背景色与尺寸统一配置
    var icon: WSPluginIcon = .empty {
        didSet {
            imageContent = .withName(icon.name)
            imageConfig = icon.imageConfig
            imageConfig.size = icon.size ?? WSPluginModuleCollectionCellItem.defaultIconSize
        }
    }
    
    /// 图标内容
    var imageContent: TPImageContent?
    
    /// 图标配置
    var imageConfig: TPImageAccessoryConfig = {
        let config = TPImageAccessoryConfig()
        config.size = WSPluginModuleCollectionCellItem.defaultIconSize
        config.shouldRenderImageWithColor = false
        return config
    }()
    
    /// 图标未指定尺寸时使用的默认尺寸
    private static let defaultIconSize: CGSize = .size(11)
    
    /// 组件数目，为 0 时不展示
    var count: Int = 0

    /// 标题与数目组合后的展示文本，数目以弱化样式跟在标题后
    var displayTitle: TextRepresentable? {
        guard let title = title else {
            return nil
        }

        guard count > 0 else {
            return title
        }

        let titleString: ASAttributedString
        if let attributedText = title as? ASAttributedString {
            titleString = attributedText
        } else {
            let config = titleConfig
            titleString = "\(title as? String ?? "", .font(config.font), .foreground(config.textColor ?? .label))"
        }

        let suffix = "•\(count)"
        let countString: ASAttributedString = "\(suffix, .font(WSPluginModuleCollectionCell.Metrics.countFont), .foreground(UIColor.tertiaryLabel))"
        return titleString + countString
    }
    
    override init() {
        super.init()
        self.registerClass = WSPluginModuleCollectionCell.self
    }
}

// MARK: - 模块网格单元格

/// 模块网格单元格：上方图标圆形，下方标题
class WSPluginModuleCollectionCell: TPCollectionCell {
    
    enum Metrics {
        
        /// 图标圆形边框宽度
        static let borderWidth = 0.5
        
        /// 标题与图标的间距
        static let titleTop = 8.0
        
        /// 标题字体
        static let titleFont = UIFont.boldSystemFont(ofSize: 12.0)
        
        /// 标题高度
        static let titleHeight: CGFloat = ceil(titleFont.lineHeight)
        
        /// 标题区域高度
        static var titleAreaHeight: CGFloat {
            return titleTop + titleHeight
        }
        
        /// 标题后数目的字体
        static let countFont = UIFont.systemFont(ofSize: 12.0, weight: .semibold)
        
        /// 图标区域默认背景色
        static let defaultIconBackgroundColor: UIColor = .secondarySystemGroupedBackground
    }
    
    /// 图标圆形
    private lazy var iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Metrics.defaultIconBackgroundColor
        view.layer.borderWidth = Metrics.borderWidth
        return view
    }()
    
    /// 图标
    private let imageView = TPImageView()
    
    /// 标题
    private lazy var titleLabel: TPLabel = {
        let label = TPLabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    /// 图标配置
    private var imageConfig = TPImageAccessoryConfig()
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            guard let cellItem = cellItem as? WSPluginModuleCollectionCellItem else {
                return
            }
            
            imageConfig = cellItem.imageConfig
            imageView.update(content: cellItem.imageContent, config: imageConfig)
            titleLabel.updateConfig(cellItem.titleConfig)
            titleLabel.updateContent(.withText(cellItem.displayTitle))
            iconContainerView.backgroundColor = cellItem.icon.backgroundColor ?? Metrics.defaultIconBackgroundColor
            
            setNeedsLayout()
        }
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        iconContainerView.addSubview(imageView)
        contentView.addSubview(iconContainerView)
        contentView.addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        
        /// 图标区域为正方形，边长取单元格宽度
        iconContainerView.width = layoutFrame.width
        iconContainerView.height = layoutFrame.width
        iconContainerView.top = layoutFrame.minY
        iconContainerView.left = layoutFrame.minX
        iconContainerView.layer.cornerRadius = iconContainerView.halfWidth
        iconContainerView.layer.borderColor = UIColor.separator.cgColor
        
        imageView.size = imageConfig.size
        imageView.center = iconContainerView.bounds.center
        
        titleLabel.width = layoutFrame.width
        titleLabel.height = Metrics.titleHeight
        titleLabel.top = iconContainerView.bottom + Metrics.titleTop
        titleLabel.left = layoutFrame.minX
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else {
            return
        }
        
        /// 边框色为 CGColor，深浅色切换后需要重新解析
        setNeedsLayout()
    }
}
