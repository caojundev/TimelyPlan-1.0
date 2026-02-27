//
//  HabitPhase.swift
//  TimelyPlan
//
//  Created by caojun on 2024/3/28.
//

import Foundation

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
