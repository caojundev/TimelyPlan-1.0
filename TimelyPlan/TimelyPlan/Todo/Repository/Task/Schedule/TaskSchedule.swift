//
//  TaskScheduleItem.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/30.
//

import Foundation
import UIKit
         
struct TaskSchedule: Hashable, Equatable {

    /// 计划日期信息
    var dateInfo: TaskDateInfo?
    
    /// 计划提醒
    var reminder: TaskReminder?

    /// 重复规则
    var repeatRule: RepeatRule?
    
    /// 是否已计划
    var isScheduled: Bool {
        return dateInfo != nil
    }
    
    /// 是否逾期
    var isOverdue: Bool {
        if let dateInfo = dateInfo, dateInfo.isOverdue {
            return true
        }
        
        return false
    }
    
    /// 是否重复
    var shouldRepeat: Bool {
        guard let repeatRule = repeatRule else {
            return false
        }
        
        return repeatRule.type != RepeatType.none
    }
    
    // MARK: - 获取数据
    /// 重复标题、副标题
    func repeatTitle() -> String? {
        guard let eventDate = dateInfo?.startDate else {
            return nil
        }
        
        return repeatRule?.title(for: eventDate)
    }
    
    /// 重复副标题
    func repeatSubtitle() -> String? {
        guard let eventDate = dateInfo?.startDate else {
            return nil
        }
        
        return repeatRule?.subtitle(for: eventDate)
    }
    
    func attributedInfo(isSlashFormattedDate: Bool = true,
                        normalColor: UIColor = .secondaryLabel,
                        highlightedColor: UIColor = .primary,
                        overdueColor: UIColor = .redPrimary,
                        imageSize: CGSize = .size(3),
                        showRepeatCount: Bool = false,
                        separator: String = "") -> ASAttributedString? {
        guard let dateInfo = dateInfo else {
            return nil
        }

        let color: UIColor
        let isOverdue = dateInfo.isOverdue
        if isOverdue {
            color = overdueColor
        } else if dateInfo.startDate.isToday || dateInfo.startDate.isTomorrow {
            color = highlightedColor
        } else {
            color = normalColor
        }
        
        var attributedInfos = [ASAttributedString]()
        /// 日期
        if let dateRangeInfo = attributedDateInfo(isSlashFormattedDate: isSlashFormattedDate, color: color) {
            attributedInfos.append(dateRangeInfo)
        }
        
        /// 提醒
        if let reminderInfo = attributedReminderInfo(imageColor: color, imageSize: imageSize) {
            attributedInfos.append(reminderInfo)
        }
        
        /// 重复
        if let repeatInfo = attributedRepeatRuleInfo(imageColor: color, imageSize: imageSize, showCountInfo: showRepeatCount) {
            attributedInfos.append(repeatInfo)
        }

        guard attributedInfos.count > 0 else {
            return nil
        }
        
        return attributedInfos.joined(separator: separator)
    }
    
    func attributedDateInfo(isSlashFormattedDate: Bool = true,
                            color: UIColor = .secondaryLabel) -> ASAttributedString? {
        return dateInfo?.attributedTitle(slashFormatted: isSlashFormattedDate,
                                         textColor: color)
    }
    
    /// 提醒富文本信息
    func attributedReminderInfo(imageColor: UIColor = .secondaryLabel,
                                imageSize: CGSize = .size(3)) -> ASAttributedString? {
        guard let reminder = reminder, reminder.hasAlarm else {
            return nil
        }
        
        if let image = resGetImage("schedule_alarm_24") {
            let reminderInfo: ASAttributedString = .string(image: image,
                                                           imageSize: imageSize,
                                                           imageColor: imageColor)
            return reminderInfo
        }
        
        return nil
    }
    
    /// 重复富文本信息
    func attributedRepeatRuleInfo(imageColor: UIColor = .secondaryLabel,
                                  imageSize: CGSize = .size(3),
                                  showCountInfo: Bool = false) -> ASAttributedString? {
        guard let repeatRule = repeatRule, repeatRule.type != RepeatType.none else {
            return nil
        }
        
        if let repeatInfo = repeatRule.attributedInfo(imageColor: imageColor,
                                                      imageSize: imageSize,
                                                      showCountInfo: showCountInfo) {
            return repeatInfo
        }
        
        return nil
    }
}

extension TaskSchedule {
    
    static func schedule(for startDateType: TodoTaskStartDateType) -> TaskSchedule? {
        var dateInfo: TaskDateInfo?
        switch startDateType {
        case .started:
            dateInfo = TaskDateInfo()
        case .today:
            dateInfo = TaskDateInfo()
        case .tomorrow:
            let date = Date().dateByAddingDays(1)!
            dateInfo = TaskDateInfo(date: date)
        case .upcoming:
            let date = Date().dateByAddingDays(2)!
            dateInfo = TaskDateInfo(date: date)
        case .later:
            let date = Date().dateByAddingDays(3)!
            dateInfo = TaskDateInfo(date: date)
        case .unassigned:
            break
        }
        
        guard let dateInfo = dateInfo else {
            return nil
        }

        let schedule = TaskSchedule(dateInfo: dateInfo,
                                    reminder: nil,
                                    repeatRule: nil)
        return schedule
    }
 
    static func schedule(for dueDateType: TodoTaskDueDateType) -> TaskSchedule? {
        var dateInfo: TaskDateInfo?
        switch dueDateType {
        case .today:
            dateInfo = TaskDateInfo()
        case .tomorrow:
            let date = Date().dateByAddingDays(1)!
            dateInfo = TaskDateInfo(date: date)
        case .upcoming:
            let date = Date().dateByAddingDays(2)!
            dateInfo = TaskDateInfo(date: date)
        case .later:
            let date = Date().dateByAddingDays(3)!
            dateInfo = TaskDateInfo(date: date)
        default:
            break
        }

        guard let dateInfo = dateInfo else {
            return nil
        }

        let schedule = TaskSchedule(dateInfo: dateInfo,
                                    reminder: nil,
                                    repeatRule: nil)
        return schedule
    }
    
}

