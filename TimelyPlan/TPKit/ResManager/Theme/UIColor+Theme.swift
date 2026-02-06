//
//  UIColor+ThemeColor.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/22.
//

import Foundation
import UIKit

extension UIColor {
    
    // MARK: - 背景
    
    /// 整体背景
    class var bg1: UIColor {
        return Color(light: 0xffffff, dark: 0x17171A)
    }
    
    /// 一级容器背景
    class var bg2: UIColor {
        return Color(light: 0xffffff, dark: 0x232324)
    }
    
    /// 二级容器背景
    class var bg3: UIColor {
        return Color(light: 0xffffff, dark: 0x2a2a2b)
    }
    
    /// 三级容器背景
    class var bg4: UIColor {
        return Color(light: 0xffffff, dark: 0x313132)
    }
    
    /// 弹出框背景
    class var bg5: UIColor {
        return Color(light: 0xffffff, dark: 0x373739)
    }
    
    
    // MARK: - 文本
    
    /// 标题
    class var text1: UIColor {
        return Color(light: 0x1d2129, 1.0, dark: 0xffffff, 0.9)
    }
    
    /// 语句
    class var text2: UIColor {
        return Color(light: 0x4e5969, 1.0, dark: 0xffffff, 0.7)
    }
    
    /// 次要信息
    class var text3: UIColor {
        return Color(light: 0x86909c, 1.0, dark: 0xffffff, 0.5)
    }
    
    /// 禁用状态文字
    class var text4: UIColor {
        return Color(light: 0xc9cdd4, 1.0, dark: 0xffffff, 0.3)
    }
    
    // MARK: - 主色
    /// 主颜色
    static var primary: UIColor {
        return Color(0x476AFF)
    }
    
    /// 常规
    class var primary6: UIColor {
        return .arcoBlue(6)
    }
    
    /// 悬浮（hover）
    class var primary5: UIColor {
        return .arcoBlue(5)
    }
    
    /// 点击（click）
    class var primary7: UIColor {
        return .arcoBlue(7)
    }
    
    /// 特殊场景
    class var primary4: UIColor {
        return .arcoBlue(4)
    }
    
    /// 一般禁用
    class var primary3: UIColor {
        return .arcoBlue(3)
    }
    
    /// 文字禁用
    class var primary2: UIColor {
        return .arcoBlue(2)
    }
    
    /// 浅色/白底悬浮
    class var primary1: UIColor {
        return .arcoBlue(1)
    }
    
    
    // MARK: - 成功色
    
    /// 常规
    class var success6: UIColor {
       return .green(6)
    }

    /// 悬浮（hover）
    class var success5: UIColor {
       return .green(5)
    }

    /// 点击（click）
    class var success7: UIColor {
       return .green(7)
    }

    /// 特殊场景
    class var success4: UIColor {
       return .green(4)
    }

    /// 一般禁用
    class var success3: UIColor {
       return .green(3)
    }

    /// 文字禁用
    class var success2: UIColor {
       return .green(2)
    }

    /// 浅色/白底悬浮
    class var success1: UIColor {
       return .green(1)
    }
    
    // MARK: - 警示色
    /// 常规
    class var warning6: UIColor {
        return .orange(6)
    }
    
    /// 悬浮（hover）
    class var warning5: UIColor {
        return .orange(5)
    }
    
    /// 点击（click）
    class var warning7: UIColor {
        return .orange(7)
    }
    
    /// 特殊场景
    class var warning4: UIColor {
        return .orange(4)
    }
    
    /// 一般禁用
    class var warning3: UIColor {
        return .orange(3)
    }
    
    /// 文字禁用
    class var warning2: UIColor {
        return .orange(2)
    }
    
    /// 浅色/白底悬浮
    class var warning1: UIColor {
        return .orange(1)
    }
    
    // MARK: - 错误色
    /// 常规
    class var danger6: UIColor {
        return .red(6)
    }

    /// 悬浮（hover）
    class var danger5: UIColor {
        return .red(5)
    }

    /// 点击（click）
    class var danger7: UIColor {
        return .red(7)
    }

    /// 特殊场景
    class var danger4: UIColor {
        return .red(4)
    }

    /// 一般禁用
    class var danger3: UIColor {
        return .red(3)
    }

    /// 文字禁用
    class var danger2: UIColor {
        return .red(2)
    }

    /// 浅色/白底悬浮
    class var danger1: UIColor {
        return .red(1)
    }
    
    // MARK: - 链接色
    /// 常规
    class var link6: UIColor {
       return .arcoBlue(6)
    }

    /// 悬浮（hover）
    class var link5: UIColor {
       return .arcoBlue(5)
    }

    /// 点击（click）
    class var link7: UIColor {
       return .arcoBlue(7)
    }

