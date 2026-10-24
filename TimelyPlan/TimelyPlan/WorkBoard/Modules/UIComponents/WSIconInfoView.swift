//
//  WSIconInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/24.
//

import Foundation
import UIKit

// MARK: - 图标信息视图

/// 图标 + 信息 + 右侧配件的通用行视图。
///
/// 左侧图标垂直居中，右侧配件垂直居中，信息区占据中间剩余空间。
/// 视图本身不处理点击，交互由外部或配件视图自行处理；尺寸完全由外部决定，
/// 字号、图标与间距参数均按行高换算，便于在不同尺寸的组件中复用。
class WSIconInfoView: UIView {
    
    // MARK: - 尺寸参数
    /// 图标边长占行高的比例及范围
    var iconHeightRatio: CGFloat = 0.6
    var iconMinSide: CGFloat = 18.0
    var iconMaxSide: CGFloat = 30.0
    
    /// 图标字号占图标边长的比例
    var iconFontRatio: CGFloat = 0.5
    
    /// 图标与信息、信息与配件之间的间距
    var iconInfoSpacing: CGFloat = 4.0
    var infoAccessorySpacing: CGFloat = 4.0
    
    /// 标题字号占行高的比例及范围
    var titleFontRatio: CGFloat = 0.3
    var titleMinFontSize: CGFloat = 13.0
    var titleMaxFontSize: CGFloat = 15.0
    
    /// 副标题字号占行高的比例及范围
    var subtitleFontRatio: CGFloat = 0.22
    var subtitleMinFontSize: CGFloat = 8.0
    var subtitleMaxFontSize: CGFloat = 13.0
    
    /// 副标题与标题的间距占行高的比例
    var subtitleSpacingRatio: CGFloat = 0.05
    
    // MARK: - 子视图
    /// 图标视图
    let iconView = TPIconView()
    
    /// 信息视图
    let infoView = TPInfoView()
    
    /// 右侧配件视图
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
    
    /// 右侧配件尺寸
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
        self.padding = UIEdgeInsets(vertical: 2.0)
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
        
        /// 图标靠左垂直居中
        let iconSide = min(max(floor(contentFrame.height * iconHeightRatio), iconMinSide), iconMaxSide)
        
        let isSizeChanged = laidOutSize != contentFrame.size
        laidOutSize = contentFrame.size
        if isSizeChanged {
            updateFonts(in: contentFrame, iconSide: iconSide)
        }
        
        iconView.size = CGSize(width: iconSide, height: iconSide)
        iconView.left = contentFrame.minX
        iconView.centerY = contentFrame.midY
        iconView.cornerRadius = iconSide / 2.0
        
        /// 配件靠右垂直居中
        var infoRight = contentFrame.maxX
        if let accessoryView = accessoryView {
            accessoryView.size = accessorySize
            accessoryView.right = contentFrame.maxX
            accessoryView.centerY = contentFrame.midY
            infoRight = accessoryView.left - infoAccessorySpacing
        }
        
        /// 信息区占据中间的剩余空间
        let infoLeft = iconView.right + iconInfoSpacing
        infoView.frame = CGRect(x: infoLeft,
                                y: contentFrame.minY,
                                width: max(0.0, infoRight - infoLeft),
                                height: contentFrame.height)
    }
    
    /// 按行高更新字号
    private func updateFonts(in contentFrame: CGRect, iconSide: CGFloat) {
        let titleFontSize = min(max(floor(contentFrame.height * titleFontRatio), titleMinFontSize),
                                titleMaxFontSize)
        infoView.titleConfig.font = .systemFont(ofSize: titleFontSize, weight: .semibold)
        
        let subtitleFontSize = min(max(floor(contentFrame.height * subtitleFontRatio), subtitleMinFontSize),
                                   subtitleMaxFontSize)
        infoView.subtitleConfig.font = .systemFont(ofSize: subtitleFontSize, weight: .medium)
        infoView.subtitleTopMargin = max(1.0, floor(contentFrame.height * subtitleSpacingRatio))
        
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
