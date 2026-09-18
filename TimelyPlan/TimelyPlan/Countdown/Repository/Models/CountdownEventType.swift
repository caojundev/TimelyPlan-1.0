//
//  CountdownEventType.swift
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
