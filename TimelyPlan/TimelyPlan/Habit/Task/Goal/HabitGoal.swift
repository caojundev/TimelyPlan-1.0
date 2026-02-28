//
//  HabitGoal.swift
//  iTimeFlow
//
//  Created by caojun on 2023/4/15.
//

import Foundation

public class HabitGoal: NSObject, NSCopying, Codable {
    
    // MARK: - 目标
    struct Target: Hashable, Codable, Equatable {
        
        /// 模式
        enum Mode: Int, Hashable, Codable, Equatable, TPMenuRepresentable {
            case checkin /// 打卡模式
            case amount  /// 定量模式
            
            static func titles() -> [String] {
                return ["Check-in",
                        "Reach amount"]
            }
        }
        
        /// 模式（打卡、定量）
        var mode: Mode? = .checkin
        
        /// 完成数量
        var amount: Int? = 1
        
        /// 单位
        var unit: String?
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
    
    struct Record: Hashable, Codable,  Equatable {
        
        /// 记录方式
        var type: RecordType? = .completeAll
        
        /// 记录方式为automatically时的自动输入值
        var amount: Int?
    }
    
    /// 目标
    var target: Target = Target()
    
    /// 记录
    var record: Record = Record()
    
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.target = (try? container.decodeIfPresent(Target.self, forKey: .target)) ?? Target()
        self.record = (try? container.decodeIfPresent(Record.self, forKey: .record)) ?? Record()
    }
    
    // MARK: - 等同性判断
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(target)
        hasher.combine(record)
        return hasher.finalize()
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? HabitGoal else { return false }
        if self === other { return true }
        return target == other.target && record == other.record
    }
    
    // MARK: - NSCopying
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = HabitGoal()
        copy.target = target
        copy.record = record
        return copy
    }
}

// MARK: - 属性便捷获取方法
extension HabitGoal {
    
    var targetAmount: Int {
        if let amount = target.amount, amount > 0 {
            return amount
        }
        
        /// 返回默认值
        return kHabitGoalDefaultTargetAmount
    }
    
    /// 默认单位
    static var defaultUnit: String {
        return resGetString("count")
    }
    
    var targetUnit: String {
        if let unit = target.unit, unit.count > 0 {
            return unit
        }
        
        return Self.defaultUnit
    }
    
    var autoRecordAmount: Int {
        if let amount = record.amount, amount > 0 {
            return amount
        }
        
        return kHabitRecordDefaultAmount
    }
}
