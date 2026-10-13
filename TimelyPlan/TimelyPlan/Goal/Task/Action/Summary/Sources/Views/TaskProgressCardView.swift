import UIKit

/// 目标任务进度卡片：把双环、圆心状态、图例、提示、指标组合在一起。
///
/// 布局全部在 `layoutSubviews` 里用 frame 手动完成，不依赖 AutoLayout。
/// 高度的唯一来源是 `makeFrames(forWidth:)`，`sizeThatFits` 与 `layoutSubviews`
/// 共用同一份计算，避免两处逻辑漂移。
final class TaskProgressCardView: UIView {
 
    // MARK: - 布局常量

    private enum Metrics {
        static let padding: CGFloat = 20
        static let ringToLegend: CGFloat = 14
        static let legendToNote: CGFloat = 13
        static let noteToSeparator: CGFloat = 16
        static let separatorHeight: CGFloat = 1
        static let separatorToMetrics: CGFloat = 16
        static let cornerRadius: CGFloat = 20
    }

    // MARK: - 子视图

    private let theme: ProgressTheme

    private let ringView = ProgressRingView()
    private let centerView = RingCenterView()
    private let legendView = ProgressLegendView()
    private let noteView = ProgressNoteView()
    private let lineSeparatorView = UIView()
    private let metricsView = ProgressMetricsView()

    // MARK: - 初始化

    init(theme: ProgressTheme = .standard, ringMetrics: ProgressRingMetrics = .regular) {
        self.theme = theme
        super.init(frame: .zero)

        ringView.metrics = ringMetrics
        ringView.theme = theme
        legendView.theme = theme
        metricsView.theme = theme

        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        backgroundColor = theme.cardBackground
        layer.cornerRadius = Metrics.cornerRadius
        layer.masksToBounds = false

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 24
        layer.shadowOffset = CGSize(width: 0, height: 8)

        lineSeparatorView.backgroundColor = theme.separator

        addSubview(ringView)
        addSubview(centerView)
        addSubview(legendView)
        addSubview(noteView)
        addSubview(lineSeparatorView)
        addSubview(metricsView)
    }

    // MARK: - 配置

    /// 使用计算好的快照刷新卡片。
    func configure(with snapshot: ProgressSnapshot) {
        let accent = theme.accent(for: snapshot.status)
        let metrics = ringView.metrics

        // 外环 = 任务完成进度；内环 = 日期时间进度
        ringView.rings = [
            ProgressRingView.Ring(radius: metrics.outerRadius,
                                  lineWidth: metrics.outerLineWidth,
                                  progress: CGFloat(snapshot.taskProgress),
                                  color: accent),
            ProgressRingView.Ring(radius: metrics.innerRadius,
                                  lineWidth: metrics.innerLineWidth,
                                  progress: CGFloat(snapshot.timeProgress),
                                  color: theme.timeAccent)
        ]

        // 圆心只表达状态，不显示百分比
        centerView.configure(status: snapshot.status, accent: accent)

        legendView.items = [
            .init(color: accent,
                  title: "任务完成进度",
                  subtitle: "\(snapshot.initialValue)→\(snapshot.targetValue) • \(snapshot.currentValue)",
                  value: snapshot.taskPercentText),
            .init(color: theme.timeAccent,
                  title: "日期时间进度",
                  subtitle: "\(snapshot.startDateText) - \(snapshot.endDateText) • \(snapshot.totalDays) 天",
                  value: snapshot.timePercentText)
        ]

        noteView.configure(text: snapshot.status.hint,
                           symbolName: snapshot.status.symbolName,
                           tint: accent)

        metricsView.items = [
            .init(value: "\(snapshot.targetValue - snapshot.currentValue)",
                  unit: "",
                  caption: "剩余量"),
            .init(value: snapshot.remainingValueText,
                  unit: " 天",
                  caption: snapshot.remainingCaptionText),
            .init(value: snapshot.gapValueText,
                  unit: "",
                  caption: "进度差",
                  valueColor: accent)
        ]

        setNeedsLayout()
    }

    // MARK: - 布局

    /// 手动布局的中间产物：各子视图的 frame 与卡片总高。
    private struct LayoutResult {
        var ring = CGRect.zero
        var legend = CGRect.zero
        var note = CGRect.zero
        var separator = CGRect.zero
        var metrics = CGRect.zero
        var totalHeight: CGFloat = 0
    }

    private func makeFrames(forWidth width: CGFloat) -> LayoutResult {
        var result = LayoutResult()

        let contentWidth = max(width - Metrics.padding * 2, 0)
        var y = Metrics.padding

        // 双环（水平居中）
        let side = ringView.metrics.side
        result.ring = CGRect(x: (width - side) / 2, y: y, width: side, height: side)
        y = result.ring.maxY

        // 图例
        y += Metrics.ringToLegend
        result.legend = CGRect(x: Metrics.padding, y: y, width: contentWidth, height: legendView.preferredHeight)
        y = result.legend.maxY

        // 状态提示条
        y += Metrics.legendToNote
        result.note = CGRect(x: Metrics.padding, y: y, width: contentWidth, height: noteView.height(for: contentWidth))
        y = result.note.maxY

        // 分隔线
        y += Metrics.noteToSeparator
        result.separator = CGRect(x: Metrics.padding, y: y, width: contentWidth, height: Metrics.separatorHeight)
        y = result.separator.maxY

        // 指标区（卡片最后一块，下方直接接卡片内间距）
        y += Metrics.separatorToMetrics
        result.metrics = CGRect(x: Metrics.padding, y: y, width: contentWidth, height: metricsView.preferredHeight)
        y = result.metrics.maxY

        result.totalHeight = y + Metrics.padding
        return result
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0 else { return }

        let frames = makeFrames(forWidth: bounds.width)

        ringView.frame = frames.ring
        centerView.frame = frames.ring
        legendView.frame = frames.legend
        noteView.frame = frames.note
        lineSeparatorView.frame = frames.separator
        metricsView.frame = frames.metrics
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let width = size.width > 0 ? size.width : UIScreen.main.bounds.width
        return CGSize(width: width, height: makeFrames(forWidth: width).totalHeight)
    }
}
