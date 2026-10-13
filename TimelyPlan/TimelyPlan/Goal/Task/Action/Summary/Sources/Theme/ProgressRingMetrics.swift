import CoreGraphics

/// 双环的几何规格。
///
/// 与 `ProgressTheme` 分开，是因为这里是「尺寸」、那边是「颜色」，
/// 两个维度的变化原因不同，拆开后互不影响。
struct ProgressRingMetrics {

    /// 整体边长（正方形）。
    let side: CGFloat

    /// 外环半径（到线宽中心）。
    let outerRadius: CGFloat

    /// 外环线宽。
    let outerLineWidth: CGFloat

    /// 内环半径（到线宽中心）。
    let innerRadius: CGFloat

    /// 内环线宽。
    let innerLineWidth: CGFloat

    // MARK: - 预设

    /// 大尺寸，用于详情页或卡片主视觉。
    /// - Note: 内环线宽与外环保持一致；两环之间留 4pt 间隙。
    static let regular = ProgressRingMetrics(
        side: 184,
        outerRadius: 72,
        outerLineWidth: 14,
        innerRadius: 54,
        innerLineWidth: 14
    )
    
    /// 紧凑尺寸，用于列表行。
    /// - Note: 内环线宽与外环保持一致；两环之间留 4pt 间隙。
    static let compact = ProgressRingMetrics(
        side: 148,
        outerRadius: 62,
        outerLineWidth: 10,
        innerRadius: 48,
        innerLineWidth: 10
    )
}
