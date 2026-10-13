import Foundation

/// 演示数据：用相对当天的偏移构造，保证三种状态都能稳定复现。
enum ProgressDemoData {

    private static let day: TimeInterval = 86_400

    /// 生成三条示例任务。
    /// - Parameter now: 参照时间，默认当前。
    static func samples(now: Date = Date()) -> [TaskProgress] {

        func date(offsetDays: Double) -> Date {
            now.addingTimeInterval(offsetDays * day)
        }

        return [
            // 时间进度 48%，完成度 37.5% → 落后
            TaskProgress(initialValue: 2,
                         startDate: date(offsetDays: -84),
                         endDate: date(offsetDays: 91),
                         completedCount: 6,
                         totalCount: 16),

            // 时间进度 55%，完成度 58.3% → 正常
            TaskProgress(initialValue: 3,
                         startDate: date(offsetDays: -110),
                         endDate: date(offsetDays: 90),
                         completedCount: 7,
                         totalCount: 12),

            // 时间进度 33%，完成度 64.3% → 领先
            TaskProgress(initialValue: 4,
                         startDate: date(offsetDays: -100),
                         endDate: date(offsetDays: 200),
                         completedCount: 9,
                         totalCount: 14)
        ]
    }
}
