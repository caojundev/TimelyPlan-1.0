import Foundation

/// 纯函数式计算器：`GoalSummaryTask` + 当前时间 → `GoalSummarySnapshot`。
///
/// 无状态、无依赖，方便单元测试，也让视图层完全不需要知道计算规则。
enum GoalSummaryCalculator {

    private static let secondsPerDay: TimeInterval = 86_400

    /// 计算进度快照。
    /// - Parameters:
    ///   - task: 任务原始数据。
    ///   - now: 参照时间，默认当前。显式传入便于测试与预览。
    static func snapshot(for task: GoalSummaryTask, now: Date = Date()) -> GoalSummarySnapshot {

        // 取值：起始值可能大于目标值（递减型目标，如「100 → 20」），
        // 因此不能按 0...目标值 钳制，只把当前值收在「起始值 ⇄ 目标值」构成的区间内。
        let initial = task.initialValue
        let target = task.targetValue
        let current: Int
        if initial == target {
            // 区间为零：保持原值，不把当前值改写成目标值。
            current = task.currentValue
        } else {
            current = min(max(task.currentValue, min(initial, target)), max(initial, target))
        }

        // 任务完成度 =（当前值 − 起始值）/（目标值 − 起始值）。
        // 递减型目标的分子与分母同为负，比值依然落在 0...1，无需按方向分支处理。
        let valueSpan = target - initial
        let taskProgress: Double
        if valueSpan == 0 {
            // 起始值与目标值相同：没有可推进的区间，视为未开始。
            taskProgress = 0
        } else {
            taskProgress = min(max(Double(current - initial) / Double(valueSpan), 0), 1)
        }

        // 时间进度：按已流逝时间占整体计划时长的比例，钳制到 0...1。
        let span = task.endDate.timeIntervalSince(task.startDate)
        let elapsed = now.timeIntervalSince(task.startDate)
        let timeProgress: Double
        if span > 0 {
            timeProgress = min(max(elapsed / span, 0), 1)
        } else {
            // 起止日期相同或倒置：视为已到期。
            timeProgress = elapsed >= 0 ? 1 : 0
        }

        let gap = taskProgress - timeProgress
        let remainingDays = Int(ceil(task.endDate.timeIntervalSince(now) / secondsPerDay))
        let totalDays = max(Int((span / secondsPerDay).rounded()), 0)

        return GoalSummarySnapshot(
            startDate: task.startDate,
            endDate: task.endDate,
            initialValue: initial,
            currentValue: current,
            targetValue: target,
            taskProgress: taskProgress,
            timeProgress: timeProgress,
            gap: gap,
            remainingValue: abs(target - current),
            remainingDays: remainingDays,
            totalDays: totalDays,
            status: GoalSummaryStatus(gap: gap,
                                      isOverdue: remainingDays < 0,
                                      isCompleted: valueSpan != 0 && current == target)
        )
    }
}
