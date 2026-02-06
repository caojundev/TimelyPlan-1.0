//
//  TimeInterval+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/24.
//

import Foundation

/// 时间显示样式
enum TimeDisplayStyle {
    case hourMinuteSecond
    case minuteSecond
}

extension TimeInterval {
    
    /// 时位
    var hoursDigit: Int {
        return Int(self) / SECONDS_PER_HOUR
    }
    
    /// 分位
    var minutesDigit: Int {
        return (Int(self) % SECONDS_PER_HOUR) / SECONDS_PER_MINUTE
    }
    
    /// 总分钟数
    var minutes: Int {
        return Int(self) / SECONDS_PER_MINUTE
    }
    
    /// 秒位
    var secondsDigit: Int {
        return Int(self) % SECONDS_PER_MINUTE
    }
    
    var seconds: TimeInterval {
        let s = self.truncatingRemainder(dividingBy: 60)
        return s
    }
    
    /// 时间字符串
    var timeString: String {
        return timeString(withStyle: .hourMinuteSecond)
    }
    
    func timeString(withStyle style: TimeDisplayStyle) -> String {
        let h: Int, m: Int, s: Int
        if style == .hourMinuteSecond {
            h = hoursDigit
            m = minutesDigit
        } else {
            h = 0
            m = minutes
        }
        
        s = secondsDigit
        if h > 0 {
            return String(format: "%02d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%02d:%02d", m, s)
        }
    }
}
