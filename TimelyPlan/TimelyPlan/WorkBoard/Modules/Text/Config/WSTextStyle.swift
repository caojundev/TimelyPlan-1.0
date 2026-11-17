//
//  WSTextStyle.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/16.
//

import Foundation
import UIKit

/// 组件文本样式
enum WSTextStyle: String, Codable, TPMenuRepresentable {
    case title
    case subtitle
    case heading
    case strong
    case body
    case caption

    /// 字体大小
    var fontSize: CGFloat {
        switch self {
        case .title:
            return 20.0
        case .subtitle:
            return 18.0
        case .heading:
            return 16.0
        case .strong, .body:
            return 15.0
        case .caption:
            return 13.0
        }
    }

    /// 是否为加粗样式
    var isBold: Bool {
        switch self {
        case .body, .caption:
            return false
        default:
            return true
        }
    }

    /// 对应字体
    var font: UIFont {
        if isBold {
            return UIFont.boldSystemFont(ofSize: fontSize)
        }

        return UIFont.systemFont(ofSize: fontSize)
    }

    /// 样式选择按钮上的简写
    var shortTitle: String {
        switch self {
        case .title:
            return "H1"
        case .subtitle:
            return "H2"
        case .heading:
            return "H3"
        case .strong:
            return "S"
        case .body:
            return "P"
        case .caption:
            return "C"
        }
    }

    /// 菜单标题本地化键，顺序与 allCases 一致
    static func titles() -> [String] {
        return ["Title",
                "Subtitle",
                "Heading",
                "Strong",
                "Body",
                "Caption"]
    }
    
    var iconName: String? {
        switch self {
        case .title:
            return "plugin_title_48"
        case .body:
            return "plugin_body_48"
        default:
            return nil
        }
    }
}
