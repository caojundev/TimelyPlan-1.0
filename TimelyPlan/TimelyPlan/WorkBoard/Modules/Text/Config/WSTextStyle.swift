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
    case largeTitle
    case title
    case headline
    case subheadline
    case body
    case caption

    /// 对应的动态字体样式
    var textStyle: UIFont.TextStyle {
        switch self {
        case .largeTitle:
            return .largeTitle
        case .title:
            return .title1
        case .headline:
            return .headline
        case .subheadline:
            return .subheadline
        case .body:
            return .body
        case .caption:
            return .caption1
        }
    }

    /// 对应字体
    var font: UIFont {
        return UIFont.preferredFont(forTextStyle: textStyle)
    }

    /// 菜单标题本地化键，顺序与 allCases 一致
    static func titles() -> [String] {
        return ["Large Title",
                "Title",
                "Headline Style",
                "Subheadline",
                "Body",
                "Caption"]
    }
}
