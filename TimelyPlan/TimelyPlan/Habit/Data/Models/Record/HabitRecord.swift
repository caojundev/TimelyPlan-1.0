//
//  HabitRecord.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/7.
//

import Foundation

/// 习惯记录模型
/// 用于存储和管理单个日期的习惯执行情况
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
