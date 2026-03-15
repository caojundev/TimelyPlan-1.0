//
//  HabitTaskStatus.swift
//  TimelyPlan
//
//  Created by caojun on 2023/7/15.
//

import Foundation

/// 代表习惯发生的时间段
enum HabitTimeOption: Int, TPMenuRepresentable {
    case anytime = 0
    case morning
    case afternoon
    case evening

    static func titles() -> [String] {
        return ["Anytime", "Morning", "Afternoon", "Evening"]
    }
    
    var identifier: String {
        let titles = Self.titles()
        return titles[rawValue]
    }
    
    var iconName: String? {
        switch self {
        case .anytime: return "habit_time_anytime_24"
        case .morning: return "habit_time_morning_24"
        case .afternoon: return "habit_time_afternoon_24"
        case .evening: return "habit_time_evening_24"
        }
    }
}

/// 习惯任务状态
enum HabitTaskStatus: Hashable, Equatable {
    case notStarted /// 未开始
    case completed /// 完成
    case inProgress /// 进行中
    case skipped(_ reason: String?) /// 跳过
    case failed(_ reason: String?)  /// 失败
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .notStarted:
            hasher.combine(0)
        case .completed:
            hasher.combine(1)
        case .inProgress:
            hasher.combine(2)
        case .skipped(let reason):
            hasher.combine(3)
            hasher.combine(reason)
        case .failed(let reason):
            hasher.combine(4)
            hasher.combine(reason)
        }
    }
    
    static func ==(lhs: HabitTaskStatus, rhs: HabitTaskStatus) -> Bool {
       switch (lhs, rhs) {
       case (.notStarted, .notStarted),
           (.completed, .completed),
           (.inProgress, .inProgress):
           return true
       case (.skipped(let lhsReason), .skipped(let rhsReason)):
           return lhsReason == rhsReason
       case (.failed(let lhsReason), .failed(let rhsReason)):
           return lhsReason == rhsReason
       default:
           return false
       }
    }
    
    var title: String {
        switch self {
        case .notStarted:
            return resGetString("Not Started")
        case .completed:
            return resGetString("Completed")
        case .inProgress:
            return resGetString("In Progress")
        case .skipped(let reason):
            return reason ?? resGetString("Skipped")
        case .failed(let reason):
            return reason ?? resGetString("Failed")
        }
    }
    
    var isSkipped: Bool {
        if case .skipped(_) = self {
            return true
        }
        
        return false
    }
    
    var isFailed: Bool {
        if case .failed(_) = self {
            return true
        }
        
        return false
    }
}

// MARK: - 任务阶段
enum HabitPhase: String {
    case notStarted /// 未开始
    case inProgress /// 进行中
    case finished   /// 已结束
    case paused     /// 暂停中
    var title: String {
        switch self {
        case .notStarted:
            return resGetString("Not Started")
        case .inProgress:
            return resGetString("In Progress")
        case .finished:
            return resGetString("Finished")
        case .paused:
            return resGetString("Paused")
        }
    }
}
