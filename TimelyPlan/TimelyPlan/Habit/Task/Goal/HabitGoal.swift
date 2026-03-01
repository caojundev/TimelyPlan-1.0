//
//  HabitGoal.swift
//  TimelyPlan
//
//  Created by caojun on 2023/4/15.
//

import Foundation

struct HabitGoal {
    
    /// 目标模式
    enum TargetMode: Int, Hashable, Codable, Equatable, TPMenuRepresentable {
        case checkin /// 打卡模式
        case amount  /// 定量模式
        
        static func titles() -> [String] {
            return ["Check-in",
                    "Reach amount"]
        }
    }
    
    /// 记录方式
    enum RecordType: Int, Hashable, Codable, Equatable, TPMenuRepresentable {
        case completeAll   /// 完成所有
        case manually      /// 手动输入
        case automatically /// 自动输入
        
        static func titles() -> [String] {
            return ["Complete All",
                    "Manually",
                    "Automatically"]
        }
    }
    
    /// 模式（打卡、定量）
    var mode: TargetMode? = .checkin
    
    /// 完成数量
    var targetAmount: Int? = 1
    
    /// 单位
    var unit: String?
    
    /// 记录方式
    var recordType: RecordType? = .completeAll
    
    /// 记录方式为automatically时的自动输入值
    var recordAmount: Int?
    
    var validatedTargetAmount: Int {
        if let amount = targetAmount, amount > 0 {
            return amount
        }
        
        /// 返回默认值
        return kHabitGoalDefaultTargetAmount
    }
    
    var validatedUnit: String {
        if let unit = unit, unit.count > 0 {
            return unit
        }
        
        return Self.defaultUnit
    }
    
    var validatedRecordAmount: Int {
        if let amount = recordAmount, amount > 0 {
            return amount
        }
        
        return kHabitRecordDefaultAmount
    }
    
    /// 默认单位
    static var defaultUnit: String {
        return resGetString("count")
    }
}
