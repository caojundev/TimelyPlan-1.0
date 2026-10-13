//
//  GoalSummaryLegendView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/13.
//

import Foundation
import UIKit

/// 图例：色环 + 名称（含一行副文案）+ 数值，逐行排列。
///
/// 百分比数值放在这里（而非圆心），让圆心专注表达状态。
final class GoalSummaryLegendView: UIView {

    struct Item {
        /// 色环颜色。
        let color: UIColor
        /// 名称，如「任务完成进度」。
        let title: String
        /// 副文案，如「0 → 16 · 6」「8月1日 - 12月31日」。
        let subtitle: String
        /// 数值，如「38%」。
        let value: String
    }

    var theme: GoalSummaryTheme = .standard {
        didSet { applyTheme() }
    }

    var items: [Item] = [] {
        didSet { rebuildRows() }
    }

    private var rows: [RowView] = []

    /// 单行高度：两行文案（名称 + 副文案），与 `RowView` 内的排版保持一致。
    private var rowHeight: CGFloat { RowView.rowHeight }

    private let rowSpacing: CGFloat = 9

    /// 供卡片计算布局使用的高度。
    var preferredHeight: CGFloat {
        guard !items.isEmpty else { return 0 }
        return CGFloat(items.count) * rowHeight + CGFloat(items.count - 1) * rowSpacing
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }

    private func rebuildRows() {
        rows.forEach { $0.removeFromSuperview() }
        rows.removeAll()

        for item in items {
            let row = RowView(frame: .zero)
            row.configure(with: item, theme: theme)
            addSubview(row)
            rows.append(row)
        }
        setNeedsLayout()
    }

    private func applyTheme() {
        zip(rows, items).forEach { pair in
            pair.0.configure(with: pair.1, theme: theme)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        var y: CGFloat = 0
        for row in rows {
            row.frame = CGRect(x: 0, y: y, width: bounds.width, height: rowHeight)
            y += rowHeight + rowSpacing
        }
    }
}

// MARK: - 单行

private final class RowView: UIView {

    /// 名称字号
    static let titleFont = UIFont.systemFont(ofSize: 13, weight: .bold)
    /// 副文案字号
    static let subtitleFont = UIFont.systemFont(ofSize: 10, weight: .medium)
    /// 名称与副文案的间距
    static let subtitleSpacing: CGFloat = 2
    /// 行内上下留白
    static let rowPadding: CGFloat = 4

    /// 单行高度：名称行 + 间距 + 副文案行 + 上下留白，供 `GoalSummaryLegendView` 排版使用。
    static var rowHeight: CGFloat {
        ceil(titleFont.lineHeight) + subtitleSpacing + ceil(subtitleFont.lineHeight) + rowPadding * 2
    }

    private let dot = UIView()
    private let infoView = TPInfoView()
    private let valueLabel = UILabel()

    private let dotSize: CGFloat = 14
    private let dotToTitle: CGFloat = 9
    private let titleToValue: CGFloat = 8

    /// 保留色值，以便外观切换时重刷 `cgColor`。
    private var dotColor: UIColor = .clear

    override init(frame: CGRect) {
        super.init(frame: frame)

        dot.backgroundColor = .clear
        dot.layer.borderWidth = 3.5
        dot.layer.cornerRadius = dotSize / 2

        /// 名称 + 副文案
        infoView.titleConfig.font = Self.titleFont
        infoView.subtitleConfig.font = Self.subtitleFont
        infoView.subtitleTopMargin = Self.subtitleSpacing

        valueLabel.alpha = 0.8
        valueLabel.font = .boldSystemFont(ofSize: 15.0)
        valueLabel.textAlignment = .right

        addSubview(dot)
        addSubview(infoView)
        addSubview(valueLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: GoalSummaryLegendView.Item, theme: GoalSummaryTheme) {
        dotColor = item.color
        dot.layer.borderColor = item.color.cgColor

        infoView.title = item.title
        infoView.titleConfig.textColor = theme.primaryText

        infoView.subtitle = item.subtitle
        infoView.subtitleConfig.textColor = theme.secondaryText

        valueLabel.text = item.value
        valueLabel.textColor = theme.primaryText
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        dot.frame = CGRect(x: 0, y: (bounds.height - dotSize) / 2, width: dotSize, height: dotSize)

        let valueWidth = ceil(valueLabel.sizeThatFits(
            CGSize(width: .greatestFiniteMagnitude, height: bounds.height)
        ).width)

        let infoX = dotSize + dotToTitle
        let infoWidth = max(bounds.width - infoX - valueWidth - titleToValue, 0)

        /// 文案块（名称 + 副文案）在行内垂直居中
        infoView.frame = CGRect(x: infoX, y: 0, width: infoWidth, height: bounds.height)
        valueLabel.frame = CGRect(x: bounds.width - valueWidth, y: 0, width: valueWidth, height: bounds.height)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        dot.layer.borderColor = dotColor.cgColor
    }
}
