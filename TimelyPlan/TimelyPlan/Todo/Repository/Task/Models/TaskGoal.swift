//
//  TaskGoal.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/5.
//

import Foundation

/// 记录输入类型
enum TodoRecordInputType: String {
    case positive
    case negative
    case update
    
    /// 类型图标
    var image: UIImage? {
        let imageName = "todo_task_record_\(self.rawValue)_24"
        return resGetImage(imageName)
    }
}

/// 计算方式
enum TaskGoalCalculation: Int, Codable, TPMenuRepresentable {
    
    /// 添加
    case sum
    
    /// 更新
    case update
    
    var title: String {
        switch self {
        case .sum:
            return resGetString("Sum")
        case .update:
            return resGetString("Update")
        }
    }
}

/// 记录方式
enum TaskGoalRecordType: Int, Codable, TPMenuRepresentable {
    
    /// 手动
    case manual
    
    /// 自动
    case auto
    
    var title: String {
        switch self {
        case .manual:
            return resGetString("Manual")
        case .auto:
            return resGetString("Auto")
        }
    }
}

public class TaskGoal: NSObject, Codable, NSCopying {
   
    /// 默认自动记录数值
    static let defaultAutoRecordValue: Int64 = 1
   
    /// 开始数值
    var initialValue: Int64 = 0
    
    /// 目标数值
    var targetValue: Int64 = 100
    
    /// 当前数值
    var currentValue: Int64 = 0
    
    /// 计算方式
    var calculation: TaskGoalCalculation = .sum {
        didSet {
            if calculation != oldValue {
                validateRecord()
            }
        }
    }
    
    /// 记录类型
    var recordType: TaskGoalRecordType = .manual
    
    /// 自动记录数值
    var autoRecordValue: Int64 = TaskGoal.defaultAutoRecordValue

    /// 是否有效
    var isValid: Bool {
        if initialValue == targetValue {
            return false
        }
        
        return true
    }
    
    var attributedInfo: ASAttributedString? {
        guard let info = info else {
            return nil
        }
        
        return info.attributedString
    }
    
    var attributedProgressInfo: ASAttributedString? {
        guard let progressInfo = progressInfo else {
            return nil
        }
        
        return progressInfo.attributedString
    }
    
    var info: String? {
        guard isValid else {
            return nil
        }
        
        return "\(initialValue)→\(targetValue)"
    }
    
    var progressInfo: String? {
        guard isValid else {
            return nil
        }
        
        return "\(currentValue)→\(targetValue)"
    }
    
    /// 进度
    var progress: CGFloat {
        let total = targetValue - initialValue
        if total == 0 {
            return 0.0
        }
        
        let progress = CGFloat(currentValue - initialValue) / CGFloat(total)
        return validatedProgress(progress)
    }
    
    var isCompleted: Bool {
        return progress == 1.0
    }
    
    func resetCurrentValue() {
        self.currentValue = self.initialValue
    }
    
    private func validateRecord() {
        if self.calculation == .update {
            self.recordType = .manual
        }
    }
    
    // MARK: - 等同性判断
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(initialValue)
        hasher.combine(targetValue)
        hasher.combine(currentValue)
        hasher.combine(calculation)
        hasher.combine(recordType)
        hasher.combine(autoRecordValue)
        return hasher.finalize()
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? TaskGoal else { return false }
        if self === other { return true }
        return initialValue == other.initialValue &&
        targetValue == other.targetValue &&
        currentValue == other.currentValue &&
        calculation == other.calculation &&
        recordType == other.recordType &&
        autoRecordValue == other.autoRecordValue
    }
    
    // MARK: - NSCopying
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = TaskGoal()
        copy.initialValue = initialValue
        copy.targetValue = targetValue
        copy.currentValue = currentValue
        copy.calculation = calculation
        copy.recordType = recordType
        copy.autoRecordValue = autoRecordValue
        return copy
    }
    
}
