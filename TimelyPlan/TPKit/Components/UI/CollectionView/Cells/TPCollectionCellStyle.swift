//
//  TPCollectionCellStyle.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/9.
//

import Foundation
import FluentDarkModeKit
import UIKit

class TPCollectionCellStyle {

    /// 单元格圆角半径
    var cornerRadius: CGFloat = 0.0
    
    /// 边框线条宽度
    var borderWidth: CGFloat = 0
    
    /// 边框颜色
    var borderColor: UIColor?
    
    /// 选中时的边框颜色
    var selectedBorderColor: UIColor?
    
    /// 单元格 tintColor
    var tintColor: UIColor?
    
    /// 正常背景色
    var backgroundColor: UIColor?

    /// 选中背景色
    var selectedBackgroundColor: UIColor?
    
    init() {
        backgroundColor = Color(light: 0xFAFBFC, dark: 0x232324)
    }
}
