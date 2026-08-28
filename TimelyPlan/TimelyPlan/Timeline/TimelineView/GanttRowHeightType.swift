//
//  GanttRowHeightType.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/28.
//

import Foundation

/// 甘特图行高类型
enum GanttRowHeightType: Int, Codable, TPMenuRepresentable {
    /// 宽松
    case loose = 0
    /// 中等
    case medium = 1
    /// 紧凑
    case compact = 2

    /// 对应的行高数值
    var rowHeight: CGFloat {
        switch self {
        case .loose:
            return 72.0
        case .medium:
            return 60.0
        case .compact:
            return 44.0
        }
    }

    static func titles() -> [String] {
        return ["Loose",
                "Medium",
                "Compact"]
    }
}
