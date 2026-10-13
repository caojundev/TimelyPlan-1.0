import UIKit

/// 视觉主题：把颜色集中在一处，视图只消费语义化色值。
///
/// 颜色全部使用动态色（`Color(light:dark:)`），因此深浅色模式切换是自动的，
/// 视图层无需关心当前外观。
struct GoalSummaryTheme {

    // MARK: - 基础色
    let cardBackground: UIColor
    let primaryText: UIColor
    let secondaryText: UIColor
    let track: UIColor
    let separator: UIColor

    /// 时间环基准色（恒定，不随状态变化）。
    /// - Note: 状态色覆盖绿（领先）/ 蓝（正常）/ 橙（落后）/ 红（严重、逾期），
    ///         因此时间环取紫色系，保证任何一种状态下两环都不同色系、可一眼区分。
    let timeAccent: UIColor

    /// 危险色，用于「已逾期未完成」，取自项目语义色 danger。
    let danger: UIColor

    // MARK: - 预设

    static let standard = GoalSummaryTheme(
        cardBackground: .secondarySystemGroupedBackground,
        primaryText: Color(light: 0x121212, dark: 0xfafafa),
        secondaryText: Color(light: 0x3C3C43, dark: 0xEBEBF5, alpha: 0.6),
        track: Color(light: 0x787880, 0.14, dark: 0x787880, 0.24),
        separator: Color(light: 0x3C3C43, 0.12, dark: 0xEBEBF5, 0.14),
        timeAccent: Color(0x5856D6),
        danger: UIColor.danger6
    )

    // MARK: - 状态色

    /// 状态主色，用于外环、圆心、状态胶囊。
    func accent(for status: GoalSummaryStatus) -> UIColor {
        switch status {
        case .ahead:    return UIColor(hex: 0x34C759)
        case .normal:   return UIColor(hex: 0x007AFF)
        case .behind:   return UIColor(hex: 0xFF9500)
        case .critical: return UIColor(hex: 0xFF3B30)
        case .overdue:  return danger
        }
    }

    /// 状态色的浅底（12% 透明），用于状态胶囊与提示条背景。
    func accentFill(for status: GoalSummaryStatus) -> UIColor {
        accent(for: status).withAlphaComponent(0.12)
    }
}

