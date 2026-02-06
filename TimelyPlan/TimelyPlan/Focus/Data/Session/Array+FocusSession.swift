//
//  Array+FocusSession.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/3.
//

import Foundation

extension Array where Element == FocusSession {
    
    /// 总时长
    var duration: Duration {
        let duration = self.reduce(0) { (result, session) in
            return result + session.duration
        }
            
        return Duration(duration)
    }
    
    /// 平均得分
    var averageScore: Int {
        let sum = self.reduce(0) { (result, session) in
            return result + session.score
        }
        
        if count > 0 {
            return Int(sum) / count
        }
        
        return 0
    }
    
    /// 中断次数
    var pauseCount: Int {
        let sum = self.reduce(0) { (result, session) in
            let count = session.pauses?.count ?? 0
            return result + count
        }
        
        return sum
    }
    
    var validFragments: [TimeFragment] {
        var results = [TimeFragment]()
        for session in self {
            let fragments = session.validFragments()
            results.append(contentsOf: fragments)
        }
        
        return results
    }
    
    var validDailyFragments: [TimeFragment] {
        var results = [TimeFragment]()
        for session in self {
            let fragments = session.validDailyFragments()
            results.append(contentsOf: fragments)
        }
        
        return results
    }
    
    /// 计算数组内所有片段在每个小时的总持续时间字典
    func hourlyDuration(on date: Date) -> [Int: Duration] {
        var result = [Int: Duration]()
        let fragments = validDailyFragments
        for fragment in fragments {
            guard date.isInSameDayAs(fragment.startDate) else {
                continue
            }
            
            let hourlyDuration = fragment.hourlyDuration()
            for (hour, duration) in hourlyDuration {
                result[hour, default: 0] += duration
            }
        }
        
        return result
    }
}
