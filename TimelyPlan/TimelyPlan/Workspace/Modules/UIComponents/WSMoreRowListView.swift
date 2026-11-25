//
//  WSMoreRowListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/5.
//

import Foundation
import UIKit

// MARK: - 带更多入口的行列表视图

/// 带「更多」入口的通用行列表视图。
///
/// 在 `WSRowListView` 的基础上记录条目总数，当总数超出当前展示条数时，
/// 最后一个条目位让给「更多 x 个」入口，行高与总高度保持不变；点击入口由外部处理。
/// 网格布局下入口只占一个条目位，不会整行让出。
class WSMoreRowListView: WSRowListView {

    // MARK: - 配置
    /// 条目总数。超出展示条数时展示更多入口
    var totalItemCount: Int = 0 {
        didSet {
            guard totalItemCount != oldValue else {
                return
            }

            setNeedsLayout()
        }
    }

    /// 点击更多入口回调
    var didSelectMoreHandler: (() -> Void)?

    /// 未展示的条目数
    var overflowCount: Int {
        guard totalItemCount > numberOfItems else {
            return 0
        }

        return max(totalItemCount - displayedItemCount, 0)
    }

    /// 实际展示的条目数。有更多入口时最后一个条目位让给入口
    private var displayedItemCount: Int {
        guard totalItemCount > numberOfItems else {
            return min(totalItemCount, numberOfItems)
        }

        return max(numberOfItems - 1, 0)
    }

    /// 是否展示更多入口
    private var showsMoreEntry: Bool {
        return overflowCount > 0
    }

    // MARK: - 更多入口
    /// 更多入口。条目未展示完时占据最后一行
    private let moreButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.cornerRadius = .greatestFiniteMagnitude
        button.padding = UIEdgeInsets(top: 6.0, left: 10.0, bottom: 6.0, right: 10.0)
        button.titleConfig.font = .boldSystemFont(ofSize: 12.0)
        button.titleConfig.textColor = .white
        button.normalBackgroundColor = .primary
        button.selectedBackgroundColor = .primary
        button.isHidden = true
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(moreButton)
        moreButton.didClickHandler = { [weak self] in
            self?.didSelectMoreHandler?()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutMoreEntry()
    }

    /// 布局更多入口。超出展示条数时隐藏最后一个条目位，把入口放在该条目位上
    private func layoutMoreEntry() {
        let showsMore = showsMoreEntry
        if moreButton.isHidden != !showsMore {
            moreButton.isHidden = !showsMore
        }

        guard numberOfItems > 0 else {
            return
        }

        /// 网格下只让出一个条目位，其余同行条目照常展示
        let moreIndex = numberOfItems - 1
        for (index, rowView) in rowViews.enumerated() {
            rowView.isHidden = showsMore && index == moreIndex
        }

        guard showsMore else {
            return
        }

        moreButton.title = String(format: resGetString("More %ld"), overflowCount)
        moreButton.sizeToFit()

        let itemFrame = itemLayoutFrame(at: moreIndex)
        if columnCount > 1 {
            moreButton.center = CGPoint(x: itemFrame.midX, y: itemFrame.midY)
        } else {
            moreButton.left = itemFrame.minX
            moreButton.centerY = itemFrame.midY
        }
    }
}
