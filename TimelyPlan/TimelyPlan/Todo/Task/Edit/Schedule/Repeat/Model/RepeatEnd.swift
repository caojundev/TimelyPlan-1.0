//
//  RepeatEnd.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/23.
//

import Foundation

enum RepeatEndType: Int, TPMenuRepresentable {
    case never /// 不结束
    case date /// 按日期
    case count /// 按次数
    
    var title: String {
        switch self {
        case .never:
            return resGetString("Never")
        case .date:
            return resGetString("By Date")
        case .count:
            return resGetString("By Count")
        }
    }
}

struct RepeatEnd: Codable, Equatable, Hashable {

    /// 结束日期
    var endDate: Date?

    /// 重复次数
    var occurrenceCount: Int?
    
    var type: RepeatEndType {
        if endDate != nil {
            return .date
        }
        
        if let occurrenceCount = occurrenceCount, occurrenceCount > 0 {
            return .count
        }
        
        return .never
    }
    
    
    init(end: Date) {
        self.endDate = end
        self.occurrenceCount = nil
    }

    init(occurrenceCount: Int) {
        self.occurrenceCount = occurrenceCount
        self.endDate = nil
    }
    
    /// 结束文本
    static var neverEndText: String {
        return RepeatEndType.never.title
    }
    
    var endText: String {
        if let endDate = endDate {
            let format = resGetString("Until %@")
            return String(format: format, endDate.yearMonthDayString)
        }
        
        if let occurrenceCount = occurrenceCount, occurrenceCount > 0 {
            /// 按次数
            let format: String
            if occurrenceCount > 1 {
                format = resGetString("After %ld repeats")
            } else {
                format = resGetString("After %ld repeat")
            }
            
            return String(format: format, occurrenceCount)
        }
        
        return Self.neverEndText
    }
}

extension RepeatEnd: AttributedDescriptable {
    
    static var neverRepeatDescription: String {
        return resGetString("Task will keep repeating")
    }
 
    func localizedAttributedDescription() -> ASAttributedString? {

        if let endDate = endDate {
            /// 按日期
            let prefix: String = resGetString("Task will repeat until ")
            return prefix + "\(endDate.yearMonthDayString, highlightedTextColor)"
        }
        
        if let occurrenceCount = occurrenceCount, occurrenceCount > 0 {
            /// 按次数
            let prefix: String = resGetString("Task will repeat ")
            let format: String
            if occurrenceCount > 1 {
                format = resGetString("%ld times")
            } else {
                format = resGetString("%ld time")
            }
            
            let highlightText: String = String(format: format, occurrenceCount)
            return prefix + "\(highlightText, highlightedTextColor)"
        }

        return Self.neverRepeatDescription.attributedString
    }
}
