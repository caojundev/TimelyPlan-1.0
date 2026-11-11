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
        return config
    }()
    
    /// 图标内容
    var imageContent: TPImageContent?
    
    /// 图标名称
    var imageName: String? {
        get {
            return imageContent?.name
        }
        
        set {
            imageContent = .withName(newValue)
        }
    }
    
    /// 图标配置
    var imageConfig: TPImageAccessoryConfig = {
        let config = TPImageAccessoryConfig()
        config.size = .large
        config.shouldRenderImageWithColor = false
        return config
    }()
    
    /// 图标右上角展示的数目，为 0 时不展示
    var count: Int = 0
    
    override init() {
        super.init()
        self.registerClass = WSPluginModuleCollectionCell.self
    }
}

// MARK: - 模块网格单元格

/// 模块网格单元格：上方图标方块，下方标题
class WSPluginModuleCollectionCell: TPCollectionCell {
    
    enum Metrics {
        
        /// 图标方块圆角
        static let cornerRadius = 18.0
        
        /// 图标方块边框宽度
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
        
        /// 数目标签与图标方块右上角的间距
        static let countMargin = 6.0
        
        /// 数目标签字体
        static let countFont = UIFont.systemFont(ofSize: 11.0, weight: .semibold)
        
        /// 数目标签内边距
        static let countEdgeInsets = UIEdgeInsets(horizontal: 5.0, vertical: 2.0)
    }
    
    /// 图标方块
    private lazy var iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = Metrics.cornerRadius
        view.layer.borderWidth = Metrics.borderWidth
        return view
    }()
    
    /// 图标
    private let imageView = TPImageView()
    
    /// 图标右上角数目
    private lazy var countLabel: TPLabel = {
        let label = TPLabel()
        label.font = Metrics.countFont
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 1
        label.edgeInsets = Metrics.countEdgeInsets
        label.backgroundColor = .tertiarySystemFill
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()
    
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
            titleLabel.updateContent(.withText(cellItem.title))
            
            countLabel.text = "\(cellItem.count)"
            countLabel.isHidden = cellItem.count <= 0
            setNeedsLayout()
        }
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        iconContainerView.addSubview(imageView)
        iconContainerView.addSubview(countLabel)
        contentView.addSubview(iconContainerView)
        contentView.addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        
        /// 图标方块为正方形，边长取单元格宽度
        iconContainerView.width = layoutFrame.width
        iconContainerView.height = layoutFrame.width
        iconContainerView.top = layoutFrame.minY
        iconContainerView.left = layoutFrame.minX
        iconContainerView.layer.borderColor = UIColor.separator.cgColor
        
        imageView.size = imageConfig.size
        imageView.center = iconContainerView.bounds.center
        
        /// 数目标签靠图标方块右上角，全圆角
        countLabel.sizeToFit()
        countLabel.layer.cornerRadius = countLabel.height / 2.0
        countLabel.top = Metrics.countMargin
        countLabel.right = iconContainerView.width - Metrics.countMargin
        
        titleLabel.width = layoutFrame.width
        titleLabel.height = Metrics.titleHeight
        titleLabel.top = iconContainerView.bottom + Metrics.titleTop
        titleLabel.left = layoutFrame.minX
    }
}
