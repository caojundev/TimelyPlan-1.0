//
//  TaskNotificationError.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/10.
//

import Foundation

// MARK: - 错误定义
enum NotificationError: LocalizedError {
    case exceededLimit
    case permissionDenied
    case invalidTask
    case noValidDates
    case schedulingFailed(String)
    case taskNotFound
    
    var errorDescription: String? {
        switch self {
        case .exceededLimit:
            return "超过系统通知数量限制"
        case .permissionDenied:
            return "通知权限被拒绝"
        case .invalidTask:
            return "任务配置无效"
        case .noValidDates:
            return "无法生成有效的触发日期"
        case .schedulingFailed(let reason):
            return "调度失败: \(reason)"
        case .taskNotFound:
            return "未找到指定任务"
        }
    }
}
