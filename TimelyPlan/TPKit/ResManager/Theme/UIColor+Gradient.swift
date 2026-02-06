//
//  UIColor+Gradient.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/22.
//

import Foundation
import UIKit

extension UIColor {
    
    // MARK: - 渐变色
    
    static let gradientBackgroundFromColor = Color(light: 0xE7E9FF, dark: 0x0E0E16)
    static let gradientBackgroundToColor = Color(light: 0xF8EFE9, dark: 0x0E0E16)
    static func gradientBackground(size: CGSize) -> UIColor? {
        let frame = CGRect(size: size)
        let color = UIColor(gradientStyle: .topToBottom,
                            withFrame: frame,
                            andColors: [gradientBackgroundFromColor, gradientBackgroundToColor])
        return color
    }
    
    // MARK: - Red / 浪漫红
    private static var redGradientValues: [UInt64] = [
        0xFFECE8, 0xFDCDC5, 0xFBACA3, 0xF98981, 0xF76560,
        0xF53F3F, 0xCB272D, 0xA1151E, 0x770813, 0x4D000A
    ]

    static func red(_ index: Int) -> UIColor {
        var index = index
        clampValue(&index, 0, redGradientValues.count - 1)
        return Color(redGradientValues[index])
    }

    static var redPrimary: UIColor {
        return red(6)
    }
    
    // MARK: - Orange Red / 晚秋红
    private static var orangeRedGradientValues: [UInt64] = [
        0xFFF3E8, 0xFDDDC3, 0xFCC59F, 0xFAAC7B, 0xF99057,
        0xF77234, 0xCC5120, 0xA23511, 0x771F06, 0x4D0E00
    ]
    
    static func orangeRed(_ index: Int) -> UIColor {
        var index = index
        clampValue(&index, 0, orangeRedGradientValues.count - 1)
        return Color(orangeRedGradientValues[index])
    }

    static var orangeRedPrimary: UIColor {
        return orangeRed(6)
    }
    
    // MARK: - Orange / 活力橙
    private static var orangeGradientValues: [UInt64] = [
        0xFFF3E8, 0xFFE4BA, 0xFFCF8B, 0xFFB65D, 0xFF9A2E,
        0xFF7D00, 0xD25F00, 0xA64500, 0x792E00, 0x4D1B00
    ]
    
    static func orange(_ index: Int) -> UIColor {
        var index = index
        clampValue(&index, 0, orangeGradientValues.count - 1)
        return Color(orangeGradientValues[index])
    }

    static var orangePrimary: UIColor {
        return orange(6)
    }
    
    // MARK: - Gold / 黄昏
    private static var goldGradientValues: [UInt64] = [
        0xFFFCE8, 0xFDF4BF, 0xFCE996, 0xFADC6D, 0xF9CC45,
        0xF7BA1E, 0xCC9213, 0xA26D0A, 0x774B04, 0x4D2D00
    ]
    
    static func gold(_ index: Int) -> UIColor {
        var index = index
        clampValue(&index, 0, goldGradientValues.count - 1)
        return Color(goldGradientValues[index])
    }

    static var goldPrimary: UIColor {
        return gold(6)
    }
    
    // MARK: - Yellow / 柠檬黄
    private static var yellowGradientValues: [UInt64] = [
        0xFEFFE8, 0xFEFEBE, 0xFDFA94, 0xFCF26B, 0xFBE842,
        0xFADC19, 0xCFAF0F, 0xA38408, 0x785D03, 0x4D3800
    ]
    
    static func yellow(_ index: Int) -> UIColor {
        var index = index
        clampValue(&index, 0, yellowGradientValues.count - 1)
        return Color(yellowGradientValues[index])
    }

    static var yellowPrimary: UIColor {
        return yellow(6)
    }
    
    // MARK: - Lime / 新生绿
    private static var limeGradientValues: [UInt64] = [
        0xFCFFE8, 0xEDF8BB, 0xDCF190, 0xC9E968, 0xB5E241,
        0x9FDB1D, 0x7EB712, 0x5F940A, 0x437004, 0x2A4D00
    ]
    
    static func lime(_ index: Int) -> UIColor {
        var index = index
        clampValue(&index, 0, limeGradientValues.count - 1)
        return Color(limeGradientValues[index])
    }

    static var limePrimary: UIColor {
        return lime(6)
    }
    
    // MARK: - Green / 仙野绿
    private static var greenGradientValues: [UInt64] = [
        0xE8FFEA, 0xAFF0B5, 0x7BE188, 0x4CD263, 0x23C343,
        0x00B42A, 0x009A29, 0x008026, 0x006622, 0x004D1C
    ]
    
