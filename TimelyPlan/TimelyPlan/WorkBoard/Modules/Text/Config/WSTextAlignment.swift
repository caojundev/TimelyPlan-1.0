//
//  WSTextAlignment.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/16.
//

import Foundation
import UIKit

/// 组件文本对齐方式
enum WSTextAlignment: Int, Codable, TPMenuRepresentable {
    case left
    case center
    case right

    /// 对应的文本对齐方式
    var textAlignment: NSTextAlignment {
        switch self {
        case .left:
            return .left
        case .center:
            return .center
        case .right:
            return .right
        }
    }

    /// 菜单标题本地化键，顺序与 allCases 一致
    static func titles() -> [String] {
        return ["Left", "Center", "Right"]
    }
}
