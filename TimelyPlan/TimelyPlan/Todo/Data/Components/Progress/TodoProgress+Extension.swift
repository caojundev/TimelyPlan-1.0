//
//  TodoProgress+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/10.
//

import Foundation

struct TodoProgressKey {
    static var completionRate = "completionRate"
}

extension TodoProgress {
    
    // MARK: - 计算属性
    /// 计算方式
    var calculation: TodoProgressCalculation {
        let rawValue = Int(calculationRawValue)
        return TodoProgressCalculation(rawValue: rawValue) ?? .sum
    }
    
    /// 记录类型
    var recordType: TodoProgressRecordType {
        let rawValue = Int(recordTypeRawValue)
        return TodoProgressRecordType(rawValue: rawValue) ?? .manual
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
    
    // MARK: - 描述
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
    
    var attributedProgressInfo: ASAttributedString? {
        guard let progressInfo = progressInfo else {
            return nil
        }
        
        return progressInfo.attributedString
    }
    
    // MARK: - 编辑进度
    var editProgress: TodoEditProgress {
        var progress = TodoEditProgress()
        progress.initialValue = initialValue
        progress.targetValue = targetValue
        progress.currentValue = currentValue
        progress.calculation = calculation
        progress.recordType = recordType
        progress.autoRecordValue = autoRecordValue
        return progress
    }
    
    func update(with editProgress: TodoEditProgress) {
        initialValue = editProgress.initialValue
        targetValue = editProgress.targetValue
        currentValue = editProgress.currentValue
        calculationRawValue = Int32(editProgress.calculation.rawValue)
        recordTypeRawValue = Int32(editProgress.recordType.rawValue)
        autoRecordValue = editProgress.autoRecordValue
        completionRate = Float(editProgress.completionRate)
    }
    
    // MARK: - 新建
    static func newProgress(with editProgress: TodoEditProgress) -> TodoProgress {
        let newProgress = TodoProgress.createEntity(in: .defaultContext)
        newProgress.update(with: editProgress)
        return newProgress
    }
    
    static func newProgress(with progress: TodoProgress) -> TodoProgress {
        var editProgress = progress.editProgress
        editProgress.resetCurrentValue()
        return newProgress(with: editProgress)
    }
}
