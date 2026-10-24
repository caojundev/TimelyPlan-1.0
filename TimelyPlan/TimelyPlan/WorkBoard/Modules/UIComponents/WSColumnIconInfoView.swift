//
//  WSColumnIconInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/24.
//

import Foundation
import UIKit

// MARK: - 竖向图标信息视图

/// 图标 + 信息 + 底部配件的通用列视图。
///
/// 上方图标靠左，中间信息区，底部配件靠左。
/// 视图本身不处理点击，交互由外部或配件视图自行处理；尺寸完全由外部决定，
/// 字号、图标与间距参数均按列宽换算，便于在不同尺寸的组件中复用。
class WSColumnIconInfoView: UIView {
    
    // MARK: - 尺寸参数
    /// 图标边长占列宽的比例及范围
    var iconWidthRatio: CGFloat = 0.34
    var iconMinSide: CGFloat = 20.0
    var iconMaxSide: CGFloat = 40.0
    
    /// 图标字号占图标边长的比例
    var iconFontRatio: CGFloat = 0.5
    
    /// 图标与信息、信息与配件之间的间距
    var iconInfoSpacing: CGFloat = 8.0

    /// 标题字号占列宽的比例及范围
    var titleFontRatio: CGFloat = 0.15
    var titleMinFontSize: CGFloat = 13.0
    var titleMaxFontSize: CGFloat = 15.0
    
    /// 副标题字号占列宽的比例及范围
    var subtitleFontRatio: CGFloat = 0.12
    var subtitleMinFontSize: CGFloat = 10.0
    var subtitleMaxFontSize: CGFloat = 13.0
    
    /// 副标题与标题的间距
    var subtitleSpacing: CGFloat = 2.0
    
    // MARK: - 外观
    /// 背景色
    var backColor: UIColor = .clear {
        didSet {
            backgroundColor = backColor
        }
    }
    
    /// 圆角半径。大于 0 时内容随圆角裁剪
    var contentCornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = contentCornerRadius
            clipsToBounds = contentCornerRadius > 0.0
        }
    }
    
    // MARK: - 子视图
    /// 图标视图
    let iconView = TPIconView()
    
    /// 信息视图
    let infoView = TPInfoView()
    
    /// 底部配件视图
    var accessoryView: UIView? {
        didSet {
            guard accessoryView !== oldValue else {
                return
            }
            
            oldValue?.removeFromSuperview()
            if let accessoryView = accessoryView {
                addSubview(accessoryView)
            }
            
            setNeedsLayout()
        }
    }
    
    /// 底部配件尺寸
    var accessorySize: CGSize = .zero {
        didSet {
            guard accessorySize != oldValue else {
                return
            }
            
            setNeedsLayout()
        }
    }
    
    /// 上一次布局的可用区域尺寸
    private var laidOutSize: CGSize = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        infoView.titleConfig.textColor = .label
        infoView.subtitleConfig.textColor = .secondaryLabel
        infoView.subtitleConfig.alpha = 1.0
        infoView.subtitleConfig.numberOfLines = 2
        addSubview(iconView)
        addSubview(infoView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentFrame = layoutFrame()
        guard contentFrame.height > 0.0 else {
            return
        }
        
        /// 图标靠左上排列
        let iconSide = min(max(floor(contentFrame.width * iconWidthRatio), iconMinSide), iconMaxSide)
        
        let isSizeChanged = laidOutSize != contentFrame.size
        laidOutSize = contentFrame.size
        if isSizeChanged {
            updateFonts(in: contentFrame, iconSide: iconSide)
        }
        
        iconView.size = CGSize(width: iconSide, height: iconSide)
        iconView.top = contentFrame.minY
        iconView.left = contentFrame.minX
        iconView.cornerRadius = iconSide / 2.0
        
        infoView.sizeToFit()
        infoView.width = contentFrame.width
        infoView.left = contentFrame.minX
        infoView.top = iconView.bottom + iconInfoSpacing
        
        /// 配件靠左下排列
        if let accessoryView = accessoryView {
            accessoryView.size = accessorySize
            accessoryView.bottom = contentFrame.maxY
            accessoryView.left = contentFrame.minX
        }
    }
    
    /// 按列宽更新字号
    private func updateFonts(in contentFrame: CGRect, iconSide: CGFloat) {
        let titleFontSize = min(max(floor(contentFrame.width * titleFontRatio), titleMinFontSize),
                                titleMaxFontSize)
        infoView.titleConfig.font = .systemFont(ofSize: titleFontSize, weight: .semibold)
        
        let subtitleFontSize = min(max(floor(contentFrame.width * subtitleFontRatio), subtitleMinFontSize),
                                   subtitleMaxFontSize)
        infoView.subtitleConfig.font = .systemFont(ofSize: subtitleFontSize, weight: .medium)
        infoView.subtitleTopMargin = subtitleSpacing
        
        iconView.font = .systemFont(ofSize: floor(iconSide * iconFontRatio))
        infoView.setNeedsLayout()
    }
    
    // MARK: - 渲染
    /// 更新图标与文案
    func update(icon: TPIcon?,
                iconForeColor: UIColor?,
                iconBackColor: UIColor?,
                title: String?,
                subtitle: String?) {
        iconView.icon = icon
        iconView.foreColor = iconForeColor
        iconView.backColor = iconBackColor
        infoView.title = title
        infoView.subtitle = subtitle
    }
}
