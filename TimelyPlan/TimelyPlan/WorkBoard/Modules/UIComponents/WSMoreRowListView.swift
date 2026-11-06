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
/// 最后一行让给「更多 x 个」入口，行高与总高度保持不变；点击入口由外部处理。
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

    /// 实际展示的条目数。有更多入口时最后一行让给入口
    private var displayedItemCount: Int {
        guard totalItemCount > numberOfItems else {
            return min(totalItemCount, numberOfItems)
        }

        return max(numberOfItems - max(columnCount, 1), 0)
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

    /// 布局更多入口。超出展示条数时隐藏最后一行，把入口放在该行的位置
    private func layoutMoreEntry() {
        let showsMore = showsMoreEntry
        if moreButton.isHidden != !showsMore {
            moreButton.isHidden = !showsMore
        }

        guard numberOfItems > 0 else {
            return
        }

        /// 最后一行的行视图让给更多入口
        let columns = max(columnCount, 1)
        let lastRowStartIndex = max(rowCount - 1, 0) * columns
        for (index, rowView) in rowViews.enumerated() where index >= lastRowStartIndex {
            rowView.isHidden = showsMore
        }

        guard showsMore else {
            return
        }

        moreButton.title = String(format: resGetString("More %ld"), overflowCount)
        moreButton.sizeToFit()

        let layoutFrame = rowsLayoutFrame
        let rowFrame = itemLayoutFrame(at: lastRowStartIndex)
        moreButton.left = layoutFrame.minX
        moreButton.centerY = rowFrame.midY
    }
}
