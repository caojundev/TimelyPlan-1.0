//
//  CountdownEventDetailProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/17.
//

import Foundation

/// 倒数日事项详情选项
struct CountdownEventDetailOption: OptionSet {
    
    let rawValue: Int
    
    /// 发生日期
    static let occuranceDate = CountdownEventDetailOption(rawValue: 1 << 0)
    
    /// 我的一天
    static let myDay = CountdownEventDetailOption(rawValue: 1 << 1)
    
    /// 日历（是否添加到日历）
    static let calendar = CountdownEventDetailOption(rawValue: 1 << 2)
    
    /// 备注
    static let note = CountdownEventDetailOption(rawValue: 1 << 3)
    
    /// 所有选项
    static let all: CountdownEventDetailOption = [occuranceDate,
                                                  .myDay,
                                                  .calendar,
                                                  .note]
    
    /// 除去我的一天的所有选项
    static var allExceptMyDay: CountdownEventDetailOption {
        return all.subtracting(.myDay)
    }
}

class CountdownEventDetailProvider {
    
    /// 倒数日事项
    let event: CountdownEvent
    
    /// 详情显示选项
    let option: CountdownEventDetailOption
    
    let day: Date
    
    init(event: CountdownEvent,
         option: CountdownEventDetailOption = .all,
         day: Date = .now) {
        self.event = event
        self.option = option
        self.day = day
    }
    
    /// 更新详情信息
    func attributedInfo() -> ASAttributedString? {
        var infos = [ASAttributedString]()
        
        if option.contains(.occuranceDate), let info = event.attributedOccuranceDateInfo(on: day) {
            infos.append(info)
        }
        
        if option.contains(.myDay), let info = event.attributedMyDayInfo {
            infos.append(info)
        }
        
        if option.contains(.calendar), let info = event.attributedCalendarInfo {
            infos.append(info)
        }
        
        if option.contains(.note), let info = event.attributedNoteInfo {
            infos.append(info)
        }
        
        if infos.count > 0 {
            return infos.joined(separator: " • ")
        }
        
        return nil
    }
}

// MARK: - 详情信息
extension CountdownEvent {
    
    /// 发生日期信息
    func attributedOccuranceDateInfo(on day: Date) -> ASAttributedString? {
        let date = occurrenceDate(on: day)
        return date.displayText.attributedString
    }
    
    /// 我的一天信息
    var attributedMyDayInfo: ASAttributedString? {
        guard myDayDisplayMode != .none else {
            return nil
        }
        
        if let image = resGetImage("todo_task_addToMyDay_24") {
            return .string(image: image, imageSize: .size(3), imageColor: .secondaryLabel)
        }
        
        return nil
    }
    
    /// 日历信息（是否添加到日历）
    var attributedCalendarInfo: ASAttributedString? {
        guard calendarDisplayMode != .none else {
            return nil
        }
        
        if let image = resGetImage("calendar_24") {
            return .string(image: image, imageSize: .size(3), imageColor: .secondaryLabel)
        }
        
        return nil
    }
    
    /// 备注信息
    var attributedNoteInfo: ASAttributedString? {
        guard let note = note, note.count > 0 else {
            return nil
        }
        
        if let image = resGetImage("todo_task_note_24") {
            return .string(image: image, imageSize: .size(3), imageColor: .secondaryLabel)
        }
        
        return nil
    }
}
