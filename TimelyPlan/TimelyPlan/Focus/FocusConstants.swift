//
//  FocusConstants.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/1.
//

import Foundation
import UIKit

/// 专注主页内容最大宽度
let kFocusHomeContentMaxWidth = 560.0

/// 默认专注计时器颜色
let kFocusTimerDefaultColor = Color(0xE84F01)

/// 计时器可选颜色数值
let kFocusTimerColorHexValues: [UInt64] = [
    0xFD2504, 0xE84F01, 0xFF9300, 0xFCB100, 0x306B16,
    0x26B450, 0x09AFFF, 0x8C36FF, 0xBA1910, 0x00786C,
    0x0096A7, 0x0087D3, 0x2E3BA3, 0x301A94, 0x7E22A3]

/// 倒计时计时器颜色
let kFocusCountdownTimerColor = UIColor.primary

/// 正计时计时器颜色
let kFocusStopwatchTimerColor = UIColor.primary

/// 本地设置项键值
/// 专注记录排列顺序
let kFocusSettingRecordsSortOrder = "FocusSettingRecordsSortOrder"
