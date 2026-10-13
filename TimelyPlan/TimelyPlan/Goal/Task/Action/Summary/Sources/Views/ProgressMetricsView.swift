import UIKit

/// 指标区：三列等宽，每列「数值 + 单位」与「说明文字」。
final class ProgressMetricsView: UIView {

    struct Item {
        /// 主数值，如「6」。
        let value: String
        /// 紧跟数值的单位，如「/16」「%」「 天」。以更小字号弱化显示。
        let unit: String
        /// 标题，如「剩余量」。
        let caption: String
        /// 数值颜色，nil 使用主题主文本色。
        let valueColor: UIColor?

        init(value: String, unit: String = "", caption: String, valueColor: UIColor? = nil) {
            self.value = value
            self.unit = unit
            self.caption = caption
            self.valueColor = valueColor
        }
    }

    var theme: ProgressTheme = .standard {
        didSet { applyTheme() }
    }

    var items: [Item] = [] {
        didSet { rebuildColumns() }
    }

    // MARK: - 布局常量

    private enum Metrics {
        /// 数值字号
        static let valueFont = UIFont.systemFont(ofSize: 19, weight: .bold)
        /// 单位字号
        static let unitFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
        /// 说明文字字号
        static let captionFont = UIFont.systemFont(ofSize: 11, weight: .regular)
        /// 数值行与说明行的间距
        static let captionSpacing: CGFloat = 4.0
    }

    /// 每列一个信息视图
    private var columns: [TPInfoView] = []

    /// 供卡片计算布局使用的高度：数值行 + 间距 + 说明行。
    var preferredHeight: CGFloat {
        ceil(Metrics.valueFont.lineHeight) + Metrics.captionSpacing + ceil(Metrics.captionFont.lineHeight)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }

    // MARK: - 内容

    private func rebuildColumns() {
        columns.forEach { $0.removeFromSuperview() }
        columns.removeAll()

        for item in items {
            let column = newColumnView()
            configure(column, with: item)
            addSubview(column)
            columns.append(column)
        }
        setNeedsLayout()
    }

    private func applyTheme() {
        zip(columns, items).forEach { configure($0, with: $1) }
    }

    /// 创建一列（标题 = 数值 + 单位，副标题 = 说明文字）
    private func newColumnView() -> TPInfoView {
        let column = TPInfoView()
        column.titleConfig.font = Metrics.valueFont
        column.titleConfig.textAlignment = .center
        column.titleConfig.adjustsFontSizeToFitWidth = true
        column.titleConfig.minimumScaleFactor = 0.7

        column.subtitleConfig.font = Metrics.captionFont
        column.subtitleConfig.textAlignment = .center
        column.subtitleTopMargin = Metrics.captionSpacing
        return column
    }

    private func configure(_ column: TPInfoView, with item: Item) {
        column.title = attributedValue(of: item)
        column.subtitle = item.caption
        column.subtitleConfig.textColor = theme.secondaryText
    }

    /// 「数值 + 单位」富文本：单位用更小字号与次要色弱化。
    private func attributedValue(of item: Item) -> ASAttributedString {
        let text = NSMutableAttributedString(
            string: item.value,
            attributes: [
                .font: Metrics.valueFont,
                .foregroundColor: item.valueColor ?? theme.primaryText
            ]
        )
        if !item.unit.isEmpty {
            text.append(NSAttributedString(
                string: item.unit,
                attributes: [
                    .font: Metrics.unitFont,
                    .foregroundColor: theme.secondaryText
                ]
            ))
        }

        return ASAttributedString(text)
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()
        guard !columns.isEmpty else { return }

        let columnWidth = bounds.width / CGFloat(columns.count)
        for (index, column) in columns.enumerated() {
            column.frame = CGRect(x: CGFloat(index) * columnWidth,
                                  y: 0,
                                  width: columnWidth,
                                  height: bounds.height)
        }
    }
}
