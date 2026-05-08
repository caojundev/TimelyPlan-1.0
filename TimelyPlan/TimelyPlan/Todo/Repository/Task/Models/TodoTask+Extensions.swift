//
//  TodoTask+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/6.
//

import Foundation

extension TodoTask: SortableIdentifiable, TaskRepresentable {
    
    var feature: TaskFeature {
        return TaskFeature(type: .todo,
                           identifier: self.identifier,
                           snapshotName: self.name)
    }
    
    var identifiableKey: String {
        return self.identifier
    }
    
    /// 是否是重复任务
    var isRecurringTask: Bool {
        guard schedule?.dateInfo != nil, let repeatRule = schedule?.repeatRule else {
            return false
        }

        return repeatRule.type != RepeatType.none
    }
}

// MARK: - 进度
extension TodoTask {
    
    /// 检查类型
    var checkType: TodoTaskCheckType {
        guard let progress = progress else {
            return .normal
        }
        
        return progress.checkType
    }
    
    /// 是否设置进度
    var isProgressSet: Bool {
        if let progress = progress, progress.isValid {
            return true
        }
        
        return false
    }
    
    /// 完成进度（范围 0 ～ 1.0）
    var completionFraction: CGFloat {
        let rate = progress?.completionFraction ?? 0.0
        return validatedProgress(CGFloat(rate))
    }
}

// MARK: - Attributed Info
extension TodoTask {
    
    /// 计划信息
    var attributedScheduleInfo: ASAttributedString? {
        return schedule?.attributedInfo(isCompleted: isCompleted)
    }
    
    /// 我的一天信息
    var attributedMyDayInfo: ASAttributedString? {
        guard isAddedToMyDay else {
            return nil
        }
        
        if let image = resGetImage("todo_task_addToMyDay_24") {
            let trailingText = resGetString("My Day")
            let info: ASAttributedString = .string(image: image,
                                                   imageSize: .size(3),
                                                   imageColor: .primary,
                                                   trailingText: trailingText,
                                                   textColor: .primary,
                                                   separator: "")
            return info
        }
        
        return nil
    }
    
    /// 备注信息
    var attributedNoteInfo: ASAttributedString? {
        guard let note = note, note.count > 0 else {
            return nil
        }
        
        if let image = resGetImage("todo_task_note_24") {
            let info: ASAttributedString = .string(image: image,
                                                   imageSize: .size(3),
                                                   imageColor: .secondaryLabel)
            return info
        }
        
        return nil
    }
    
    /// 步骤信息
    var attributedStepInfo: ASAttributedString? {
        guard self.stepCount > 0 else {
            return nil
        }

        let format = resGetString("%ld of %ld")
        let trailingText = String(format: format, stepCompletedCount, self.stepCount)
        
        guard let checkmarkImage = resGetImage("checkmark_12") else {
            return trailingText.attributedString
        }
        
        let info: ASAttributedString = .string(image: checkmarkImage,
                                               imageSize: .size(3),
                                               imageColor: .secondaryLabel,
                                               trailingText: trailingText,
                                               separator: nil)
        return info
    }
    
    /// 进度信息
    var attributedProgressInfo: ASAttributedString? {
        guard let progress = self.progress, progress.isValid else {
            return nil
        }
        
        return progress.progressInfo?.attributedString
    }
    
    /// 标签信息
    var attributedTagInfo: ASAttributedString? {
        guard let tags = tags, tags.count > 0 else {
            return nil
        }

        let orderedTags = tags.orderedElements()
        return orderedTags.attributedInfo()
    }
    
    /// 完成信息
    var attributedCompletionInfo: ASAttributedString? {
        guard isCompleted, let completionDate = completionDate else {
            return nil
        }
        
        let dateString = completionDate.yearMonthDayTimeString(omitYear: true,
                                                               showRelativeDate: true,
                                                               slashFormatted: true)
        guard let checkmarkImage = resGetImage("checkmark_12") else {
            return dateString.attributedString
        }
        
        let info: ASAttributedString = .string(image: checkmarkImage,
                                               imageSize: .size(3),
                                               imageColor: .secondaryLabel,
                                               trailingText: dateString,
                                               separator: nil)
        return info
    }
}

extension Array where Element == TodoTask {
    
    var userListFeatures: [TodoListFeature]? {
        var lists = [TodoListFeature]()
        for task in self {
            if let list = task.list {
                lists.append(list)
            }
        }
        
        if lists.count > 0 {
            return lists
        }
        
        return nil
    }
    
    var userTags: Set<TodoTag>? {
        var results = Set<TodoTag>()
        for task in self {
            if let tags = task.tags {
                results = results.union(Set(tags))
            }
        }
        
        if results.count > 0 {
            return results
        }
        
        return nil
    }
}
