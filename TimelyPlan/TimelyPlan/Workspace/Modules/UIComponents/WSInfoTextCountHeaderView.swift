//
//  WSInfoTextCountHeaderView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/5.
//

import Foundation
import UIKit

// MARK: - 文案 + 数目头部

/// 通用「标题 + 数目徽标」头部视图。
///
/// 用于分组、日期等需要同时展示名称与数量的场景，标题样式可通过 `titleLabel` 调整。
class WSInfoTextCountHeaderView: UIView {

    // MARK: - 配置
    /// 头部高度
    var headerHeight: CGFloat = 18.0 {
        didSet {
            setNeedsLayout()
        }
    }

    /// 标题与徽标的间距
    var spacing: CGFloat = 6.0 {
        didSet {
            setNeedsLayout()
        }
    }

    /// 标题标签
    let titleLabel: TPLabel = {
        let label = TPLabel()
        label.font = .boldSystemFont(ofSize: 12.0)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    /// 数目徽标
    let countBadgeView: WSCountBadgeView = {
        let view = WSCountBadgeView()
        view.font = .boldSystemFont(ofSize: 10.0)
        view.badgeHeight = 18.0
        view.minimumWidth = 18.0
        view.edgeInsets = UIEdgeInsets(horizontal: 5.0)
        view.isHidden = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)
        addSubview(countBadgeView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 数据
    /// 更新标题与数目。数目为 0 时不展示徽标
    func update(title: String?, count: Int) {
        titleLabel.text = title
        countBadgeView.count = count
        countBadgeView.isHidden = count <= 0
        setNeedsLayout()
    }

    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()

        let layoutFrame = bounds
        guard layoutFrame.width > 0.0, layoutFrame.height > 0.0 else {
            return
        }

        titleLabel.sizeToFit()
        titleLabel.height = headerHeight
        titleLabel.left = layoutFrame.minX
        titleLabel.centerY = layoutFrame.midY

        guard !countBadgeView.isHidden else {
            return
        }

        let badgeSize = countBadgeView.sizeThatFits(CGSize(width: .greatestFiniteMagnitude,
                                                           height: headerHeight))
        countBadgeView.size = badgeSize
        countBadgeView.left = titleLabel.right + spacing
        countBadgeView.centerY = layoutFrame.midY
    }
}
