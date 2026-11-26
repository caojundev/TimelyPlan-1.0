//
//  FocusTimerIntervalCalculator.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/26.
//

import Foundation

/// 专注计时器触发间隔计算器
///
/// 计时器的触发间隔需要与当前步骤的目标时长匹配：
/// - 步骤时长较长时，单位时间内环形进度变化很小，过高的刷新频率只会消耗性能，没有视觉收益；
/// - 步骤时长较短时，单次刷新推进的进度较多，间隔过大会出现肉眼可见的“跳格”，体验不连续。
///
/// 计算流程：
/// 1. 由「单次刷新允许推进的最大进度比例」推导理论间隔：`理论间隔 = 步骤时长 × 允许推进比例`，
///    等价于「满圈刷新次数恒定」，从而让不同时长下的视觉角速度保持一致；
/// 2. 将理论间隔收敛到 `[最小间隔, 最大间隔]`：
///    - 最小间隔避免极短步骤下的过度刷新；
///    - 最大间隔受时间标签的显示精度限制（标签以秒为单位），间隔过大会导致秒数跳变滞后；
/// 3. 在候选间隔阶梯中取第一个不小于收敛值的间隔，使间隔为规整值并且能够整除 1 秒，
///    从而与整秒对齐，避免秒数标签出现跳秒或停顿。
///
/// 以默认参数为例：
/// ```
/// 30 秒以内   → 1/30 ~ 0.05s（进度条需要高频刷新才平滑）
/// 30 秒 ~ 2 分 → 0.1 ~ 0.2s
/// 2 分 ~ 10 分  → 0.25 ~ 1.0s
/// 10 分钟以上   → 1.0s（进度变化已经足够缓慢，降低刷新频率）
/// ```
struct FocusTimerIntervalCalculator {

    // MARK: - 计算参数
    struct Configuration {

        /// 最小间隔（秒），避免极短步骤下过度刷新
        static let defaultMinimumInterval: TimeInterval = 1.0 / 30.0

        /// 最大间隔（秒），受时间标签「秒」精度限制
        static let defaultMaximumInterval: TimeInterval = 1.0

        /// 单次刷新允许推进的最大进度比例（相对整个环形，1 表示满圈）
        /// 1/600 表示满圈至少刷新 600 次，单次推进不超过 0.6°，肉眼可视为连续
        static let defaultMaximumProgressDelta: Double = 1.0 / 600.0

        /// 候选间隔（秒），升序排列且均能整除 1 秒
        static let defaultCandidateIntervals: [TimeInterval] = [
            1.0 / 30.0, /// 约 33ms
            1.0 / 20.0, /// 50ms
            1.0 / 15.0, /// 约 67ms
            1.0 / 10.0, /// 100ms
            1.0 / 5.0,  /// 200ms
            0.25,       /// 250ms
            0.5,        /// 500ms
            1.0         /// 1s
        ]

        static let `default` = Configuration()

        /// 最小间隔（秒）
        var minimumInterval: TimeInterval = Configuration.defaultMinimumInterval

        /// 最大间隔（秒）
        var maximumInterval: TimeInterval = Configuration.defaultMaximumInterval

        /// 单次刷新允许推进的最大进度比例
        var maximumProgressDelta: Double = Configuration.defaultMaximumProgressDelta

        /// 候选间隔（秒），升序排列
        var candidateIntervals: [TimeInterval] = Configuration.defaultCandidateIntervals
    }

    /// 无法确定时长时使用的兜底间隔
    static let fallbackInterval: TimeInterval = 0.5

    /// 浮点数比较容差
    private static let tolerance: TimeInterval = 0.000_001

    /// 计算参数
    private let configuration: Configuration

    init(configuration: Configuration = .default) {
        self.configuration = Self.validated(configuration)
    }

