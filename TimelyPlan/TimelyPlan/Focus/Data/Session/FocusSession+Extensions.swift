//
//  FocusSession+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/20.
//

import Foundation

extension FocusSession {
    
    var timerType: FocusTimerType {
        get {
            return FocusTimerType(rawValue: Int(timerTypeRawValue)) ?? .defaultType
        }
        
        set {
            self.timerTypeRawValue = Int64(newValue.rawValue)
        }
    }
    
    /// 获取会话对应的计时器信息
    var timerFeature: TimerFeature? {
        if let timerID = timerID {
            return TimerFeature(identifier: timerID,
                                timerType: timerType,
                                shotName: timerShotName)
        }
        
        return nil
    }
    
    /// 创建新记录
    static func newSession(with record: FocusRecord, isManual: Bool) -> FocusSession {
        let session = FocusSession.createEntity(in: .defaultContext)
        session.identifier = UUID().uuidString
        session.isManual = isManual
        session.update(with: record)
        return session
    }
    
    var editingRecord: FocusRecord {
        let record = FocusRecord()
        record.timeline = self.recordTimeline
        record.score = Int(self.score)
        record.note = self.note
        record.timer = self.timerFeature?.timer
        record.task = self.taskInfo?.task
        return record
    }
    
    /// 记录时间线
    var recordTimeline: FocusRecordTimeline {
        let startDate = self.startDate ?? .now
        let duration = FocusRecordDuration(type: .focus, interval: TimeInterval(self.duration))
        let timeline = FocusRecordTimeline(startDate: startDate, recordDurations: [duration])
        return timeline
    }
    
    /// 判断当前会话是否与记录内容相同
    func isSameAs(_ record: FocusRecord) -> Bool {
        if self.recordTimeline == record.timeline &&
            self.score == record.score &&
            self.note == record.note &&
            self.timerFeature == record.timer?.feature &&
            self.taskInfo == record.task?.info {
            return true
        }
            
        return false
    }
    
    /// 根据记录更新会话
    func update(with record: FocusRecord) {
        if let timer = record.timer {
            self.timerType = timer.timerType
            self.timerID = timer.identifier
            self.timerShotName = timer.name
        }
        
        if let taskInfo = record.task?.info {
            self.taskType = Int64(taskInfo.type.rawValue)
            self.taskID = taskInfo.identifier
            self.taskShotName = record.task?.name
        }
        
        let timeline = record.timeline
        self.startDate = timeline.startDate
        self.endDate = timeline.endDate
        self.duration = Int64(timeline.focusInterval)
        self.score = Int64(record.score)
        self.note = record.note
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
    
    /// 获取会话对应的任务信息
    var taskInfo: TaskInfo? {
        if let taskID = taskID, let type = TaskType(rawValue: Int(taskType)) {
            return TaskInfo(type: type, identifier: taskID)
        }
        
        return nil
    }
}
