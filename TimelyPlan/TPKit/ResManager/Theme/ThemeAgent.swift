//
//  ThemeAgent.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/23.
//

import Foundation
import UIKit
protocol ThemeChangeListener: AnyObject {
    /// 主题变化
    func themeDidChange()
    
    /// 注册为主题改变监听
    func registerThemeListener()
    
    /// 取消注册主题改变监听
    func unregisterThemeListener()
}

extension ThemeChangeListener {
    
    func themeDidChange() {
        
    }
    
    func registerThemeListener() {
        ThemeAgent.shared.addListener(self)
    }
    
    func unregisterThemeListener() {
        ThemeAgent.shared.removeListener(self)
    }
}

/// 主题名称
enum Theme: String {
    case normal /// 正常
    
    var name: String {
        return rawValue.capitalizedFirstLetter()
    }
}

class ThemeAgent {
    
    static let shared = ThemeAgent()
    
    /// 当前主题名称
    private var theme: Theme = .normal
    
    /// 颜色字典
    private var colorDic = [String: UIColor]()

    /// 监听者
    private let weakDelegateCollection = TPWeakDelegateCollection()
    
    private init() {
        themeDidChange()
    }

    private func themeDidChange() {
        parseColors(for: theme)
    }
    
    /// 通知所有监听者
    private func notifyListeners() {
        weakDelegateCollection.notifyDelegates { (delegate: ThemeChangeListener) in
            delegate.themeDidChange()
        }
    }
    
    private func parseColors(for theme: Theme) {
        guard let resPath = PATH_RESOURCE else {
            return
        }
    
        let filePath = resPath + "/Themes/\(theme.name)/color.plist"
        guard let dic = NSDictionary(contentsOfFile: filePath), let rawDic = dic as? [String: Any] else {
            return
        }
        
        var colorDic = [String: UIColor]()
        parseColors(in: rawDic, currentPath: nil, toDic: &colorDic)
        self.colorDic = colorDic
    }
    
    private func parseColors(in rawDic: [String: Any],
                             currentPath: String?,
                             toDic: inout [String: UIColor]) {
        let names = rawDic.keys
        for name in names {
            guard let value = rawDic[name] else {
                continue
            }
            
            /// 当前路径
            let path: String
            if let currentPath = currentPath {
                path = currentPath / name
            } else {
                path = name
            }
            
            if let dic = value as? [String: Any] {
                /// 继续解析字典
                parseColors(in: dic, currentPath: path, toDic: &toDic)
            } else if let colorString = value as? String {
                /// 解析颜色
                if let color = colorFromString(colorString) {
                    toDic[path] = color
                }
            }
        }
    }
    
    // MARK: - 解码颜色
    private func colorFromString(_ string: String) -> UIColor? {
        if string.contains("/") {
            /// 解析浅色和深色
            let components = string.components(separatedBy: "/")
            let lightString = components[0]
            let lightColor = colorFromComponent(lightString)
            
            let darkString = components[1]
            let darkColor = colorFromComponent(darkString)
            
            assert(lightColor != nil && darkColor != nil, "浅色和深色都不能为空")
            return Color(light: lightColor, dark: darkColor)
        }
        
        /// 解析单色
        return colorFromComponent(string)
    }
    
    private func colorFromComponent(_ string: String) -> UIColor? {
        if string.contains(",") {
            let components = string.components(separatedBy: ",")
            let rgbString = components[0].whitespacesAndNewlinesTrimmedString
            let alphaString = components[1].whitespacesAndNewlinesTrimmedString
            let alpha = Float(alphaString) ?? 1.0
            return Color(rgbString, CGFloat(alpha))
        }
        
        return Color(string)
    }
    
    /// 获取颜色
    
    func color(for key: ThemeKey) -> UIColor? {
        let color = colorDic[key.value]
        assert(color != nil, "\(key.value) 颜色为空")
        return color
    }
    
    func color(for keys: [ThemeKey]) -> UIColor? {
        let key = keys.themeKey
        return color(for: key)
    }
    
    /// 监听主题变化
    func addListener(_ listener: ThemeChangeListener) {
        weakDelegateCollection.addDelegate(listener)
    }
    
    func removeListener(_ listener: ThemeChangeListener) {
        weakDelegateCollection.removeDelegate(listener)
    }
    
    /// 选择主题
    func selectTheme(_ theme: Theme) {
        guard self.theme != theme else {
            return
        }
        
        self.theme = theme
        notifyListeners()
    }
    
}
