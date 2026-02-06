//
//  TodoEditProgress.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/12.
//

import Foundation

struct TodoEditProgress: Hashable, Equatable {
    
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
    
    /// 进度
    var completionRate: CGFloat {
        let total = targetValue - initialValue
        if total == 0 {
            return 0.0
        }
        
        let progress = CGFloat(currentValue - initialValue) / CGFloat(total)
        return validatedProgress(progress)
    }
    
    /// 是否有效
    var isValid: Bool {
        if initialValue == targetValue {
            return false
        }
        
        return true
    }
    
    var isCompleted: Bool {
        return completionRate == 1.0
    }
    
    var info: String? {
        guard isValid else {
            return nil
        }
        
        return "\(initialValue)→\(targetValue)"
    }
    
    /// 详情信息，包含当前数值
    var detailInfo: String? {
        guard isValid else {
            return nil
        }
        
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
        let completionRate = Float(completionRate)
        let comparisonOperator = specificValue.getComparisonOperator()
        let floatPercentage = Float(specificValue.getPercentage()) / 100.0
        switch comparisonOperator {
        case .greaterThan:
            return completionRate > floatPercentage
        case .greaterOrEqual:
            return completionRate >= floatPercentage
        case .lessThan:
            return completionRate < floatPercentage
        case .lessOrEqual:
            return completionRate <= floatPercentage
        case .equal:
            return completionRate == floatPercentage
        }
    }
}
