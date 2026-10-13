import Foundation

/// 计算产出的、可直接用于渲染的进度快照。
///
/// 视图层只从这个结构体读值、做格式化，不参与任何业务计算 ——
/// 这是「数据」与「展示」之间唯一的契约。
struct ProgressSnapshot {

    // MARK: - 原始输入（回传给视图做日期轴等展示）

    let startDate: Date
    let endDate: Date

    /// 起始值（环的起点）。
    let initialValue: Int

    /// 当前值，即已完成的任务项数量。
    let currentValue: Int

    /// 目标值（环的终点），即任务项总数。
    let targetValue: Int

    // MARK: - 计算结果

    /// 任务完成度，0...1。
    let taskProgress: Double

    /// 日期时间进度，0...1。
    let timeProgress: Double

    /// 进度差 = `taskProgress − timeProgress`，正数表示领先。
    let gap: Double

    /// 距截止日期的天数。负数表示已逾期。
    let remainingDays: Int

    /// 计划持续天数（开始到结束），如 175。
    let totalDays: Int

    /// 由 `gap` 判定出的状态。
    let status: ProgressStatus

    // MARK: - 便捷判定

    var isOverdue: Bool { remainingDays < 0 }

    var isCompleted: Bool { targetValue > 0 && currentValue >= targetValue }
}

// MARK: - 展示格式化

extension ProgressSnapshot {

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
    var remainingCaptionText: String { isOverdue ? "已逾期" : "剩余时间" }

    /// 日期轴左端文案，如「8月1日」。
    var startDateText: String { Self.dateFormatter.string(from: startDate) }

    /// 日期轴右端文案，如「12月31日」。
    var endDateText: String { Self.dateFormatter.string(from: endDate) }

    // MARK: - 私有

    private static func percent(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter
    }()
}
