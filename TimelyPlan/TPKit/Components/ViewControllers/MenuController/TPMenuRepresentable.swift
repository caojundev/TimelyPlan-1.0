//
//  TPMenuRepresentable.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/25.
//

import Foundation
import UIKit

protocol TPMenuRepresentable: RawRepresentable,
                              CaseIterable,
                              Equatable {

    /// 唯一标识符
    var identifier: String { get }
    
    /// 整数标签
    var tag: Int { get }
    
    /// 菜单动作样式
    var actionStyle: TPMenuActionStyle { get }

    /// 标题
    var title: String { get }

    /// 标题颜色
    var titleColor: UIColor { get }

    /// 图标名称
    var iconName: String? { get }

    /// 图标图片
    var iconImage: UIImage? { get }
    
    /// 图标颜色
    var iconColor: UIColor { get }

    /// 是否在菜单视图控制器dismiss前回调
    var handleBeforeDismiss: Bool { get }
    
    /// 返回对应的标题数组
    static func titles() -> [String]
    
    func iconImage(with size: CGSize) -> UIImage?
}

extension TPMenuRepresentable {
    
    /// 获取 case 索引
    var index: Int? {
        let index = Self.allCases.firstIndex(where:{ value -> Bool in
            return value == self
        })
        
        return index as? Int
    }
    
    /// 按钮动作样式
    var actionStyle: TPMenuActionStyle {
        return .normal
    }
    
    var title: String {
        let titles = Self.titles()
        if titles.count > 0, let index = index {
            return resGetString(titles[index])
        }
        
        return ""
    }
    
    static func titles() -> [String] {
        return []
    }
    
    var titleColor: UIColor {
        return .label
    }
    
    /// 获取图标
    var icon: TPIcon? {
        if let iconName = iconName {
            return TPIcon(name: iconName)
        }

        return nil
    }
    
    var iconImage: UIImage? {
        guard let iconName = iconName else {
            return nil
        }
        
        return resGetImage(iconName)
    }
    
    var iconColor: UIColor {
        return .label
    }
    
    var handleBeforeDismiss: Bool {
        return false
    }
    
    func iconImage(with size: CGSize) -> UIImage? {
        guard let iconName = iconName else {
            return nil
        }
        
        return resGetImage(iconName, size: size)
    }
}

extension TPMenuRepresentable where RawValue == Int {
    
    var iconName: String? {
        return nil
    }
    
    var identifier: String {
        return "\(self.rawValue)"
    }
    
    var tag: Int {
        return self.rawValue
    }
}

extension TPMenuRepresentable where RawValue == String {
    
    var identifier: String {
        return self.rawValue
    }
    
    /// 默认使用索引作为tag
    var tag: Int {
        return index ?? 0
    }
    
    /// 默认标题
    var title: String {
        let titles = Self.titles()
        if titles.count > 0, let index = index {
            return resGetString(titles[index])
        } else {
            return defaultTitle
        }
    }
    
    /// 默认标题
    var defaultTitle: String {
        return resGetString(rawValue.capitalizedFirstLetter())
    }
    
    /// 图标名称
    var iconName: String? {
        return nil
    }
    
    /// 默认图标名rawValue首字符大写
    func defaultIconName() -> String {
        let firstCharIndex = rawValue.startIndex
        let firstChar = String(rawValue[firstCharIndex]).capitalized
        let name = firstChar + String(rawValue.dropFirst())
        return name
    }
}
