//
//  WSPluginEmptyPlaceholderView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/19.
//

import Foundation
import UIKit

// MARK: - 默认空白内容视图

/// 工作台组件默认空白内容视图。
///
/// 数据加载完成但没有内容（`dataItem` 为 nil）时展示：顶部图标、中间描述、底部「配置插件」按钮。
/// 组件不支持配置（未提供 `configActionHandler`）时只展示图标与描述。
class WSPluginEmptyPlaceholderView: UIView {
    
    struct Constants {
        
        /// 图标尺寸
        static let iconSize = CGSize(width: 32.0, height: 32.0)
        
        /// 图标与描述的间距
        static let iconTitleSpacing: CGFloat = 12.0
        
        /// 描述与按钮的间距
        static let titleButtonSpacing: CGFloat = 12.0
        
        /// 按钮高度
        static let buttonHeight: CGFloat = 44.0
        
        /// 内容与视图边缘的内边距
        static let contentInsets = UIEdgeInsets(value: 12.0)
        
        /// 描述文字字号
        static let titleFont = UIFont.systemFont(ofSize: 14.0)
        
        /// 按钮文字字号
        static let buttonFont = UIFont.systemFont(ofSize: 14.0, weight: .medium)
    }
    
    /// 点击「配置插件」回调。为 nil 时不展示按钮
    var configActionHandler: (() -> Void)? {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 图标
    private lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "info.circle")
        imageView.tintColor = .tertiaryLabel
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    /// 描述文字
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = resGetString("No Content")
        label.font = Constants.titleFont
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    /// 配置插件按钮
    private lazy var configButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.title = resGetString("Configure Plugin")
        button.titleConfig.font = Constants.buttonFont
        button.titleConfig.textColor = .primary
        button.titleConfig.highlightedTextColor = .primary
        button.titleConfig.selectedTextColor = .primary
        button.normalBackgroundColor = .primary.withAlphaComponent(0.1)
        button.selectedBackgroundColor = .primary.withAlphaComponent(0.16)
        button.didClickHandler = { [weak self] in
            self?.configActionHandler?()
        }
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(configButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let insets = Constants.contentInsets
        let availableWidth = max(bounds.width - insets.left - insets.right, 0.0)
        let availableHeight = max(bounds.height - insets.top - insets.bottom, 0.0)
        
        /// 未提供配置回调时不展示按钮
        let showsButton = configActionHandler != nil
        configButton.isHidden = !showsButton
        
        /// 图标尺寸不超过可用空间
        let iconHeight = min(Constants.iconSize.height, availableHeight)
        let iconWidth = min(Constants.iconSize.width, availableWidth)
        
        let titleSize = titleLabel.sizeThatFits(CGSize(width: availableWidth, height: .greatestFiniteMagnitude))
        let buttonHeight = min(Constants.buttonHeight, availableHeight * 0.3)
        
        /// 图标、描述、按钮整体垂直居中
        var contentHeight = iconHeight + Constants.iconTitleSpacing + titleSize.height
        if showsButton {
            contentHeight += Constants.titleButtonSpacing + buttonHeight
        }
        let originY = insets.top + max((availableHeight - contentHeight) / 2.0, 0.0)
        
        iconView.frame = CGRect(x: (bounds.width - iconWidth) / 2.0,
                                y: originY,
                                width: iconWidth,
                                height: iconHeight)
        
        titleLabel.frame = CGRect(x: insets.left,
                                  y: iconView.frame.maxY + Constants.iconTitleSpacing,
                                  width: availableWidth,
                                  height: titleSize.height)
        
        guard showsButton else {
            return
        }
        
        configButton.frame = CGRect(x: insets.left,
                                    y: titleLabel.frame.maxY + Constants.titleButtonSpacing,
                                    width: availableWidth,
                                    height: buttonHeight)
        configButton.cornerRadius = .greatestFiniteMagnitude
    }
}
