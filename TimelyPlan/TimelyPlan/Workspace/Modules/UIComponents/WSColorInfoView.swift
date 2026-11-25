//
//  WSColorInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/24.
//

import Foundation
import UIKit

// MARK: - 颜色信息视图

/// 颜色条 + 信息 + 右侧配件的通用行视图。
///
/// 左侧颜色条（圆角竖条）垂直居中，右侧配件垂直居中，信息区占据中间剩余空间。
/// 视图本身不处理点击，交互由外部或配件视图自行处理；尺寸完全由外部决定，
/// 字号与间距参数均按行高换算，便于在不同尺寸的组件中复用。
class WSColorInfoView: UIView {
    
    // MARK: - 尺寸参数
    /// 颜色条宽度
    var colorBarWidth: CGFloat = 6.0
    
    /// 颜色条高度占行高的比例及范围
    var colorBarHeightRatio: CGFloat = 0.6
    var colorBarMinHeight: CGFloat = 18.0
    var colorBarMaxHeight: CGFloat = 24.0
    
    /// 颜色条与信息、信息与配件之间的间距
    var colorInfoSpacing: CGFloat = 8.0
    var infoAccessorySpacing: CGFloat = 4.0
    
    /// 标题字号占行高的比例及范围
    var titleFontRatio: CGFloat = 0.3
    var titleMinFontSize: CGFloat = 13.0
    var titleMaxFontSize: CGFloat = 15.0
    
    /// 副标题字号占行高的比例及范围
    var subtitleFontRatio: CGFloat = 0.24
    var subtitleMinFontSize: CGFloat = 8.0
    var subtitleMaxFontSize: CGFloat = 12.0
    
    /// 副标题与标题的间距占行高的比例
    var subtitleSpacingRatio: CGFloat = 0.03
    
    /// 骨架配置
    var skeletonConfig: SkeletonConfig = Skeleton.config
    
    // MARK: - 子视图
    /// 颜色条
    let colorView = UIView()
    
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
    
    /// 上一次布局时骨架是否展示
    private var wasSkeletonShowing = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = .zero
        self.backgroundColor = .clear
        
        colorView.clipsToBounds = true
        
        infoView.titleConfig.textColor = .label
        infoView.subtitleConfig.textColor = .secondaryLabel
        infoView.subtitleConfig.alpha = 1.0
        infoView.subtitleConfig.numberOfLines = 2
        addSubview(colorView)
        addSubview(infoView)
        
        /// 骨架标记：直接标记真实子视图，由 Skeleton 统一绘制
        colorView.isSkeletonable = true
        colorView.skeletonShape = .capsule
        
        infoView.titleLabel.isSkeletonable = true
        infoView.titleLabel.skeletonShape = .capsule
        infoView.titleLabel.skeletonWidthRatio = 0.6
        
        infoView.subtitleLabel.isSkeletonable = true
        infoView.subtitleLabel.skeletonShape = .capsule
        infoView.subtitleLabel.skeletonWidthRatio = 0.45
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
        
        let isSizeChanged = laidOutSize != contentFrame.size
        laidOutSize = contentFrame.size
        if isSizeChanged {
            updateFonts(in: contentFrame)
        }
        
        /// 颜色条靠左垂直居中
        let barHeight = min(max(floor(contentFrame.height * colorBarHeightRatio), colorBarMinHeight),
                            colorBarMaxHeight)
        colorView.size = CGSize(width: colorBarWidth, height: min(barHeight, contentFrame.height))
        colorView.left = contentFrame.minX
        colorView.centerY = contentFrame.midY
        colorView.layer.cornerRadius = colorBarWidth / 2.0
        
        /// 配件靠右垂直居中
        var infoRight = contentFrame.maxX
        if let accessoryView = accessoryView {
            accessoryView.size = accessorySize
            accessoryView.right = contentFrame.maxX
            accessoryView.centerY = contentFrame.midY
            infoRight = accessoryView.left - infoAccessorySpacing
        }
        
        /// 信息区占据中间的剩余空间
        let infoLeft = colorView.right + colorInfoSpacing
        infoView.frame = CGRect(x: infoLeft,
                                y: contentFrame.minY,
                                width: max(0.0, infoRight - infoLeft),
                                height: contentFrame.height)
        
        /// 骨架态下保持标题 / 副标题一行高度，Skeleton 才能生成文本占位块
        let isSkeleton = sk.isShowing
        infoView.titleMinimumHeight = isSkeleton ? ceil(infoView.titleConfig.font.lineHeight) : 0.0
        infoView.subtitleMinimumHeight = isSkeleton ? ceil(infoView.subtitleConfig.font.lineHeight) : 0.0
        
        /// 骨架首次展示或尺寸变化时，按最新布局重算骨架块
        if isSkeleton, isSizeChanged || !wasSkeletonShowing {
            infoView.layoutIfNeeded()
            sk.reload()
        }
        
        wasSkeletonShowing = isSkeleton
    }
    
    /// 按行高更新字号
    private func updateFonts(in contentFrame: CGRect) {
        let titleFontSize = min(max(floor(contentFrame.height * titleFontRatio), titleMinFontSize),
                                titleMaxFontSize)
        infoView.titleConfig.font = .systemFont(ofSize: titleFontSize, weight: .semibold)
        
        let subtitleFontSize = min(max(floor(contentFrame.height * subtitleFontRatio), subtitleMinFontSize),
                                   subtitleMaxFontSize)
        infoView.subtitleConfig.font = .systemFont(ofSize: subtitleFontSize, weight: .medium)
        infoView.subtitleTopMargin = max(1.0, floor(contentFrame.height * subtitleSpacingRatio))
        
        infoView.setNeedsLayout()
    }
    
    // MARK: - 渲染
    /// 更新颜色条与文案
    func update(color: UIColor?,
                title: String?,
                subtitle: String?) {
        colorView.backgroundColor = color ?? .clear
        infoView.title = title
        infoView.subtitle = subtitle
    }
}
