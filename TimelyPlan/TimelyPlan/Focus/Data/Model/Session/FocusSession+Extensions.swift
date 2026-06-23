//
//  FocusSession+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/20.
//

import Foundation
import UIKit

extension FocusSession {

    /// 会话显示颜色
    var color: UIColor {
        return timerFeature?.color ?? FocusConstant.sessionDefaultColor
    }
    
    /// 获取会话对应的计时器信息
    var timerFeature: TimerFeature? {
        if let timerID = self.timerID {
            return TimerFeature(identifier: timerID,
                                snapshotName: self.timerSnapshotName,
                                snapshotColorHex: self.timerSnapshotColorHex)
        }
        
        return nil
    }
    
    /// 获取会话对应的任务信息
    var taskFeature: TaskFeature? {
        if let taskID = taskID,
            let type = TaskType(rawValue: Int(taskType)) {
            return TaskFeature(type: type,
                            identifier: taskID,
                            snapshotName: self.taskSnapshotName)
        }
        
        return nil
    }
    
    var editingRecord: FocusRecord {
        let record = FocusRecord()
        record.timeline = self.recordTimeline
        record.score = Int(self.score)
        record.note = self.note
        record.timerFeature = self.timerFeature
        record.taskFeature = self.taskFeature
        return record
    }
    
    /// 记录时间线
    var recordTimeline: FocusRecordTimeline {
        let startDate = self.startDate ?? .now
        let interval = TimeInterval(self.duration)
        let pauseFragments = pauseInfo?.fragments
        let timeline = FocusRecordTimeline.timeline(startDate: startDate,
                                                    endDate: endDate,
                                                    focusDuration: interval,
                                                    pauseFragments: pauseFragments)
        return timeline
    }
    
    /// 判断当前会话是否与记录内容相同
    func isSameAs(_ record: FocusRecord) -> Bool {
        if self.recordTimeline == record.timeline &&
            self.score == record.score &&
            self.note == record.note &&
            self.timerFeature == record.timerFeature &&
            self.taskFeature == record.taskFeature {
            return true
        }
            
        return false
    }
    
    /// 是否是今日会话
    var isToday: Bool {
        if let startDate = startDate {
            return startDate.isToday
        }
        
        return false
    }

    /// 开始结束日期范围富文本
    func attributedDateRangeString() -> ASAttributedString? {
        let dateRange = DateRange(startDate: startDate, endDate: endDate)
        return dateRange.attributedTimeRange()
    }
}
