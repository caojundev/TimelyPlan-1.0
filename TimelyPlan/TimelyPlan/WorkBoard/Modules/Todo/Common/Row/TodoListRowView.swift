//
//  TodoListRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/3.
//

import Foundation
import UIKit

// MARK: - 行视图

/// 待办清单行视图。
///
/// 左侧展示清单图标，右侧展示清单名称；没有对应清单的行展示骨架。
class TodoListRowView: WSRowView {
    
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
        static let iconMinSide: CGFloat = 18.0
        static let iconMaxSide: CGFloat = 26.0
        
        /// 图标与名称的间距
        static let iconTitleSpacing: CGFloat = 8.0
        
        /// 骨架块颜色。组件底色偏亮，骨架块需要更明显的对比
        static let skeletonColor = Color(light: 0x000000, 0.12, dark: 0xFFFFFF, 0.22)
    }
    
    /// 当前展示的清单
    private(set) var dataItem: TodoListDataItem?
    
    /// 内容与行边缘的间距
    var contentInsets: UIEdgeInsets = Metrics.contentInsets {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 点击行的回调
    var didSelectListHandler: ((TodoListDataItem) -> Void)?
    
    /// 清单图标
    let iconView = TPIconView()
    
    /// 清单名称
    let infoView = TPInfoView()
    
    /// 上一次布局的图标边长，用于避免重复设置字号
    private var laidOutIconSide: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentCornerRadius = Metrics.cornerRadius
        
        let titleConfig = TPLabelConfig.withFont(Metrics.titleFont,
                                                 textColor: .label,
                                                 adjustsFontSizeToFitWidth: true,
                                                 minimumScaleFactor: 0.8)
        infoView.titleConfig = titleConfig
        
        /// 图标不参与骨架，名称以胶囊块占位
        iconView.isSkeletonExcluded = true
        infoView.titleLabel.isSkeletonable = true
        infoView.titleLabel.skeletonShape = .capsule
        infoView.titleLabel.skeletonWidthRatio = 0.5
        
        /// 组件底色偏亮，骨架块需要更明显的对比
        var skeletonConfig = Skeleton.config
        skeletonConfig.baseColor = Metrics.skeletonColor
        self.skeletonConfig = skeletonConfig
        
        addSubview(iconView)
        addSubview(infoView)
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
        
        /// 图标靠左垂直居中
        let iconSide = min(max(floor(layoutFrame.height * Metrics.iconHeightRatio), Metrics.iconMinSide),
                           Metrics.iconMaxSide)
        iconView.size = CGSize(width: iconSide, height: iconSide)
        iconView.left = layoutFrame.minX
        iconView.centerY = layoutFrame.midY
        
        if laidOutIconSide != iconSide {
            laidOutIconSide = iconSide
            iconView.font = .systemFont(ofSize: floor(iconSide * 0.9))
        }
        
        /// 名称占据图标右侧的剩余空间
        let infoLeft = iconView.right + Metrics.iconTitleSpacing
        infoView.frame = CGRect(x: infoLeft,
                                y: layoutFrame.minY,
                                width: max(layoutFrame.maxX - infoLeft, 0.0),
                                height: layoutFrame.height)
    }
    
    // MARK: - 渲染
    /// 更新展示的清单。传 nil 时清空内容并展示骨架
    func update(with dataItem: TodoListDataItem?) {
        self.dataItem = dataItem
        
        guard let dataItem = dataItem else {
            iconView.icon = nil
            infoView.title = nil
            
            /// 骨架态保留名称一行高度，Skeleton 才能生成文本占位块
            infoView.titleMinimumHeight = ceil(infoView.titleConfig.font.lineHeight)
            
            setNeedsLayout()
            layoutIfNeeded()
            sk.show(config: skeletonConfig)
            return
        }
        
        sk.hide()
        infoView.titleMinimumHeight = 0.0
        iconView.icon = dataItem.icon
        iconView.foreColor = dataItem.color
        infoView.title = dataItem.title
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
