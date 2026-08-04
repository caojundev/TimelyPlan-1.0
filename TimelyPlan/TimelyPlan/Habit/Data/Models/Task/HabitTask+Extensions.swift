//
//  HabitTask+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/22.
//

import Foundation

// MARK: - 状态和进度
extension HabitTask {
    
    /// 获取特定记录对应的任务状态
    func status(with record: HabitRecord?) -> HabitTaskStatus {
        guard let record = record else {
            return .notStarted
        }

        var status: HabitTaskStatus = .notStarted
        let amount = record.amount
        if amount >= self.goal.validatedTargetAmount {
            status = .completed /// 已完成
        } else {
            if amount > 0 {
                status = .inProgress /// 进行中
            }
            
            if record.status == .failed {
                status = .failed(record.reason) /// 失败
            } else if record.status == .skipped {
                status = .skipped(record.reason)  /// 跳过
            }
        }
        
        return status
    }
    
    /// 获取特定记录对应的任务进度
    func progress(with record: HabitRecord?) -> CGFloat {
        guard let record = record else {
            return 0.0
        }

        let amount = record.amount
        let progress = CGFloat(amount) / CGFloat(goal.validatedTargetAmount)
        return validatedProgress(progress)
    }
    
}

// MARK: -  任务富文本信息
extension HabitTask {

    func attributedInfo(color: UIColor? = nil) -> ASAttributedString {
        var indicators = [ASAttributedString]()
        
        /// 我的一天
        if isAddedToMyDay, let myDayIndicator = myDayIndicator(color: color) {
            indicators.append(myDayIndicator)
        }
        
        /// 提醒
        if hasAlarm, let bellIndicator = bellIndicator(color: color) {
            indicators.append(bellIndicator)
        }

        /// 时间计划
        if let timePlanIndicator = timePlanIndicator {
            indicators.append(timePlanIndicator)
        }
        
        return indicators.joined(separator: " • ")
    }
    
    /// 我的一天图标信息
    func myDayIndicator(color: UIColor? = nil) -> ASAttributedString? {
        guard let image = resGetImage("myDay_fill_16") else {
            return nil
        }
        
        return .string(image: image, imageSize: .size(4), imageColor: color)
    }
    
    /// 备注图标信息
    func bellIndicator(color: UIColor? = nil) -> ASAttributedString? {
        guard let image = resGetImage("bell_fill_16") else {
            return nil
        }
        
        return .string(image: image, imageSize: .size(4), imageColor: color)
    }
    
    /// 时间计划富文本信息
    var timePlanIndicator: ASAttributedString? {
        let title = timePlan.title ?? ""
        guard let subtitle = timePlan.subtitle else {
            return "\(title)"
        }
        
        return "\(title)(\(subtitle))"
    }
    
    /// 备注图标信息
    func logIndicator(color: UIColor? = nil) -> ASAttributedString {
        return .logIndicator(color: color)
    }
    
    /// 跳过指示信息
    func skipIndicator(reason: String? = nil, color: UIColor? = nil) -> ASAttributedString {
        return .skipIndicator(reason: reason, color: color)
    }
    
    /// 失败指示信息
    func failIndicator(reason: String? = nil, color: UIColor? = nil) -> ASAttributedString {
        return .failIndicator(reason: reason, color: color)
    }
}

// MARK: - 编辑任务 EdtingTask
extension HabitTask {
    
    /// 获取编辑任务
    var editingTask: HabitEditingTask {
        var task = HabitEditingTask()
        task.emoji = emoji
        task.name = name
        task.color = color
        task.goal = goal
        task.dateRange = dateRange
        task.timeOption = timeOption
        task.startTime = startTime
        task.duration = duration
        task.isAddedToMyDay = isAddedToMyDay
        task.timePlan = (timePlan.copy() as? HabitTimePlan) ?? HabitTimePlan()
        task.shouldRemind = shouldRemind
        task.reminder = reminder?.copy() as? HabitReminder
        task.note = note
        return task
    }
    
    /// 判断编辑任务内容是否与当前任务相同
    func isSameEditingTask(as other: HabitEditingTask) -> Bool {
        return editingTask == other
    }
}

extension HabitTask: TaskRepresentable {
    
    var feature: TaskFeature {
        return TaskFeature(type: .habit,
                           identifier: self.identifier,
                           snapshotName: self.name)
    }
}

extension Array where Element == HabitTask {
    /// 所有标识
    var identifiers: [String] {
        return self.map { $0.identifier }
    }
}
