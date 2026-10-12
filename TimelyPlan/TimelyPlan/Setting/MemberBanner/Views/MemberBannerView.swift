//
//  MemberBannerView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/11.
//

import Foundation
import UIKit

/// 会员横幅容器
final class MemberBannerView: UIView {

    // MARK: - 子视图

    /// 会员金卡（外部可通过它设置 `delegate`，接收「查看权益」点击）
    let cardView = MemberBannerCard()

    // MARK: - 数据

    /// 会员状态：设置后自动绑定给 `cardView`
    var status: MemberStatus? {
        didSet {
            guard let status = status else { return }
            cardView.bind(status)
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }

    // MARK: - 配置

    /// 内容内间距（卡片四周留白）
    var contentPadding: UIEdgeInsets = .zero {
        didSet {
            if contentPadding != oldValue {
                setNeedsLayout()
                invalidateIntrinsicContentSize()
            }
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupView() {
        backgroundColor = .clear
        addSubview(cardView)
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()

        let contentFrame = bounds.inset(by: contentPadding)
        let cardWidth = max(0, contentFrame.width)
        cardView.frame = CGRect(x: contentFrame.minX,
                                y: contentFrame.minY,
                                width: cardWidth,
                                height: Self.cardHeight(forWidth: cardWidth))
    }

    static func cardHeight(forWidth width: CGFloat) -> CGFloat {
        MemberBannerCard.preferredHeight(forWidth: width)
    }

    /// 整体推荐高度（卡片高度 + 上下留白），供外部布局参考
    func recommendedHeight(forWidth width: CGFloat) -> CGFloat {
        let cardWidth = width - contentPadding.horizontalLength
        return Self.cardHeight(forWidth: cardWidth) + contentPadding.verticalLength
    }

    override var intrinsicContentSize: CGSize {
        let cardWidth = bounds.width - contentPadding.horizontalLength
        return CGSize(width: UIView.noIntrinsicMetric,
                      height: Self.cardHeight(forWidth: cardWidth) + contentPadding.verticalLength)
    }
}
