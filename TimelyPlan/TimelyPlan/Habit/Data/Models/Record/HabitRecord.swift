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
    case logEdited(oldValue: String?, newValue: String?)
    
    /// 时间段内所有记录被重置
    case reseted(period: HabitDatePeriod)
}

/// 记录输入类型
enum HabitRecordInputType: Int, TPMenuRepresentable {
    case byIncrement /// 按增量
    case byTotal     /// 按总量
    static func titles() -> [String] {
        return ["By Increment", "By Total"]
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
    var day: Int32
    
    /// 完成数量
    var amount: Int64 = 0
    
    /// 记录状态
    var status: Status = .normal
    
    /// 跳过或失败的原因
    var reason: String?
    
    /// 日志内容
    var log: String?
    
    /// 是否包含日志
    var hasLog: Bool {
        if let log = log, log.count > 0 {
            return true
        }
        return false
    }
    
    /// 当任务频率为随机时，表示在 date 所在周期内已完成天数
    /// - Optional: 已完成的天数
    var randomlyCompletedDays: Int?
    
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
        self.log = content.log
        self.reason = content.reason
    }
}
