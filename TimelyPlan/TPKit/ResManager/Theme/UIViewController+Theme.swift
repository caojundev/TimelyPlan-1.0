//
//  UIViewController+ThemeColor.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/13.
//

import Foundation

import UIKit

extension UIViewController: ThemeChangeListener {
    
    // 主题背景色
    @objc var themeBackgroundColor: UIColor? {
        return .systemBackground
    }

    // 导航栏背景色
    @objc var themeNavigationBarBackgroundColor: UIColor? {
        return themeBackgroundColor
    }
    
    // 导航栏图标和文字颜色
    @objc var themeNavigationBarTintColor: UIColor? {
        return resGetColor(.navigationBar, .tint)
    }

    // 导航栏标题颜色
    @objc var themeNavigationBarTitleColor: UIColor? {
        return resGetColor(.navigationBar, .title)
    }
    
    /// 导航栏标题字体
    @objc var navigationBarTitleFont: UIFont? {
        return nil
    }

    func updateBackgroundTheme() {
        view.backgroundColor = themeBackgroundColor
    }
    
    /// 更新导航栏主题
    func updateNavigationBarTheme() {
        guard let navigationBar = self.navigationController?.navigationBar else {
            return
        }
        
        let backgroundColor = self.themeNavigationBarBackgroundColor
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = backgroundColor
        appearance.shadowImage = UIImage()
        appearance.shadowColor = UIColor.clear
        
        // 标题样式
        var textAttributes = [NSAttributedString.Key : Any]()
        if let titleColor = self.themeNavigationBarTitleColor {
            textAttributes[.foregroundColor] = titleColor
        }
        
        if let titleFont = navigationBarTitleFont {
            textAttributes[.font] = titleFont
        }
        
        appearance.titleTextAttributes = textAttributes
        appearance.largeTitleTextAttributes = textAttributes
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.backgroundColor = backgroundColor
        navigationBar.barTintColor = backgroundColor
        navigationBar.tintColor = self.themeNavigationBarTintColor
        navigationBar.isTranslucent = false
    }
    
    /// 主题变更通知响应
    @objc func themeDidChange() {
        
    }
}
