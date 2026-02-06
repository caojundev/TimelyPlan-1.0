//
//  ColorFunctions.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/12.
//

import Foundation
import UIKit

// MARK: - 十六进制整型数值
func Color(_ hex: UInt64, _ alpha: CGFloat = 1.0) -> UIColor {
    return UIColor(hex: hex, alpha: alpha)
}

/// 浅色和深色具有相同的透明度
func Color(light: UInt64, dark: UInt64, alpha: CGFloat = 1.0) -> UIColor {
    return Color(light: light, alpha, dark: dark, alpha)
}

/// 浅色和深色具有不同的透明度
func Color(light: UInt64, _ lightAlpha: CGFloat,
           dark: UInt64, _ darkAlpha: CGFloat) -> UIColor {
    let lightColor = Color(light, lightAlpha)
    let darkColor = Color(dark, darkAlpha)
    return UIColor(.dm, light: lightColor, dark: darkColor)
}

func Color(light: UIColor?, dark: UIColor?) -> UIColor? {
    if dark == nil {
        return light
    } else if light == nil {
        return dark
    }
    
    return UIColor(.dm, light: light!, dark: dark!)
}

// MARK: - 十六进制字符串创建颜色
func Color(_ RGBString: String, _ alpha: CGFloat = 1.0) -> UIColor? {
    let alpha = max(0, min(1.0, alpha))
    return UIColor(RGBString: RGBString, alpha: alpha)
}
