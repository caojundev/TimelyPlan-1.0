//
//  TPHexColorConvertible.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/3.
//

import Foundation
import UIKit

protocol TPHexColorConvertible {
    
    /// 颜色十六进制字符串
    var colorHex: String? {get set}
    
    /// 当十六进制颜色字符串获取颜色为空时返回的默认颜色
    static var defaultColor: UIColor { get }
}

extension TPHexColorConvertible {
    
    static var defaultColor: UIColor {
        return .primary
    }
    
    var color: UIColor? {
        get {
            if let colorHex = colorHex {
                return UIColor(RGBString: colorHex)
            }
            
            return Self.defaultColor
        }
        
        set {
            colorHex = newValue?.hexString
        }
    }
    
    var lighterColor: UIColor? {
        return color?.withBrightness(1.0).withSaturation(0.4)
    }
    
    var darkerColor: UIColor? {
        return color?.withBrightness(0.5)
    }
}
