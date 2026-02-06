//
//  TPTableCellStyle.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/27.
//

import Foundation
import UIKit
import FluentDarkModeKit

class TPTableCellStyle {
    
    /// 单元格 tintColor
    var tintColor: UIColor?

    /// 正常背景色
    var backgroundColor: UIColor?
    
    /// 选中背景色
    var selectedBackgroundColor: UIColor?
    
    /// 复选背景色
    var multipleSelectionBackgroundColor: UIColor?
    
    init() {
        self.backgroundColor = Color(light: 0xFAFBFC, dark: 0x232324)
        self.selectedBackgroundColor = Color(light: 0xF2F6FF, dark: 0x2E3033)
        self.multipleSelectionBackgroundColor = selectedBackgroundColor
    }
    
    class func defaultStyle() -> TPTableCellStyle {
        let style = TPTableCellStyle()
        style.tintColor = resGetColor(.tint)
        style.backgroundColor = resGetColor(.insetGroupedTableCellBackgroundNormal)
        style.selectedBackgroundColor = resGetColor(.insetGroupedTableCellBackgroundSelected)
        return style
    }
}
