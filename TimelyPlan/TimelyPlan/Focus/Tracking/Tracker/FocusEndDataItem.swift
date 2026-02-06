//
//  FocusEndDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/15.
//

import Foundation

struct FocusEndDataItem {
    
    /// 开始日期
    let startDate: Date
    
    /// 结束日期
    let endDate: Date
    
    /// 专注记录数组
    let focusRecords: [FocusRecord]
    
    /// 休息记录数组
    let breakRecords: [FocusRecord]?
    
    /// 最小记录时长
    let minimumRecordDuration: Duration
    
    /// 所有记录数组
    let allRecords: [FocusRecord]
    
    /// 有效专注记录
    private(set) var validFocusRecords: [FocusRecord]?
    
    /// 是否存在有效专注记录
    var isValidFocusRecordExist: Bool {
        if let validFocusRecords = validFocusRecords, validFocusRecords.count > 0 {
            return true
        }
        
        return false
    }
    
    /// 结束日期与开始日期间时间间隔
    var interval: TimeInterval {
        return endDate.timeIntervalSince(startDate)
    }
    
    /// 平均得分
    var averageScore: Int {
        guard focusRecords.count > 0 else {
            return 0
        }
        
        let totalScore = focusRecords.map { $0.score }.reduce(0, +)
        return totalScore / focusRecords.count
    }
    
    /// 专注记录中暂停数目
    var pauseCount: Int {
        return focusRecords.map { $0.timeline.pauseCount }.reduce(0, +)
    }
    
    /// 专注记录中暂停时长
    var pauseDuration: Duration {
        let interval = focusRecords.map { $0.timeline.pauseInterval }.reduce(0.0, +)
        return Duration(interval)
    }
    
    /// 专注时长
    var focusDuration: Duration {
        let interval = focusRecords.map { $0.timeline.focusInterval }.reduce(0.0, +)
        return Duration(interval)
    }
    
    /// 专注率
    var focusRate: CGFloat {
        let focusDuration = focusDuration
        let toalDuration = focusDuration + pauseDuration
        guard toalDuration > 0 else {
            return 0.0
        }
        
        return CGFloat(focusDuration) / CGFloat(toalDuration)
    }
    
    init(startDate: Date,
         endDate: Date,
         focusRecords: [FocusRecord],
         breakRecords: [FocusRecord]? = nil,
         minimumRecordDuration: Duration = 0) {
        self.startDate = startDate
        self.endDate = endDate
        self.focusRecords = focusRecords
        self.breakRecords = breakRecords
        self.minimumRecordDuration = minimumRecordDuration
        self.allRecords = focusRecords + (breakRecords ?? [])
        self.validFocusRecords = getFocusRecords(exceeding: TimeInterval(minimumRecordDuration))
    }
    
    static var emptyDataItem: FocusEndDataItem {
        let date = Date(timeIntervalSince1970: 0.0)
        return FocusEndDataItem(startDate: date, endDate: date, focusRecords: [])
    }
    
    /// 获取超过给定最小时长的专注记录数组
    private func getFocusRecords(exceeding minimumFocusInterval: TimeInterval) -> [FocusRecord]? {
        let records = self.focusRecords.filter { record in
            let focusInterval = record.timeline.focusInterval
            return focusInterval >= minimumFocusInterval
        }
        
        if records.count > 0 {
            return records
        }
        
        return nil
    }
    
}
