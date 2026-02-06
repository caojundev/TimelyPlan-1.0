//
//  Int+Duration.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/8.
//

import Foundation
import UIKit

typealias Duration = Int

extension Duration {
    
    /// 小时
    var hour: Int {
        return self / SECONDS_PER_HOUR
    }
    
    /// 分钟
    var minute: Int {
        return (self - hour * SECONDS_PER_HOUR) / SECONDS_PER_MINUTE
    }
    
    /// 秒
    var second: Int {
        return (self - hour * SECONDS_PER_HOUR) % SECONDS_PER_MINUTE
    }
    
    /// 显示文本
    var title: String {
        let h = hour
        let m = minute
        let s = second
        if h == 0 && m == 0 {
            if s == 0 {
                return "0m"
            } else {
                return String(format: "%lds", s)
            }
        } else if m == 0 {
            return String(format: "%ldh", h)
        } else if h == 0 {
            return String(format: "%ldm", m)
        } else {
            return String(format: "%ldh%ldm", h, m)
        }
    }
    
    var localizedTitle: String {
        let h = hour
        let m = minute
        let s = second
        if h == 0 && m == 0 {
            if s == 0 {
                return String(format: resGetString("%ldm"), 0)
            } else {
                return String(format: resGetString("%lds"), s)
            }
        } else if m == 0 {
            return String(format: resGetString("%ldh"), h)
        } else if h == 0 {
            return String(format: resGetString("%ldm"), m)
        } else {
            return String(format: resGetString("%ldh%ldm"), h, m)
        }
    }

    var numberOfMinutes: Int {
        let minutes = self / SECONDS_PER_MINUTE
        return minutes
    }
    
    /// 富文本信息
    var attributedTitle: ASAttributedString {
        return attributedTitle()
    }
    
    func attributedTitle(symbolFont: UIFont = BOLD_SMALL_SYSTEM_FONT,
                         symbolColor: UIColor? = nil) -> ASAttributedString {
        let symbolColor = symbolColor ?? Color(light: 0x19225B, dark: 0xC0E3F4, alpha: 0.6)
        let h = hour
        let m = minute
        let hourString: ASAttributedString = "\(h)\(resGetString("H"), .font(symbolFont), .foreground(symbolColor))"
        let minuteString: ASAttributedString = "\(m)\(resGetString("M"), .font(symbolFont), .foreground(symbolColor))"
        if h == 0 && m == 0 {
            /// 显示秒
            let secondsString: ASAttributedString = "\(second)\(resGetString("S"), .font(symbolFont), .foreground(symbolColor))"
            return secondsString
        } else if m == 0 {
            return hourString
        } else if h == 0 {
            return minuteString
        } else {
            return hourString + " " + minuteString
        }
    }
}

extension Duration {
    
    /// 返回duration表示时间文本
    var timeString: String {
        String(format: "%02ld:%02ld", self.hour, self.minute)
    }
}
