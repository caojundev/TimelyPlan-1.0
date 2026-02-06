//
//  FocusStatsDayInfo.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/26.
//

import Foundation

struct FocusStatsDayInfo {
    
    /// 日期
    var date: Date
    
    /// 当日所有会话
    var sessions: [FocusSession]
    
    /// 当日所有会话总时长
    var duration: Duration
    
    /// 当日所有会话平均评分
    var averageScore: Int?
    
    init(date: Date, sessions: [FocusSession]) {
        self.date = date
        self.sessions = sessions
        self.duration = sessions.duration
        self.averageScore = sessions.averageScore
    }

    /// 每个小时的活动进度
    var hourlyActivity: [Int: Float] {
        var result = [Int: Float]()
        let hourlyDuration = sessions.hourlyDuration(on: date)
        for (hour, duration) in hourlyDuration {
            result[hour] = Float(duration) / Float(SECONDS_PER_HOUR)
        }
        
        return result
    }
}

extension Array where Element == FocusStatsDayInfo {
    
    /// 总时长
    var duration: Duration {
        let duration = self.reduce(0) { (result, dayInfo) in
            return result + dayInfo.duration
        }
            
        return Duration(duration)
    }
    
    /// 总专注次数
    var times: Int {
        let sessionsCount = self.reduce(0) { (result, dayInfo) in
            return result + dayInfo.sessions.count
        }
            
        return sessionsCount
    }
    
    /// 平均得分
    var averageScore: Int {
        let sum = self.reduce(0) { (result, dayInfo) in
            let score = dayInfo.averageScore ?? 0
            return result + score
        }
        
        if count > 0 {
            return Int(sum) / count
        }
        
        return 0
    }

}

