//
//  GoalSummaryStatus.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/13.
//

import Foundation
import UIKit

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
        case .ahead:              return resGetString("Ahead")
        case .normal:             return resGetString("Normal")
        case .behind, .critical:  return resGetString("Behind")
        case .overdue:            return resGetString("Past Due")
        }
    }

    /// 对应 SF Symbol 名称，保证不依赖颜色也能识别状态。
    var symbolName: String {
        switch self {
        case .normal:   return "equal.circle"
        case .ahead:    return "arrow.up.right"
        case .behind:   return "arrow.down.forward"
        case .critical: return "exclamationmark.triangle"
        case .overdue:  return "exclamationmark.circle"
        }
    }

    /// 卡片底部的解释性提示。
    var hint: String {
        switch self {
        case .ahead:    return resGetString("Task progress is ahead of time progress, good pace")
        case .normal:   return resGetString("Task progress is in sync with time progress")
        case .behind:   return resGetString("Task progress is behind time progress, consider speeding up")
        case .critical: return resGetString("Significantly behind time progress, needs attention")
        case .overdue:  return resGetString("Past the end date but not finished, handle it as soon as possible")
        }
    }

    // MARK: - 展示色

    /// 状态标签的背景色（实色底，配白色文字）。
    /// - Note: 颜色统一由 `GoalSummaryTheme` 提供，保证列表标签与进度概览卡片的状态色一致。
    var backgroundColor: UIColor {
        return GoalSummaryTheme.standard.accent(for: self)
    }
}
