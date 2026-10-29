//
//  WSGoalTaskDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

// MARK: - 数据条目

/// 目标任务组件中的单个任务数据。
///
/// 展示字段与目标任务列表一致：颜色、名称、日期、进度与完成状态。
class WSGoalTaskDataItem: NSObject, WSPluginDataItem {
    
    /// 任务唯一标识
    let taskIdentifier: String
    
    /// 任务名称
    let title: String
    
    /// 任务颜色
    let color: UIColor
    
    /// 任务进度（0.0 ~ 1.0）
    let progress: CGFloat
    
    /// 是否展示进度条。初始值与目标值相同时不展示
    let hasValidProgress: Bool
    
    /// 是否已完成
    let isCompleted: Bool
    
    /// 完成状态样式：普通 / 加 / 减
    let checkType: TodoTaskCheckType
    
    /// 任务日期范围
    let dateRange: DateRange
    
    /// 当前数值
    let currentValue: Int64
    
    /// 目标数值
    let targetValue: Int64
    
    /// 任务权重
    let weight: Int64
    
    init(taskIdentifier: String,
         title: String,
         color: UIColor,
         progress: CGFloat,
         hasValidProgress: Bool,
         isCompleted: Bool,
         checkType: TodoTaskCheckType,
         dateRange: DateRange,
         currentValue: Int64,
         targetValue: Int64,
         weight: Int64) {
        self.taskIdentifier = taskIdentifier
        self.title = title
        self.color = color
        self.progress = progress
        self.hasValidProgress = hasValidProgress
        self.isCompleted = isCompleted
        self.checkType = checkType
        self.dateRange = dateRange
        self.currentValue = currentValue
        self.targetValue = targetValue
        self.weight = weight
        super.init()
    }
    
    /// 由目标任务生成展示数据
    convenience init(goalTask: GoalTask) {
        self.init(taskIdentifier: goalTask.identifier,
                  title: goalTask.displayName,
                  color: goalTask.color ?? GoalTask.defaultColor,
                  progress: CGFloat(goalTask.progressFraction),
                  hasValidProgress: goalTask.isValidProgress,
                  isCompleted: goalTask.isCompleted,
                  checkType: goalTask.checkType,
                  dateRange: goalTask.dateRange,
                  currentValue: goalTask.currentValue,
                  targetValue: goalTask.targetValue,
                  weight: goalTask.weight)
    }
    
    /// 日期区间文案
    var intervalText: String? {
        return GoalDateHelper.intervalDescription(startDate: dateRange.startDate,
                                                  endDate: dateRange.endDate)
    }
    
    /// 详情文案：日期区间 • 进度 • 权重，与目标任务列表的详情一致
    var attributedDetail: ASAttributedString? {
        var components = [String]()
        
        if let intervalText = intervalText {
            components.append(intervalText)
        }
        
        if hasValidProgress {
            let percentText = Float(progress).percentageString(decimalPlaces: 0)
            components.append("\(currentValue)→\(targetValue)")
            components.append(percentText)
        }
        
        if GoalTaskWeightOption.isValidWeight(weight) {
            components.append("#\(weight)")
        }
        
        guard !components.isEmpty else {
            return nil
        }
        
        return components.joined(separator: " • ").attributedString
    }
}

// MARK: - 多条目数据

/// 目标任务多条目数据，列表与网格共用。
class WSGoalTaskRowsDataItem: NSObject, WSPluginDataItem {
    
    /// 待展示的目标任务，按展示顺序排列
    let items: [WSGoalTaskDataItem]
    
    init(items: [WSGoalTaskDataItem]) {
        self.items = items
        super.init()
    }
}
