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
/// 数据加载完成但没有内容（`dataItem` 为 nil）时展示：居中显示淡色图标与说明文字。
/// 组件尺寸不足以同时放下图标与文字时只保留图标，避免文字在小尺寸组件中被压缩。
class WSPluginEmptyPlaceholderView: UIView {
    
    struct Constants {
        
        /// 图标尺寸
        static let iconSize = CGSize(width: 26.0, height: 26.0)
        
        /// 图标与文字的间距
        static let titleSpacing: CGFloat = 8.0
        
        /// 内容与视图边缘的内边距
        static let contentInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        
        /// 说明文字字号
        static let titleFont = UIFont.systemFont(ofSize: 12.0)
    }
    
    /// 图标
    private lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "square.dashed")
        imageView.tintColor = .tertiaryLabel
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    /// 说明文字
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = resGetString("No Content")
        label.font = Constants.titleFont
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = false
        addSubview(iconView)
        addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let availableWidth = max(bounds.width - Constants.contentInsets.left - Constants.contentInsets.right, 0.0)
        let availableHeight = max(bounds.height - Constants.contentInsets.top - Constants.contentInsets.bottom, 0.0)
        
        /// 图标尺寸不超过可用空间
        let iconHeight = min(Constants.iconSize.height, availableHeight)
        let iconWidth = min(Constants.iconSize.width, availableWidth)
        
        /// 图标与文字整体放不下时只保留图标
        let titleSize = titleLabel.sizeThatFits(CGSize(width: availableWidth, height: .greatestFiniteMagnitude))
        let needsTitle = titleSize.height > 0.0
        let showsTitle = needsTitle && iconHeight + Constants.titleSpacing + titleSize.height <= availableHeight
        titleLabel.isHidden = !showsTitle
        
        /// 图标与文字整体垂直居中
        let contentHeight = showsTitle ? iconHeight + Constants.titleSpacing + titleSize.height : iconHeight
        let originY = Constants.contentInsets.top + max((availableHeight - contentHeight) / 2.0, 0.0)
        
        iconView.frame = CGRect(x: (bounds.width - iconWidth) / 2.0,
                                y: originY,
                                width: iconWidth,
                                height: iconHeight)
        
        if showsTitle {
            titleLabel.frame = CGRect(x: Constants.contentInsets.left,
                                      y: iconView.frame.maxY + Constants.titleSpacing,
                                      width: availableWidth,
                                      height: titleSize.height)
        }
    }
}
