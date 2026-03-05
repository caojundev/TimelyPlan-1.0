//
//  HabitTaskStatus.swift
//  TimelyPlan
//
//  Created by caojun on 2023/7/15.
//

import Foundation

enum HabitTaskStatus: Equatable {
    case notStarted /// 未开始
    case completed /// 完成
    case inProgress /// 进行中
    case skipped(_ reason: String?) /// 跳过
    case failed(_ reason: String?)  /// 失败
    
    static func ==(lhs: HabitTaskStatus, rhs: HabitTaskStatus) -> Bool {
       switch (lhs, rhs) {
       case (.notStarted, .notStarted),
           (.completed, .completed),
           (.inProgress, .inProgress),
           (.skipped(_), .skipped(_)),
           (.failed(_), .failed(_)):
           return true
       default:
           return false
       }
    }
}
