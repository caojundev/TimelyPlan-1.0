//
//  WSIconInfoTextValueContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/5.
//

import Foundation
import UIKit

// MARK: - 带图标标题的组件内容视图

/// 带图标信息标题的通用组件内容视图。
///
/// 头部使用 `TPIconInfoTextValueView` 展示图标与标题，右侧可展示数目徽标；
/// 子类只需覆写 `layoutContent(in:)`，在头部以下的内容区域内排布自身内容。
class WSIconInfoTextValueContentView: WSPluginContentView {

    // MARK: - 配置
    /// 内容与组件边缘的间距
    var contentInsets: UIEdgeInsets = UIEdgeInsets(value: 8.0) {
        didSet {
            setNeedsLayout()
        }
    }

    /// 头部高度
    var headerHeight: CGFloat = 30.0 {
        didSet {
            setNeedsLayout()
        }
    }

    /// 头部与内容的间距
    var headerSpacing: CGFloat = 6.0 {
        didSet {
            setNeedsLayout()
        }
    }

    /// 图标边长
    var iconSide: CGFloat = 28.0 {
        didSet {
            updateIconConfig()
            setNeedsLayout()
        }
    }

    /// 图标圆角
    var iconCornerRadius: CGFloat = .greatestFiniteMagnitude {
        didSet {
            headerView.iconView.cornerRadius = iconCornerRadius
            setNeedsLayout()
        }
    }

    /// 图标与标题的间距
    var iconSpacing: CGFloat = 8.0 {
        didSet {
            updateIconConfig()
            setNeedsLayout()
        }
    }

    /// 标题与右侧徽标的间距
    var countSpacing: CGFloat = 8.0 {
        didSet {
            setNeedsLayout()
        }
    }

    // MARK: - 头部
    /// 头部信息视图
    let headerView: TPIconInfoTextValueView = {
        let view = TPIconInfoTextValueView()
        view.titleConfig.font = .boldSystemFont(ofSize: 14.0)
        view.titleConfig.adjustsFontSizeToFitWidth = true
        view.titleConfig.minimumScaleFactor = 0.8
        return view
    }()

    /// 头部右侧的数目徽标
    let countBadgeView: WSCountBadgeView = {
        let view = WSCountBadgeView()
        view.isHidden = true
        return view
    }()

    /// 头部以下的内容区域，由子类在 `layoutContent(in:)` 中使用
    private(set) var contentLayoutFrame: CGRect = .zero

    /// 图标配置
    private var iconConfig: TPIconAccessoryConfig?

    override init(frame: CGRect) {
        super.init(frame: frame)

        headerView.iconView.cornerRadius = iconCornerRadius
        addSubview(headerView)
        addSubview(countBadgeView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 数据
    /// 更新头部信息。数目为 0 时不展示徽标
    func updateHeader(title: String?,
                      icon: TPIcon?,
                      iconBackColor: UIColor = .primary,
                      iconForeColor: UIColor = .white,
                      count: Int = 0) {
        headerView.title = title

        let config = TPIconAccessoryConfig()
        config.size = CGSize(value: iconSide)
        config.margins = UIEdgeInsets(right: iconSpacing)
        config.icon = icon
        config.foreColor = iconForeColor
        config.backColor = iconBackColor
        iconConfig = config
        headerView.iconConfig = config

        countBadgeView.count = count
        countBadgeView.isHidden = count <= 0
        setNeedsLayout()
    }

    /// 图标尺寸或间距变化后重新应用配置
    private func updateIconConfig() {
        guard let iconConfig = iconConfig else {
            return
        }

        iconConfig.size = CGSize(value: iconSide)
        iconConfig.margins = UIEdgeInsets(right: iconSpacing)
        headerView.iconConfig = iconConfig
    }

    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()

        let layoutFrame = bounds.inset(by: contentInsets)
        guard layoutFrame.width > 0.0, layoutFrame.height > 0.0 else {
            contentLayoutFrame = .zero
            return
        }

        /// 徽标优先占用头部右侧空间
        var headerFrame = CGRect(x: layoutFrame.minX,
                                 y: layoutFrame.minY,
                                 width: layoutFrame.width,
                                 height: headerHeight)
        if !countBadgeView.isHidden {
            let badgeSize = countBadgeView.sizeThatFits(CGSize(width: .greatestFiniteMagnitude,
                                                               height: headerHeight))
            countBadgeView.size = badgeSize
            countBadgeView.right = layoutFrame.maxX
            countBadgeView.centerY = layoutFrame.minY + headerHeight / 2.0
            headerFrame.size.width = max(countBadgeView.left - countSpacing - layoutFrame.minX, 0.0)
        }
        headerView.frame = headerFrame

        let contentHeight = max(layoutFrame.height - headerHeight - headerSpacing, 0.0)
        contentLayoutFrame = CGRect(x: layoutFrame.minX,
                                    y: layoutFrame.minY + headerHeight + headerSpacing,
                                    width: layoutFrame.width,
                                    height: contentHeight)
        layoutContent(in: contentLayoutFrame)
    }

    /// 子类在头部以下的内容区域内排布内容
    func layoutContent(in frame: CGRect) {
        
    }
}