    static func green(_ index: Int) -> UIColor {
        var index = index
        clampValue(&index, 0, greenGradientValues.count - 1)
        return Color(greenGradientValues[index])
    }

    static var greenPrimary: UIColor {
        return green(6)
    }
    
    
    // MARK: - Cyan / 碧涛青

    private static var cyanGradientValues: [UInt64] = [
        0xE8FFFB, 0xB7F4EC, 0x89E9E0, 0x5EDFD6, 0x37D4CF,
        0x14C9C9, 0x0DA5AA, 0x07828B, 0x03616C, 0x00424D
    ]
    
    static func cyan(_ index: Int) -> UIColor {
        var index = index
        clampValue(&index, 0, cyanGradientValues.count - 1)
        return Color(cyanGradientValues[index])
    }

    static var cyanPrimary: UIColor {
        return cyan(6)
    }
    
    
    // MARK: - Blue / 海蔚蓝

    private static var blueGradientValues: [UInt64] = [
        0xE8F7FF, 0xC3E7FE, 0x9FD4FD, 0x7BC0FC, 0x57A9FB,
        0x3491FA, 0x206CCF, 0x114BA3, 0x063078, 0x001A4D
    ]
    
    static func blue(_ index: Int) -> UIColor {
        var index = index
        clampValue(&index, 0, blueGradientValues.count - 1)
        return Color(blueGradientValues[index])
    }

    static var bluePrimary: UIColor {
        return blue(6)
    }
    
    
    // MARK: - Arco Blue / 极致蓝

    private static var arcoBlueGradientValues: [UInt64] = [
        0xE8F3FF, 0xBEDAFF, 0x94BFFF, 0x6AA1FF, 0x4080FF,
        0x165DFF, 0x0E42D2, 0x072CA6, 0x031A79, 0x000D4D
    ]
    
    static func arcoBlue(_ index: Int) -> UIColor {
        var index = index
        clampValue(&index, 0, arcoBlueGradientValues.count - 1)
        return Color(arcoBlueGradientValues[index])
    }

    static var arcoBluePrimary: UIColor {
        return arcoBlue(6)
    }
    
    
    // MARK: - Purple / 暗夜紫

    private static var purpleGradientValues: [UInt64] = [
        0xF5E8FF, 0xDDBEF6, 0xC396ED, 0xA871E3, 0x8D4EDA,
        0x722ED1, 0x551DB0, 0x3C108F, 0x27066E, 0x16004D
    ]
    
    static func purple(_ index: Int) -> UIColor {
        var index = index
        clampValue(&index, 0, purpleGradientValues.count - 1)
        return Color(purpleGradientValues[index])
    }

    static var purplePrimary: UIColor {
        return purple(6)
    }
    
    
    // MARK: - Pink Purple / 青春紫

    private static var pinkPurpleGradientValues: [UInt64] = [
        0xFFE8FB, 0xF7BAEF, 0xF08EE6, 0xE865DF, 0xE13EDB,
        0xD91AD9, 0xB010B6, 0x8A0993, 0x650370, 0x42004D
    ]
    
    static func pinkPurple(_ index: Int) -> UIColor {
        var index = index
        clampValue(&index, 0, pinkPurpleGradientValues.count - 1)
        return Color(pinkPurpleGradientValues[index])
    }

    static var pinkPurplePrimary: UIColor {
        return pinkPurple(6)
    }
    
    
    // MARK: - Magenta / 品红

     private static var magentaGradientValues: [UInt64] = [
        0xFFE8F1, 0xFDC2DB, 0xFB9DC7, 0xF979B7, 0xF754A8,
        0xF5319D, 0xCB1E83, 0xA11069, 0x77064F, 0x4D0034
     ]
     
     static func magenta(_ index: Int) -> UIColor {
         var index = index
         clampValue(&index, 0, magentaGradientValues.count - 1)
         return Color(magentaGradientValues[index])
     }

     static var magentaPrimary: UIColor {
         return magenta(6)
     }
    
    
    // MARK: - Gray / 中性灰

    private static var grayGradientValues: [UInt64] = [
        0xF7F8FA, 0xF2F3F5, 0xE5E6EB, 0xC9CDD4, 0xA9AEB8,
        0x86909C, 0x6B7785, 0x4E5969, 0x272E3B, 0x1D2129
    ]

    static func gray(_ index: Int) -> UIColor {
        var index = index
        clampValue(&index, 0, grayGradientValues.count - 1)
        return Color(grayGradientValues[index])
    }

    static var grayPrimary: UIColor {
        return gray(6)
    }
}