    // MARK: - 计算
    /// 根据步骤目标时长计算合适的触发间隔
    /// - Parameter duration: 步骤目标时长（秒）
    /// - Returns: 触发间隔（秒），始终落在 `[minimumInterval, maximumInterval]` 区间内
    func interval(forDuration duration: TimeInterval) -> TimeInterval {
        guard duration.isFinite, duration > 0 else {
            /// 时长无效（未开始、已结束或数据异常）：无需高频刷新
            return configuration.maximumInterval
        }

        /// 理论间隔：满圈刷新次数恒定
        let idealInterval = duration * configuration.maximumProgressDelta
        guard idealInterval.isFinite else {
            return configuration.maximumInterval
        }

        /// 收敛到有效区间后再取规整的候选值
        let constrainedInterval = min(max(idealInterval, configuration.minimumInterval),
                                      configuration.maximumInterval)
        return candidateInterval(notLessThan: constrainedInterval)
    }

    /// 根据计时器信息计算合适的触发间隔
    /// - Parameter timerInfo: 当前计时器信息
    /// - Returns: 触发间隔（秒）
    func interval(for timerInfo: FocusTimerInfo?) -> TimeInterval {
        guard let timerInfo = timerInfo else {
            return Self.fallbackInterval
        }

        if timerInfo.isPaused || timerInfo.state == .finished {
            /// 暂停或结束时进度不再变化，使用最大间隔即可
            return configuration.maximumInterval
        }

        return interval(forDuration: timerInfo.totalDuration)
    }

    // MARK: - 便捷调用
    /// 根据步骤目标时长计算合适的触发间隔（使用默认参数）
    static func interval(forDuration duration: TimeInterval) -> TimeInterval {
        return FocusTimerIntervalCalculator().interval(forDuration: duration)
    }

    /// 根据计时器信息计算合适的触发间隔（使用默认参数）
    static func interval(for timerInfo: FocusTimerInfo?) -> TimeInterval {
        return FocusTimerIntervalCalculator().interval(for: timerInfo)
    }
}

// MARK: - 内部实现
private extension FocusTimerIntervalCalculator {

    /// 取第一个不小于指定值的候选间隔
    func candidateInterval(notLessThan value: TimeInterval) -> TimeInterval {
        let interval = configuration.candidateIntervals.first {
            $0 >= value - Self.tolerance
        } ?? configuration.maximumInterval

        return min(max(interval, configuration.minimumInterval),
                   configuration.maximumInterval)
    }

    /// 修正非法或自相矛盾的参数，保证计算结果始终可用
    static func validated(_ configuration: Configuration) -> Configuration {
        var configuration = configuration
        let fallback = Configuration.default

        if !(configuration.minimumInterval.isFinite && configuration.minimumInterval > 0) {
            configuration.minimumInterval = fallback.minimumInterval
        }

        if !(configuration.maximumInterval.isFinite && configuration.maximumInterval > 0) {
            configuration.maximumInterval = fallback.maximumInterval
        }

        if configuration.maximumInterval < configuration.minimumInterval {
            swap(&configuration.maximumInterval, &configuration.minimumInterval)
        }

        if !(configuration.maximumProgressDelta.isFinite &&
             configuration.maximumProgressDelta > 0 &&
             configuration.maximumProgressDelta <= 1) {
            configuration.maximumProgressDelta = fallback.maximumProgressDelta
        }

        var candidates = configuration.candidateIntervals.filter {
            $0.isFinite && $0 > 0
        }
        candidates.sort()

        if candidates.isEmpty {
            candidates = fallback.candidateIntervals
        }

        /// 仅保留落在有效区间内的候选值
        candidates = candidates.filter {
            $0 >= configuration.minimumInterval - tolerance &&
            $0 <= configuration.maximumInterval + tolerance
        }

        if candidates.isEmpty {
            candidates = [configuration.minimumInterval, configuration.maximumInterval]
        }

        configuration.candidateIntervals = candidates
        return configuration
    }
}
