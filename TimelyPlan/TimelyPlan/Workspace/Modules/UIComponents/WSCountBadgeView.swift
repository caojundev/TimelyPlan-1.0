//
//  WSCountBadgeView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/5.
//

import Foundation
import UIKit

// MARK: - 数目徽标

/// 通用数目徽标。以胶囊样式展示数量，高度与最小宽度可调整
class WSCountBadgeView: TPLabel {

    /// 数目
    var count: Int = 0 {
        didSet {
            text = "\(count)"
            setNeedsLayout()
        }
    }

    /// 徽标高度
    var badgeHeight: CGFloat = 28.0 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    /// 徽标最小宽度，单位为 1 位数时保持正圆
    var minimumWidth: CGFloat = 28.0 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        font = .boldSystemFont(ofSize: 13.0)
        textColor = .secondaryLabel
        textAlignment = .center
        backgroundColor = Color(light: 0x000000, 0.06, dark: 0xFFFFFF, 0.12)
        edgeInsets = UIEdgeInsets(horizontal: 6.0)
        clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 布局
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let fittedSize = super.sizeThatFits(CGSize(width: .greatestFiniteMagnitude,
                                                  height: badgeHeight))
        return CGSize(width: max(ceil(fittedSize.width), minimumWidth), height: badgeHeight)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = height / 2.0
    }
}
