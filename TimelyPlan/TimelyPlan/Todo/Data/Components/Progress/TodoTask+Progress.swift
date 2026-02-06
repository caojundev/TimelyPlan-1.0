//
//  TodoTask+Progress.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/12.
//

import Foundation

// MARK: - 进度
extension TodoTask {
    
    /// 检查类型
    var checkType: TodoTaskCheckType {
        guard let progress = progress, progress.isValid else {
            return .normal
        }
        
        if progress.initialValue < progress.targetValue {
            return .increase
        }
        
        return .decrease
    }
    
    /// 是否设置进度
    var isProgressSet: Bool {
        if let progress = progress, progress.isValid {
            return true
        }
        
        return false
    }
    
    /// 完成进度（范围 0 ～ 1.0）
    var completionRate: CGFloat {
        let rate = progress?.completionRate ?? 0.0
        return validatedProgress(CGFloat(rate))
    }
    
    var editProgress: TodoEditProgress? {
        return progress?.editProgress
    }
    
}
