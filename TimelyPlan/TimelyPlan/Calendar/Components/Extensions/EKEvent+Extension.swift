//
//  EKEvent+Extension.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/12.
//

import Foundation
import EventKit

// MARK: - EKEvent 扩展
struct EventPermissions {
    let canView: Bool
    let canEdit: Bool
    let canDelete: Bool
}

extension EKEvent {
    
    /// 综合判断：返回事件的操作权限
    var permissions: EventPermissions {
        guard let calendar = self.calendar else {
            return EventPermissions(canView: false, canEdit: false, canDelete: false)
        }
        
        return EventPermissions(canView: true,
                                canEdit: isEditable,
                                canDelete: isDeletable)
    }
    
    /// 判断事件是否可编辑
    var isEditable: Bool {
        guard let calendar = self.calendar else {
            // 事件没有关联日历
            return false
        }
        
        // 检查是否允许修改
        guard calendar.allowsContentModifications else {
            // 此日历不允许修改内容（如订阅日历、生日日历）
            return false
        }
        
        // 检查日历来源类型
        switch calendar.source.sourceType {
        case .birthdays, .subscribed:
            return false
        case .calDAV, .exchange:
            // 这些类型通常可编辑，但需检查权限
            break
        default:
            break
        }
        
        // 检查是否为独立事件（重复事件的例外）
        if self.isDetached {
            // 这是重复事件的分离实例，不可编辑
            return false
        }
        
        return true
    }
    
    /// 判断事件是否可删除
    var isDeletable: Bool {
        guard isEditable else {
            return false
        }
        
        if let organizer = self.organizer, !organizer.isCurrentUser {
            // 某些 Exchange/CalDAV 日历中，非组织者不能删除
            let sourceType = calendar.source.sourceType
            if sourceType == .exchange || sourceType == .calDAV {
                /// 只有事件创建者才能删除
                return false
            }
        }
        
        return true
    }
    
    /// 是否横跨多天
    var spanMultipleDays: Bool {
        return Date.days(fromDate: startDate, toDate: endDate) != 0
    }
    
    func toCalendarEvent() ->  CalendarEvent? {
        guard let identifier = self.eventIdentifier else {
            return nil
        }
        
        let color: UIColor
        if let cgColor = self.calendar.cgColor {
            color = UIColor(cgColor: cgColor)
        } else {
            color = .systemBlue
        }
        
        var isAllDay = self.isAllDay
        if !isAllDay {
            /// 跨天任务，显示为全天事项
            isAllDay = spanMultipleDays
        }
        
        return CalendarEvent(
            identifier: identifier,
            source: .system,
            name: self.title,
            color: color,
            startDate: self.startDate,
            endDate: self.endDate,
            isAllDay: isAllDay,
            sourceItem: self
        )
    }
}

// MARK: - Array 扩展
extension Array where Element == EKEvent {
    
    func toCalendarEvents() -> [CalendarEvent] {
        var results = [CalendarEvent]()
        for ekEvent in self {
            if let event = ekEvent.toCalendarEvent() {
                results.append(event)
            }
        }
        
        return results
    }
}
