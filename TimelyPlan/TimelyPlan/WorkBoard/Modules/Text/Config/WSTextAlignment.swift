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
    
    var iconName: String? {
        switch self {
        case .left:
            return "text_alignment_left_24"
        case .center:
            return "text_alignment_center_24"
        case .right:
            return "text_alignment_right_24"
        }
    }
}
