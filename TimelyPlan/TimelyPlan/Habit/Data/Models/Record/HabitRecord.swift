//
//  HabitRecord.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/7.
//

import Foundation

enum HabitRecordChange {
    
    /// 数目变化
    case amountChanged(oldValue: Int64, newValue: Int64)
    
    /// 失败
    case failChanged(oldValue: Bool, newValue: Bool)
    
    /// 跳过
    case skipChanged(oldValue: Bool, newValue:Bool)
    
    /// 日志编辑
    case logEdited(oldValue: HabitRecordLogInfo?, newValue: HabitRecordLogInfo?)
}

/// 记录输入类型
enum HabitRecordInputType: Int, TPMenuRepresentable {
    case byIncrement /// 按增量
    case byTotal     /// 按总量
    static func titles() -> [String] {
        return ["By Increment", "By Total"]
    }
}

struct HabitRecordLogInfo {
    
    /// 日志文本
    var log: String?
     
    /// 评分
    var score: Int
    
    static func logInfo(with status: HabitTaskStatus) -> HabitRecordLogInfo {
        let score: Int
        switch status {
        case .notStarted, .inProgress:
            score = 0
        case .completed:
            score = HabitSetting.shared.defaultCompletedScore
        case .skipped(_):
            score = HabitSetting.shared.defaultSkippedScore
        case .failed(_):
            score = HabitSetting.shared.defaultFailedScore
        }
        
        return HabitRecordLogInfo(log: nil, score: score)
    }
}

class HabitRecord: NSObject {

    /// 记录状态枚举
    enum Status: Int {
        case normal = 0  /// 正常状态
        case skipped     /// 已跳过
        case failed      /// 已失败
    }
    
    /// 日期（整型数值表示）
    var day: DayIntegerKey
    
    var date: Date? {
        return .dateFromDayIntegerKey(day)
    }
    
    /// 完成数量
    var amount: Int64 = 0
    
    /// 记录状态
    var status: Status = .normal
    
    /// 跳过或失败的原因
    var reason: String?
    
    /// 日志内容
    var log: String?
    
    /// 评分
    var score: Int16 = 0
    
    /// 日志评分封装信息
    var logInfo: HabitRecordLogInfo {
        return HabitRecordLogInfo(log: log, score: Int(score))
    }
    
    /// 是否包含日志
    var hasLog: Bool {
        if let log = log, log.count > 0 {
            return true
        }
        return false
    }

    /// 获取样本的时间偏移集合
    var sampleTimeOffsets: Set<Duration>? {
        return content.sampleTimeOffsets
    }
    
    var hourlyCheckinResults: HabitHourlyCheckinResults? {
        return content.hourlyCheckinResults
    }
    
    /// 核心数据对象
    let content: CDHabitRecord
    
    // MARK: - Initialization
    
    /// 初始化习惯记录
    /// - Parameter content: 核心数据记录对象
    init(content: CDHabitRecord) {
        self.content = content
        self.day = content.day
        super.init()
        self.updateProperties()
    }
    
    // MARK: - Private Methods
    
    /// 更新属性
    /// 从核心数据对象同步最新的状态信息
    private func updateProperties() {
        self.amount = content.amount
        self.status = Status(rawValue: Int(content.status)) ?? .normal
        self.reason = content.reason
        self.log = content.log
        self.score = content.score
    }
}
