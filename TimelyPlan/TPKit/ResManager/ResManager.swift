//
//  ResManager.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/4.
//

import Foundation
import UIKit

/// 获取本地化字符串
func resGetString(_ shotName: String) -> String {
    let localizedString = NSLocalizedString(shotName, comment: "")
    return localizedString
}

/// 获取主题对应颜色
func resGetColor(_ key: ThemeKey) -> UIColor {
    let color = ThemeAgent.shared.color(for: key)
    return color!
}

func resGetColor(_ keys: ThemeKey...) -> UIColor {
    let color = ThemeAgent.shared.color(for: keys)
    return color!
}

func resGetImage(_ shotName: String) -> UIImage? {
    return UIImage(named: shotName)
}

func resGetImage(_ shotName: String, color: UIColor) -> UIImage? {
    let image = UIImage(named: shotName)
    return image?.withTintColor(color)
}

func resGetImage(_ shotName: String, size: Int) -> UIImage? {
    resGetImage(shotName, size: CGSize(width: size, height: size))
}

func resGetImage(_ shotName: String, size: CGSize) -> UIImage? {
    let imageName = resGetShotName(shotName, size: size)
    return UIImage(named: imageName)
}

func resGetShotName(_ shotName: String, size: CGSize = .mini) -> String {
    if size.width == size.height {
        return shotName + "_\(Int(size.height))"
    } else {
        return shotName + "_\(Int(size.width))x\(Int(size.height))"
    }
}