    /// 特殊场景
    class var link4: UIColor {
       return .arcoBlue(4)
    }

    /// 一般禁用
    class var link3: UIColor {
       return .arcoBlue(3)
    }

    /// 文字禁用
    class var link2: UIColor {
       return .arcoBlue(2)
    }

    /// 浅色/白底悬浮
    class var link1: UIColor {
       return .arcoBlue(1)
    }
    
    
    // MARK: - 边框色
    /// 浅色
    class var border1: UIColor {
       return .gray(2)
    }
    
    /// 一般
    class var border2: UIColor {
       return .gray(3)
    }
    
    /// 深/悬浮
    class var border3: UIColor {
       return .gray(4)
    }
    
    /// 重/按钮描边
    class var border4: UIColor {
       return .gray(6)
    }
    
    // MARK: - 填充颜色
    class var fill1: UIColor {
        return Color(light: 0xF7F8FA, 1.0, dark: 0xffffff, 0.04)
    }
    
    class var fill2: UIColor {
        return Color(light: 0xF2F3F5, 1.0, dark: 0xffffff, 0.08)
    }
    
    class var fill3: UIColor {
        return Color(light: 0xE5E6EB, 1.0, dark: 0xffffff, 0.12)
    }
    
    class var fill4: UIColor {
        return Color(light: 0xC9CDD4, 1.0, dark: 0xffffff, 0.16)
    }
    
    // MARK: - 数据色
    class var data1: UIColor {
        return .arcoBlue(5)
    }
    
    class var data2: UIColor {
        return .arcoBlue(3)
    }
    
    class var data3: UIColor {
        return .blue(5)
    }
    
    class var data4: UIColor {
        return .blue(3)
    }
    
    class var data5: UIColor {
        return .orange(6)
    }
    
    class var data6: UIColor {
        return .orange(3)
    }
    
    class var data7: UIColor {
        return .green(4)
    }
    
    class var data8: UIColor {
        return .green(3)
    }
    
    class var data9: UIColor {
        return .purple(4)
    }
    
    class var data10: UIColor {
        return .purple(3)
    }
    
    class var data11: UIColor {
        return .gold(6)
    }
    
    class var data12: UIColor {
        return .gold(4)
    }
    
    class var data13: UIColor {
        return .lime(6)
    }
    
    class var data14: UIColor {
        return .lime(4)
    }
    
    class var data15: UIColor {
        return .magenta(4)
    }
    
    class var data16: UIColor {
        return .magenta(3)
    }
    
    class var data17: UIColor {
        return .cyan(6)
    }
    
    class var data18: UIColor {
        return .cyan(3)
    }
    
    class var data19: UIColor {
        return .pinkPurple(4)
    }
    
    class var data20: UIColor {
        return .pinkPurple(2)
    }
    
    /// 阴影色
    static var shadow: UIColor {
        return Color(0x000000, 0.25)
    }
}

/*
extension UIColor {

    static func primary(_ keys: ColorKey...) -> UIColor? {
        return color(prefixKey: .primary, middleKeys: keys, suffixKey: nil, frame: nil)
    }
    
    static func primary(_ keys: ColorKey..., frame: CGRect?) -> UIColor? {
        return color(prefixKey: .primary, middleKeys: keys, suffixKey: nil, frame: frame)
    }
    
    static func color(_ keys: ColorKey...) -> UIColor? {
        let stringKeys = keys.map{ $0.rawValue}
        return SkinAgent.shared.color(stringKeys, frame: nil)
    }
    
    static func color(_ keys: ColorKey..., frame: CGRect?) -> UIColor? {
        let stringKeys = keys.map{ $0.rawValue}
        return SkinAgent.shared.color(stringKeys, frame: frame)
    }
    
    static func fromColor(_ keys: ColorKey...) -> UIColor? {
        let stringKeys = keys.map{ $0.rawValue}
        return SkinAgent.shared.fromColor(stringKeys)
    }
    
    static func toColor(_ keys: ColorKey...) -> UIColor? {
        let stringKeys = keys.map{ $0.rawValue}
        return SkinAgent.shared.toColor(stringKeys)
    }
    
    private static func color(prefixKey: ColorKey?,
                              middleKeys: [ColorKey],
                              suffixKey: ColorKey?,
                              frame: CGRect? = nil) -> UIColor? {
        var combineKeys = middleKeys
        if let prefixKey = prefixKey {
            combineKeys.insert(prefixKey, at: 0)
        }
        
        if let suffixKey = suffixKey {
            combineKeys.append(suffixKey)
        }
        
        let stringKeys = combineKeys.map{ $0.rawValue}
        return SkinAgent.shared.color(stringKeys, frame: frame)
    }
}
*/
