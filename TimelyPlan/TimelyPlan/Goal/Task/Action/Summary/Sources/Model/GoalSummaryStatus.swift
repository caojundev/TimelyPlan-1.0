import Foundation

/// 由「任务完成进度」与「时间进度」的差值判定出的状态。
///
/// 判定阈值集中在这里，视图层只需要读取 `title` / `symbolName` / `hint` 即可渲染，
/// 不需要知道任何数值边界。
enum GoalSummaryStatus {

    /// 任务进度明显快于时间进度。
    case ahead

    /// 两者基本同步。
    case normal

    /// 任务进度落后于时间进度。
    case behind

    /// 严重落后，需要重点关注。
    case critical

    /// 已过截止日期但任务仍未完成。
    case overdue

    // MARK: - 阈值

    private static let aheadThreshold = 0.05
    private static let behindThreshold = -0.05
    private static let criticalThreshold = -0.25

    /// 依据进度差与完成情况判定状态。
    /// - Parameters:
    ///   - gap: 进度差 = 任务完成度 − 时间进度。
    ///   - isOverdue: 是否已过截止日期。
    ///   - isCompleted: 任务是否已完成。
    /// - Note: 已逾期且未完成优先级最高 —— 此时无论进度差多少都属于需要立即处理的逾期状态；
    ///         逾期但已完成不视为逾期。
    init(gap: Double, isOverdue: Bool = false, isCompleted: Bool = false) {
        if isOverdue && !isCompleted {
            self = .overdue
        } else if gap <= Self.criticalThreshold {
            self = .critical
        } else if gap <= Self.behindThreshold {
            self = .behind
        } else if gap >= Self.aheadThreshold {
            self = .ahead
        } else {
            self = .normal
        }
    }

    // MARK: - 展示文案

    /// 圆心的状态主文案。
    var title: String {
        switch self {
        case .ahead:              return "领先"
        case .normal:             return "正常"
        case .behind, .critical:  return "落后"
        case .overdue:            return "逾期"
        }
    }

    /// 对应 SF Symbol 名称，保证不依赖颜色也能识别状态。
    var symbolName: String {
        switch self {
        case .ahead:    return "arrow.up.right"
        case .normal:   return "equal"
        case .behind:   return "clock"
        case .critical: return "exclamationmark.triangle"
        case .overdue:  return "exclamationmark.octagon"
        }
    }

    /// 卡片底部的解释性提示。
    var hint: String {
        switch self {
        case .ahead:    return "任务进度快于时间进度，节奏良好"
        case .normal:   return "任务进度与时间进度基本同步"
        case .behind:   return "任务进度慢于时间进度，建议加快"
        case .critical: return "严重落后于时间进度，需要重点关注"
        case .overdue:  return "已过截止日期但任务尚未完成，需要尽快处理"
        }
    }
}
