import UIKit

/// 卡片底部的状态提示条：图标 + 说明文字，整体使用状态色浅底。
///
/// 布局交给 `TPImageInfoView`：图标由左配件承担，文案由 `titleLabel` 承担，
/// 因此这里只负责规格与内容配置。
final class GoalSummaryNoteView: TPImageInfoView {

    // MARK: - 布局常量

    private enum Metrics {
        /// 内间距
        static let padding = UIEdgeInsets(horizontal: 12.0, vertical: 9.0)
        /// 圆角
        static let cornerRadius: CGFloat = 11.0
        /// 图标尺寸
        static let iconSize = CGSize(value: 15.0)
        /// 图标与文案的间距
        static let iconSpacing: CGFloat = 7.0
        /// 文案字号
        static let titleFont = UIFont.systemFont(ofSize: 12.5, weight: .semibold)
        /// 图标字号
        static let symbolPointSize: CGFloat = 12.0
    }

    // MARK: - 初始化

    override func setupSubviews() {
        super.setupSubviews()

        layer.cornerRadius = Metrics.cornerRadius
        layer.masksToBounds = true

        /// 内间距与左配件（图标）规格
        padding = Metrics.padding
        leftAccessorySize = Metrics.iconSize
        leftAccessoryMargins = UIEdgeInsets(right: Metrics.iconSpacing)

        imageConfig.size = Metrics.iconSize
        imageConfig.margins = UIEdgeInsets(right: Metrics.iconSpacing)
        imageConfig.shouldRenderImageWithColor = true

        /// 说明文字可换行
        titleConfig.font = Metrics.titleFont
        titleConfig.numberOfLines = 0

        /// 不使用副标题，测量时也无需为其留出间距
        subtitleTopMargin = 0
    }

    // MARK: - 配置

    /// 配置内容。
    func configure(text: String, symbolName: String, tint: UIColor) {
        imageContent = .withImage(UIImage(systemName: symbolName)?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: Metrics.symbolPointSize,
                                                           weight: .semibold)))
        imageConfig.color = tint

        title = text
        titleConfig.textColor = tint

        backgroundColor = tint.withAlphaComponent(0.12)
        setNeedsLayout()
    }

    /// 给定宽度下所需的高度，供卡片手动布局计算。
    func height(for width: CGFloat) -> CGFloat {
        let layout = TPInfoViewLayout()
        layout.titleContent = titleContent
        layout.titleConfig = titleConfig
        layout.padding = padding
        layout.subtitleTopMargin = subtitleTopMargin
        layout.leftAccessorySize = leftAccessorySize
        layout.leftAccessoryMargins = leftAccessoryMargins
        return ceil(layout.boundingSize(with: width).height)
    }
}
