//
//  FocusConstant.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/1.
//

import Foundation
import UIKit

struct FocusConstant {
    
    /// 专注主页内容最大宽度
    static let timerListContentMaxWidth = 560.0
    
    /// 默认专注计时器颜色
    static let timerDefaultColor = Color(0xE84F01)
    
    /// 倒计时计时器颜色
    static let countdownTimerColor = UIColor.primary

    /// 正计时计时器颜色
    static let stopwatchTimerColor = UIColor.primary

    /// 计时器可选颜色数值
    static let timerColors = [
        Color(0xFD2504), Color(0xE84F01), Color(0xFF9300),
        Color(0xFCB100), Color(0x306B16), Color(0x26B450),
        Color(0x09AFFF), Color(0x8C36FF), Color(0xBA1910),
        Color(0x00786C), Color(0x0096A7), Color(0x0087D3),
        Color(0x2E3BA3), Color(0x301A94), Color(0x7E22A3),
        Color(0x00CF85), Color(0x999DA8)
    ]
    
    static let sessionDefaultColor = UIColor.primary

    /// 专注会话颜色
    static let focusSessionColors = [
        Color(0xFD2504), Color(0xE84F01), Color(0xFF9300),
        Color(0xFCB100), Color(0x306B16), Color(0x26B450),
        Color(0x09AFFF), Color(0x8C36FF), Color(0xBA1910),
        Color(0x00786C), Color(0x0096A7), Color(0x0087D3),
        Color(0x2E3BA3), Color(0x301A94), Color(0x7E22A3)
    ]
}

/// 专注会话颜色
let kFocusSessionColorHexValues: [UInt64] = [
    0xFD2504, 0xE84F01, 0xFF9300, 0xFCB100, 0x306B16,
    0x26B450, 0x09AFFF, 0x8C36FF, 0xBA1910, 0x00786C,
    0x0096A7, 0x0087D3, 0x2E3BA3, 0x301A94, 0x7E22A3]
