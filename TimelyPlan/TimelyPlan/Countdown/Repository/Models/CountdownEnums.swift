//
//  CountdownEnums.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/14.
//

import Foundation
import UIKit

/// 倒数日事项类型
enum CountdownEventType: Int, TPMenuRepresentable {
    
    /// 倒数日
    case countdown = 0
    
    /// 纪念日
    case anniversary
    
    /// 生日
    case birthday
    
    /// 年龄
    case age
    
    /// 节日
    case holiday
    
    // MARK: - Getters
    /// 标题本地化键
    var titleKey: String {
        switch self {
        case .countdown:
            return "Countdown"
        case .anniversary:
            return "Anniversary"
        case .birthday:
            return "Birthday"
        case .age:
            return "Age"
        case .holiday:
            return "Holiday"
        }
    }
    
    /// 标题
    var title: String {
        return resGetString(titleKey)
    }
    
    /// 默认表情
    var emoji: String {
        switch self {
        case .countdown:
            return "⏳"
        case .anniversary:
            return "🕐"
        case .birthday:
            return "🎂"
        case .age:
            return "👶"
        case .holiday:
            return "🎈"
        }
    }
    
    var emojiTitle: String {
        return emoji + " " + title
    }
    
    /// 类型专属颜色（取自 CountdownConfig.countdownEventColors 调色板）
    var color: UIColor {
        switch self {
        case .countdown:
            /// 橙红：倒数日默认色
            return Color(0xE84F01)
        case .anniversary:
            /// 紫色
            return Color(0x8C36FF)
        case .birthday:
            /// 蓝色
            return Color(0x09AFFF)
        case .age:
            /// 绿色
            return Color(0x26B450)
        case .holiday:
            /// 正红
            return Color(0xFD2504)
        }
    }
}

// MARK: - 气泡菜单
extension CountdownEventType {
    
    /// 气泡菜单项
    var bubbleMenuItem: BubbleMenuItem {
        return BubbleMenuItem(title: title, icon: emoji)
    }
    
    /// 气泡菜单项列表
    static var bubbleMenuItems: [BubbleMenuItem] {
        return allCases.map { $0.bubbleMenuItem }
    }
    
    /// 根据气泡菜单项获取事项类型（以表情作为唯一标识）
    static func type(for menuItem: BubbleMenuItem) -> CountdownEventType? {
        return allCases.first { $0.emoji == menuItem.icon }
    }
}

/// 倒数日事项布局类型
enum CountdownLayoutType: Int, CaseIterable {
    
    /// 列表
    case list = 0
    
    /// 网格
    case grid
    
    /// 切换后的布局类型
    var toggled: CountdownLayoutType {
        switch self {
        case .list:
            return .grid
        case .grid:
            return .list
        }
    }
    
    var iconName: String {
        switch self {
        case .list:
            return "countdown_layout_list_24"
        case .grid:
            return "countdown_layout_grid_24"
        }
    }
    
    /// 标题
    var title: String {
        switch self {
        case .list:
            return resGetString("List")
        case .grid:
            return resGetString("Grid")
        }
    }
}

/// 倒数日事项在“我的一天”与日历中的显示方式
///
/// 全部模式仅使用一个 `Int16` 字段（`code`）落库解析：
/// - `0`：不显示（默认值）
/// - `-1`：当日显示
/// - `-2`：一直显示
/// - `> 0`：提前 N 天显示（N 即编码值，由用户自定义，取值 1...99）
/// - 其它负值：按默认的不显示处理
enum CountdownDisplayMode: Equatable, Hashable {
    
    /// 不显示
    case none
    
    /// 当日显示
    case onTheDay
    
    /// 提前 N 天显示（取值限制在 1...99）
    case daysBefore(Int)
    
    /// 一直显示
    case always
    
    // MARK: - 编码
    /// 不显示的编码值（默认值）
    static let noneCode: Int16 = 0
    
    /// 当日显示的编码值
    static let onTheDayCode: Int16 = -1
    
    /// 一直显示的编码值
    static let alwaysCode: Int16 = -2
    
    /// 可自定义的提前天数范围
    static let daysRange: ClosedRange<Int> = 1...99
    
    /// 将提前天数限制在可自定义范围内
    static func validDays(_ days: Int) -> Int {
        return min(max(days, daysRange.lowerBound), daysRange.upperBound)
    }
    
    /// 是否一直显示
    var isAlwaysVisible: Bool {
        return self == .always
    }
    
    /// 提前显示的天数（不显示与一直显示时无提前天数）
    var advanceDays: Int? {
        switch self {
        case .none, .always:
            return nil
        case .onTheDay:
            return 0
        case .daysBefore(let days):
            return Self.validDays(days)
        }
    }
    
    /// 落库编码值
    var code: Int16 {
        switch self {
        case .none:
            return Self.noneCode
        case .onTheDay:
            return Self.onTheDayCode
        case .daysBefore(let days):
            return Int16(Self.validDays(days))
        case .always:
            return Self.alwaysCode
        }
    }
    
    /// 由落库编码值解析（提前天数越界时收敛到 1...99，其它非法负值按不显示处理）
    init(code: Int16) {
        switch code {
        case Self.noneCode:
            self = .none
        case Self.onTheDayCode:
            self = .onTheDay
        case Self.alwaysCode:
            self = .always
        case 1...:
            self = .daysBefore(Self.validDays(Int(code)))
        default:
            self = .none
        }
    }
    
    // MARK: - Getters
    /// 标题
    var title: String {
        switch self {
        case .none:
            return resGetString("Do Not Show")
        case .onTheDay:
            return resGetString("On the Day")
        case .daysBefore(let days):
            let format: String
            if days > 1 {
                format = resGetString("%ld Days Early")
            } else {
                format = resGetString("%ld Day Early")
            }
            
            return String(format: format, Self.validDays(days))
        case .always:
            return resGetString("Always Show")
        }
    }
    
    /// 预设模式（菜单选项，自定义天数由用户输入）
    static let presetModes: [CountdownDisplayMode] = [.none,
                                                      .onTheDay,
                                                      .daysBefore(3),
                                                      .daysBefore(7),
                                                      .always]
}

/// 倒数日时间单位
/// 用于描述正数计数时的时间粒度（天 / 周 + 天 / 月 + 天 等）
enum CountdownTimeUnit: Int, TPMenuRepresentable {
    
    /// 天
    case days = 0
    
    /// 周 + 天
    case weekDay
    
    /// 月 + 天
    case monthDay
    
    /// 月 + 周
    case monthWeek
    
    /// 年 + 天
    case yearDay
    
    /// 年 + 周
    case yearWeek
    
    /// 年 + 月
    case yearMonth
    
    /// 用于本地化的 key（与字符串文件中的键名保持一致）
    var titleKey: String {
        return "countdown.unit.\(String(describing: self))"
    }
    
    /// 标题
    var title: String {
        return resGetString(titleKey)
    }
}
