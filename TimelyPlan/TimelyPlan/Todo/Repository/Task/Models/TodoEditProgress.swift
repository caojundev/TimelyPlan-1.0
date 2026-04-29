//
//  TodoEditProgress.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/12.
//

import Foundation

/// 记录输入类型
enum TodoRecordInputType: Int, TPMenuRepresentable {
    case increase = 0
    case decrease
    case update
    
    static func titles() -> [String] {
        return ["Increase", "Decrease", "Update"]
    }
}

/// 计算方式
enum TodoProgressCalculation: Int, Codable, TPMenuRepresentable {
    
    /// 添加
    case sum = 0
    
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
enum TodoProgressRecordType: Int, Codable, TPMenuRepresentable {
    
    /// 手动
    case manual = 0
    
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

struct TodoEditProgress: Codable, Hashable, Equatable {
    
    /// 开始数值
    var initialValue: Int64 = 0
    
    /// 目标数值
    var targetValue: Int64 = 100
    
    /// 当前数值
    var currentValue: Int64 = 0
    
    /// 计算方式
    var calculation: TodoProgressCalculation = .sum {
        didSet {
            if calculation != oldValue {
                updateRecordType()
            }
        }
    }
    
    /// 记录类型
    var recordType: TodoProgressRecordType = .manual
    
    /// 自动记录数值
    var autoRecordValue: Int64 = 1
    
    /// 是否有效
    var isValid: Bool {
        if initialValue == targetValue {
            return false
        }
        
        return true
    }
    
    /// 检查类型
    var checkType: TodoTaskCheckType {
        guard isValid else {
            return .normal
        }
        
        if initialValue < targetValue {
            return .increase
        }
        
        return .decrease
    }
    
    /// 进度
    var completionFraction: CGFloat {
        let total = targetValue - initialValue
        if total == 0 {
            return 0.0
        }
        
        let progress = CGFloat(currentValue - initialValue) / CGFloat(total)
        return validatedProgress(progress)
    }

    var isCompleted: Bool {
        return completionFraction >= 1.0
    }
    
    var info: String? {
        return "\(initialValue)→\(targetValue)"
    }
    
    var progressInfo: String? {
        return "\(currentValue)→\(targetValue)"
    }
    
    /// 详情信息，包含当前数值
    var detailInfo: String? {
        return "\(initialValue)→\(targetValue)•\(currentValue)"
    }
    
    var detailDescription: String? {
        guard isValid else {
            return nil
        }
        
        let format = resGetString("From %ld To %ld • %ld")
        return String(format: format, initialValue, targetValue, currentValue)
    }
    
    private mutating func updateRecordType() {
        if calculation == .update {
            recordType = .manual
        }
    }
    
    /// 重置当前值为初始值
    mutating func resetCurrentValue() {
        self.currentValue = self.initialValue
    }
    
    /// 完成进度
    mutating func complete() {
        self.currentValue = self.targetValue
    }

    // MARK: - 根据数值获取新的进度
    /// 根据当前数值获取一个新进度
    func progressWithCurrentValue(_ currentValue: Int64) -> TodoEditProgress {
        let checkType = self.checkType
        var newValue = currentValue
        if checkType == .decrease {
            newValue = clampedValue(newValue, targetValue, initialValue)
        } else {
            newValue = clampedValue(newValue, initialValue, targetValue)
        }
        
        var progress = self
        progress.currentValue = newValue
        return progress
    }
    
    func progressByIncrementValue(_ incrementValue: Int64) -> TodoEditProgress {
        let value = self.currentValue + incrementValue
        return progressWithCurrentValue(value)
    }
    
    /// 自动记录后的进度
    func autoRecordedProgress() -> TodoEditProgress? {
        guard isValid, recordType == .auto else {
            return nil
        }
        
        var recordValue = autoRecordValue
        if recordValue == 0 {
            recordValue = 1
        }
        
        if checkType == .decrease {
            recordValue = -recordValue
        }
        
        return progressByIncrementValue(recordValue)
    }
    
    func progressWithInputValue(_ inputValue: Int64, inputType: TodoRecordInputType) -> TodoEditProgress {
        if inputType == .update {
            return progressWithCurrentValue(inputValue)
        } else {
            var incrementValue = inputValue
            if inputType == .decrease {
                incrementValue = -inputValue
            }
            
            return progressByIncrementValue(incrementValue)
        }
    }
}
 
extension TodoEditProgress {
    
    /// 根据过滤条件调整当前值
    mutating func adjustCurrentValue(toMatch specificValue: TodoProgressFilterSpecificValue?) {
        guard let specificValue = specificValue, !isMatchFilterSpecificValue(specificValue) else {
            return
        }
        
        let comparisonOperator = specificValue.getComparisonOperator()
        let percentage = Float(specificValue.getPercentage()) / 100.0
        let targetProgress = Float(targetValue - initialValue) * percentage + Float(initialValue)

        switch comparisonOperator {
        case .greaterThan:
           currentValue = max(currentValue, Int64(targetProgress) + 1)
        case .greaterOrEqual:
           currentValue = max(currentValue, Int64(targetProgress))
        case .lessThan:
           currentValue = min(currentValue, Int64(targetProgress) - 1)
        case .lessOrEqual:
           currentValue = min(currentValue, Int64(targetProgress))
        case .equal:
           currentValue = Int64(targetProgress)
        }
    }
    
    /// 检查当前进度是否满足过滤条件
    func isMatchFilterSpecificValue(_ specificValue: TodoProgressFilterSpecificValue) -> Bool {
        let completionFraction = Float(completionFraction)
        let comparisonOperator = specificValue.getComparisonOperator()
        let floatPercentage = Float(specificValue.getPercentage()) / 100.0
        switch comparisonOperator {
        case .greaterThan:
            return completionFraction > floatPercentage
        case .greaterOrEqual:
            return completionFraction >= floatPercentage
        case .lessThan:
            return completionFraction < floatPercentage
        case .lessOrEqual:
            return completionFraction <= floatPercentage
        case .equal:
            return completionFraction == floatPercentage
        }
    }
}
