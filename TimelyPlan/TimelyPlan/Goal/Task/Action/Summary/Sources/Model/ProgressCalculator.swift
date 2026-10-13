import Foundation

/// 纯函数式计算器：`TaskProgress` + 当前时间 → `ProgressSnapshot`。
///
/// 无状态、无依赖，方便单元测试，也让视图层完全不需要知道计算规则。
enum ProgressCalculator {

    private static let secondsPerDay: TimeInterval = 86_400

    /// 计算进度快照。
    /// - Parameters:
    ///   - task: 任务原始数据。
    ///   - now: 参照时间，默认当前。显式传入便于测试与预览。
    static func snapshot(for task: TaskProgress, now: Date = Date()) -> ProgressSnapshot {

        // 任务完成度：钳制在有效区间，避免脏数据导致负值或超过 100%。
        let total = max(task.totalCount, 0)
        let initial = min(max(task.initialValue, 0), total)
        let completed = min(max(task.completedCount, 0), total)
        let taskProgress = total == 0 ? 0 : Double(completed) / Double(total)

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

        return ProgressSnapshot(
            startDate: task.startDate,
            endDate: task.endDate,
            initialValue: initial,
            currentValue: completed,
            targetValue: total,
            taskProgress: taskProgress,
            timeProgress: timeProgress,
            gap: gap,
            remainingDays: remainingDays,
            totalDays: totalDays,
            status: ProgressStatus(gap: gap,
                                   isOverdue: remainingDays < 0,
                                   isCompleted: total > 0 && completed >= total)
        )
    }
}
