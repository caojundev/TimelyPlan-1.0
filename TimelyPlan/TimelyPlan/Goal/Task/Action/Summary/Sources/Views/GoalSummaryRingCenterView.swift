//
//  GoalSummaryRingCenterView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/13.
//

import Foundation
import UIKit

/// 圆心的状态展示：状态图标 + 状态主文案，整体在环心居中。
///
/// 刻意不显示百分比与副文案 —— 圆心承担「一眼判断状态」的职责，
/// 具体数值交给下方图例与指标区。
final class GoalSummaryRingCenterView: UIView {

    // MARK: - 布局常量

    private enum Metrics {
        /// 图标与文案的间距。
        static let iconToTitle: CGFloat = 7
        /// 图标尺寸。
        static let iconSize: CGSize = .size(4)
        /// 状态文案字号。
        static let titleFont: UIFont = .boldSystemFont(ofSize: 13.0)
    }

    private let infoView: TPImageTitleView = {
        let view = TPImageTitleView()
        view.accessoryPosition = .top
        view.accessoryAlignment = .center
        view.imageConfig.size = Metrics.iconSize
        view.imageConfig.margins = UIEdgeInsets(bottom: Metrics.iconToTitle)
        view.imageConfig.shouldRenderImageWithColor = true

        view.titleConfig.font = Metrics.titleFont
        view.titleConfig.textAlignment = .center
        view.titleConfig.adjustsFontSizeToFitWidth = true
        view.titleConfig.minimumScaleFactor = 0.7
        return view
    }()

    // MARK: - 生命周期

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        isUserInteractionEnabled = false

        addSubview(infoView)
    }

    // MARK: - 配置

    /// 配置状态。图标与文案统一使用 `accent`。
    func configure(status: GoalSummaryStatus, accent: UIColor) {
        infoView.image = UIImage(systemName: status.symbolName)?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold))
        infoView.imageConfig.color = accent

        infoView.title = status.title
        infoView.titleConfig.textColor = accent

        setNeedsLayout()
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()

        /// 内容整体在环心居中
        let fitSize = infoView.sizeThatFits(CGSize(width: bounds.width,
                                                   height: .greatestFiniteMagnitude))
        infoView.size = CGSize(width: min(fitSize.width, bounds.width), height: fitSize.height)
        infoView.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
}
