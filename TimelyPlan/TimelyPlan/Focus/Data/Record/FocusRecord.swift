//
//  FocusRecord.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/19.
//

import Foundation
import UIKit

class FocusRecord {
    
    /// 颜色
    var color: UIColor?
    
    /// 记录时间线
    var timeline: FocusRecordTimeline = FocusRecordTimeline()
    
    /// 评分
    var score: Int = 100
    
    /// 备注
    var note: String?
    
    /// 绑定的计时器
    var timer: FocusTimerRepresentable?
    
    /// 绑定的任务
    var task: TaskRepresentable?
    
    init() {}
    
    init(timer: FocusTimerRepresentable?, task: TaskRepresentable?) {
        self.timer = timer
        self.task = task
    }
    
    init(timeline: FocusRecordTimeline) {
        self.timeline = timeline
    }
}

/// 专注记录时间线对象
struct FocusRecordTimeline: Equatable {
    
    /// 开始日期
    var startDate: Date = .now
    
    /// 时间线会话数组
    var recordDurations = [FocusRecordDuration(type: .focus)]

    /// 总时长
    var totalInterval: TimeInterval {
        var result: TimeInterval = 0.0
        for recordDuration in recordDurations {
            result += recordDuration.interval
        }
        
        return result
    }
    
    /// 专注时长
    var focusInterval: TimeInterval {
        return interval(of: .focus)
    }
    
    /// 暂停时长
    var pauseInterval: TimeInterval {
        return interval(of: .pause)
    }
    
    /// 暂停次数
    var pauseCount: Int {
        var count = 0
        for recordDuration in recordDurations {
            if recordDuration.type == .pause {
                count += 1
            }
        }
        
        return count
    }

    /// 所有时间片段
    var timeFragmentInfos: [(type: FocusRecordDurationType, timeFragment: TimeFragment)]? {
        var fragments = [(FocusRecordDurationType, TimeFragment)]()
        var interval = 0.0
        for duration in recordDurations {
            let date = startDate.addingTimeInterval(interval)
            let fragment = TimeFragment(startDate: date, interval: duration.interval)
            fragments.append((duration.type, fragment))
            interval += duration.interval
        }
        
        return fragments.count > 0 ? fragments : nil
    }
    
    /// 专注时间片段
    var foucsTimeFragments: [TimeFragment]? {
        return timeFragments(for: .focus)
    }
    
    /// 暂停时间片段
    var pauseTimeFragments: [TimeFragment]? {
        return timeFragments(for: .pause)
    }

    /// 结束日期
    var endDate: Date {
        return startDate.addingTimeInterval(totalInterval)
    }
    
    /// 开始结束日期范围富文本
    func attributedDateRangeString() -> ASAttributedString? {
        let dateRange = DateRange(startDate: startDate, endDate: endDate)
        return dateRange.attributedTimeRange()
    }
    
    /// 获取对应类型对应的总时长
    private func interval(of durationType: FocusRecordDurationType) -> TimeInterval {
        var result: TimeInterval = 0.0
        for recordDuration in recordDurations {
            if recordDuration.type == durationType {
                result += recordDuration.interval
            }
        }
        
        return result
    }
    
    func timeFragments(for type: FocusRecordDurationType) -> [TimeFragment]? {
        var fragments = [TimeFragment]()
        var interval = 0.0
        for duration in recordDurations {
            if  duration.type == type {
                let date = startDate.addingTimeInterval(interval)
                let fragment = TimeFragment(startDate: date, interval: duration.interval)
                fragments.append(fragment)
            }
            
            interval += duration.interval
        }
        
        return fragments.count > 0 ? fragments : nil
    }
    
}

enum FocusRecordDurationType: Int {
    case focus  /// 专注
    case pause  /// 暂停
}

struct FocusRecordDuration: Equatable {

    /// 类型
    var type: FocusRecordDurationType = .focus
    
    /// 时长
    var interval: TimeInterval = 0.0
    
    init(type: FocusRecordDurationType) {
        self.type = type
        if type == .focus {
            self.interval = TimeInterval(25 * SECONDS_PER_MINUTE)
        } else {
            self.interval = TimeInterval(SECONDS_PER_MINUTE)
        }
    }
    
    init(type: FocusRecordDurationType, interval: TimeInterval) {
        self.type = type
        self.interval = interval
    }
}
