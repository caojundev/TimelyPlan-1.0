import Foundation

/// 计算产出的、可直接用于渲染的进度快照。
///
/// 视图层只从这个结构体读值、做格式化，不参与任何业务计算 ——
/// 这是「数据」与「展示」之间唯一的契约。
struct GoalSummarySnapshot {

    // MARK: - 原始输入（回传给视图做日期轴等展示）

    let startDate: Date
    let endDate: Date

    /// 起始值（环的起点）。
    let initialValue: Int

    /// 当前值。递减型目标时向目标值靠近（数值变小）。
    let currentValue: Int

    /// 目标值（环的终点）。递减型目标时小于 `initialValue`。
    let targetValue: Int

    // MARK: - 计算结果

    /// 任务完成度，0...1。
    let taskProgress: Double

    /// 日期时间进度，0...1。
    let timeProgress: Double

    /// 进度差 = `taskProgress − timeProgress`，正数表示领先。
    let gap: Double

    /// 剩余量 = 离目标值还差多少。递减型目标为「当前值 − 目标值」，恒为非负。
    let remainingValue: Int

    /// 距截止日期的天数。负数表示已逾期。
    let remainingDays: Int

    /// 计划持续天数（开始到结束），如 175。
    let totalDays: Int

    /// 由 `gap` 判定出的状态。
    let status: GoalSummaryStatus

    // MARK: - 便捷判定

    var isOverdue: Bool { remainingDays < 0 }

    var isCompleted: Bool { initialValue != targetValue && currentValue == targetValue }
}

// MARK: - 展示格式化

extension GoalSummarySnapshot {

    /// 任务完成度文案，如「38%」。
    var taskPercentText: String { Self.percent(taskProgress) }

    /// 时间进度文案，如「48%」。
    var timePercentText: String { Self.percent(timeProgress) }

    /// 指标区的带符号数值，如「+12%」。
    var gapValueText: String {
        let value = Int((gap * 100).rounded())
        return (value > 0 ? "+" : "") + "\(value)%"
    }

    /// 指标区数值，如「91」。
    var remainingValueText: String { "\(abs(remainingDays))" }

    /// 指标区标题，如「剩余时间」/「已逾期」。
    var remainingCaptionText: String {
        isOverdue ? resGetString("Overdue") : resGetString("Remaining Time")
    }

    /// 天数单位文案，如「天」/「days」。
    /// - Note: 英文按单复数切换（0 与 1 用 `day`，大于 1 用 `days`），中文两种写法都是「天」。
    var dayUnitText: String { Self.dayUnitText(for: abs(remainingDays)) }

    /// 计划总天数文案（图例用），如「175天」/「175 days」。
    var totalDaysText: String { Self.dayCountText(totalDays) }

    /// 指标区「时间」一列的（数值、单位、说明）。
    /// - Note: 任务已完成时改为表达完成状态 —— 对已完成的任务来说，
    ///         是否超过截止日期已经没有意义，继续显示「已逾期 N 天」并不合适。
    var timeMetric: (value: String, unit: String, caption: String) {
        if isCompleted {
            return (resGetString("Completed"), "", resGetString("Status"))
        }

        return (remainingValueText, dayUnitText, remainingCaptionText)
    }

    /// 日期轴左端文案，如「8月1日」。
    /// - Note: 与全局「月 + 天」格式共用本地化格式串（`resGetString("MMM d")`）。
    var startDateText: String { startDate.monthDayString }

    /// 日期轴右端文案，如「12月31日」。
    var endDateText: String { endDate.monthDayString }

    // MARK: - 私有

    /// 天数单位（0 与 1 用单数 `day`，大于 1 用复数 `days`，复用全局文案）
    private static func dayUnitText(for count: Int) -> String {
        resGetString(count > 1 ? "days" : "day")
    }

    /// 天数数值 + 单位（单复数规则同上）
    private static func dayCountText(_ count: Int) -> String {
        String(format: resGetString(count > 1 ? "%ld days" : "%ld day"), count)
    }

    private static func percent(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }
}
