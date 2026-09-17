//
//  CountdownConfig.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/14.
//

import Foundation
import UIKit

struct CountdownConfig {
    
    /// 倒数日事项列表内容最大宽度
    static let eventListContentMaxWidth = 560.0
    
    /// 倒数日事项网格条目首选宽度
    static let eventGridItemWidth = 200.0
    
    /// 倒数日默认颜色
    static let countdownEventDefaultColor = Color(0xE84F01)
    
    /// 倒数日可选颜色
    static let countdownEventColors = [
        Color(0xFD2504), Color(0xE84F01), Color(0xFF9300),
        Color(0xFCB100), Color(0x306B16), Color(0x26B450),
        Color(0x09AFFF), Color(0x8C36FF), Color(0xBA1910),
        Color(0x00786C), Color(0x0096A7), Color(0x0087D3),
        Color(0x2E3BA3), Color(0x301A94), Color(0x7E22A3),
        Color(0x00CF85), Color(0x999DA8)
    ]
    
    static let defaultEmoji = "⏳"
}
