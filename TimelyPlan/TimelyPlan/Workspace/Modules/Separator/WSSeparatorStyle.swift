//
//  WSSeparatorStyle.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/11.
//

import Foundation
import UIKit

// MARK: - 分割线样式

/// 分割线样式。
///
/// `rawValue` 参与持久化，已发布的取值不可修改。
/// 新增样式时在 `title` 与 `drawing` 中补齐即可，绘制逻辑无需改动。
enum WSSeparatorStyle: String, Codable, CaseIterable {

    /// 实线
    case solid

    /// 虚线
    case dashed

    /// 粗线
    case thick

    /// 居中点
    case dotted

    /// 样式名称
    var title: String {
        switch self {
        case .solid: return resGetString("Solid")
        case .dashed: return resGetString("Dashed")
        case .thick: return resGetString("Thick")
        case .dotted: return resGetString("Dotted")
        }
    }

    /// 绘制方式
    var drawing: WSSeparatorDrawing {
        switch self {
        case .solid: return .line(width: 1.0, dashPattern: nil)
        case .dashed: return .line(width: 1.0, dashPattern: [4.0, 4.0])
        case .thick: return .line(width: 3.2, dashPattern: nil)
        case .dotted: return .dots(count: 6, diameter: 3.0, spacing: 4.0)
        }
    }
}

// MARK: - 绘制方式

/// 分割线的绘制方式
enum WSSeparatorDrawing {

    /// 一条横线
    /// - Parameters:
    ///   - width: 线宽
    ///   - dashPattern: 线段的虚实间隔。实线传 nil
    case line(width: CGFloat, dashPattern: [CGFloat]?)

    /// 居中排列的圆点
    /// - Parameters:
    ///   - count: 圆点个数
    ///   - diameter: 圆点直径
    ///   - spacing: 相邻圆点的间距
    case dots(count: Int, diameter: CGFloat, spacing: CGFloat)
}
