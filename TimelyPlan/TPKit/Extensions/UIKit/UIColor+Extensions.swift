//
//  UIColor+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2023/7/24.
//

import Foundation
import UIKit

func getRGBValues(from hexValue: UInt64) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
    let r = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
    let g = CGFloat((hexValue & 0x00FF00) >> 8) / 255.0
    let b = CGFloat(hexValue & 0x0000FF) / 255.0
    return (r, g, b)
}

extension UIColor {

    /// 随机颜色
    static var random: UIColor {
        let r = CGFloat(arc4random() % 255) / 255.0
        let g = CGFloat(arc4random() % 255) / 255.0
        let b = CGFloat(arc4random() % 255) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    /// 十六进制整型数值颜色
    convenience init(hex: UInt64, alpha: CGFloat = 1.0) {
        let (r, g, b) = getRGBValues(from: hex)
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
    convenience init?(RGBString: String, alpha: CGFloat = 1.0) {
        var hexString = RGBString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "").uppercased()
        if hexString.count != 6 {
            return nil
        }
        
        var hexValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&hexValue)
        let (r, g, b) = getRGBValues(from: hexValue)
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
    /// 十六进制字符串
    var hexString: String? {
        guard let components = self.cgColor.components, components.count >= 3 else {
            return nil
        }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])

        let hexString = String(format: "%02lX%02lX%02lX",
                               lroundf(r * 255),
                               lroundf(g * 255),
                               lroundf(b * 255))
        return hexString
    }
}

extension UIColor {
    
    var lighterColor: UIColor {
        return withBrightness(1.0).withSaturation(0.5)
    }
    
    var darkerColor: UIColor {
        return withAdjustedBrightness(by: -0.15)
    }
    
    /// 调整饱和度，saturation 属性的取值范围是 0.0 到 1.0。当饱和度设置为 0.0 时，即完全无色，对应的是灰阶色调（黑白灰）。而饱和度为 1.0 时，颜色会显示出最大的鲜艳度和纯度
    func withSaturation(_ s: CGFloat) -> UIColor {
        let s = min(max(0.0, s), 1.0)
        var h: CGFloat = 0.0, b: CGFloat = 0.0
        getHue(&h, saturation: nil, brightness: &b, alpha: nil)
        return UIColor(hue: h, saturation: s, brightness: b, alpha: 1.0)
    }
    
    /// 调整颜色亮度，b的范围 0.0 ～ 1.0，数值越大越亮
    func withBrightness(_ b: CGFloat) -> UIColor {
        let b = min(max(0.0, b), 1.0)
        var h: CGFloat = 0.0, s: CGFloat = 0.0
        getHue(&h, saturation: &s, brightness: nil, alpha: nil)
        return UIColor(hue: h, saturation: s, brightness: b, alpha: 1.0)
    }
    
    /// 根据传入的参数调整颜色的亮度（brightness），并返回新的颜色
    func withAdjustedBrightness(by amount: CGFloat) -> UIColor {
        var h: CGFloat = 0.0, s: CGFloat = 0.0, b: CGFloat = 0.0
        getHue(&h, saturation: &s, brightness: &b, alpha: nil)
        b = min(max(0.0, b + amount), 1.0)
        return UIColor(hue: h, saturation: s, brightness: b, alpha: 1.0)
    }
}

extension UIColor {
    
    // MARK: - Equatable
    static func == (lhs: UIColor, rhs: UIColor) -> Bool {
        return lhs.hexString == rhs.hexString
    }
    
    /// 颜色等同判断
    open override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let color = object as? UIColor else {
            return false
        }
        
        /// 比较十六进制字符串，比较颜色数值会有偏差
        return color.hexString == self.hexString
    }
}
