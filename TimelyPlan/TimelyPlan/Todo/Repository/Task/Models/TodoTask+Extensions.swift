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
        return schedule?.attributedInfo()
    }
    
    /// 我的一天信息
    func attributedMyDayInfo() -> ASAttributedString? {
        guard isAddedToMyDay else {
            return nil
        }
        
        if let image = resGetImage("todo_task_addToMyDay_24") {
            let trailingText = resGetString("My Day")
            let info: ASAttributedString = .string(image: image,
                                                   imageSize: .size(3),
                                                   imageColor: .secondaryLabel,
                                                   trailingText: trailingText,
                                                   separator: "")
            return info
        }
        
        return nil
    }
    
    /// 备注信息
    func attributedNoteInfo() -> ASAttributedString? {
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
        return nil
        /*
        guard let steps = steps as? Set<TodoStep>, steps.count > 0 else {
            return nil
        }
    
        let completedCount = steps.completedCount
        let format = resGetString("%ld of %ld")
        let trailingText = String(format: format, completedCount, steps.count)
        
        guard let checkmarkImage = resGetImage("checkmark_12") else {
            return trailingText.attributedString
        }
        
        let info: ASAttributedString = .string(image: checkmarkImage,
                                               imageSize: .size(3),
                                               imageColor: .secondaryLabel,
                                               trailingText: trailingText,
                                               separator: nil)
        return info
         */
    }
    
    /// 进度信息
    var attributedProgressInfo: ASAttributedString? {
        guard let progress = self.progress else {
            return nil
        }
        
        if progress.isValid {
            return progress.info?.attributedString
        }
        
        return nil
    }
    
    /// 标签信息
    var attributedTagInfo: ASAttributedString? {
        guard let tags = tags, tags.count > 0 else {
            return nil
        }

        let orderedTags = tags.orderedElements()
        return orderedTags.attributedInfo()
    }
}
