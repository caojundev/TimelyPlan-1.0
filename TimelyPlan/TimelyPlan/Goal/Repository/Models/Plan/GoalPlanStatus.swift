//
//  GoalPlanStatus.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/13.
//

import Foundation
import UIKit

/// 由「计划进度」与「起止日期」判定出的状态。
///
/// 判定阈值集中在这里，视图层只需要读取 `title` / `symbolName` 即可渲染，
/// 不需要知道任何数值边界。
enum GoalPlanStatus {

    /// 未开始（开始日期未到）。
    case notStarted

    /// 进行中（已开始且未过结束日期）。
    case inProgress

    /// 已完成（进度已达标）。
    case completed

    /// 已逾期（已过结束日期但未完成）。
    case overdue

    // MARK: - 阈值

    /// 视为已完成的进度。
    private static let completedProgress = 1.0

    /// 依据进度与起止日期判定状态。
    /// - Parameters:
    ///   - progress: 计划进度（0.0 ~ 1.0）。
    ///   - startDate: 开始日期，未设置（`nil`）时视为已开始。
    ///   - endDate: 结束日期，未设置（`nil`）时视为未逾期。
    ///   - now: 判定基准时间。
    /// - Note: 已完成优先级最高 —— 进度达标后无论日期如何都属于已完成；
    ///         其余情况逾期优先于未开始，与 `GoalTaskAchieveStatus` 保持一致。
    init(progress: Double, startDate: Date?, endDate: Date? = nil, now: Date = Date()) {
        if progress >= Self.completedProgress {
            self = .completed
        } else if let endDate = endDate, endDate < now {
            self = .overdue
        } else if let startDate = startDate, startDate > now {
            self = .notStarted
        } else {
            self = .inProgress
        }
    }

    // MARK: - 展示文案

    /// 状态主文案。
    var title: String {
        switch self {
        case .notStarted: return resGetString("Not Started")
        case .inProgress: return resGetString("In Progress")
        case .completed:  return resGetString("Completed")
        case .overdue:    return resGetString("Overdue")
        }
    }

    // MARK: - 展示色

    /// 状态标签的背景色（实色底，配白色文字）。
    var backgroundColor: UIColor {
        switch self {
        case .notStarted: return .grayPrimary
        case .inProgress: return .primary6
        case .completed:  return .success6
        case .overdue:    return .danger6
        }
    }
}
