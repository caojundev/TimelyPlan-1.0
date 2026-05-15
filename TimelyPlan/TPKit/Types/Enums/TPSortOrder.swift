//
//  TPSortOrder.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/15.
//

import Foundation

enum TPSortOrder: Int, Codable, TPMenuRepresentable {
    case ascending = 0 /// 升序
    case descending    /// 降序
    
    static func titles() -> [String] {
        return ["Ascending",
                "Descending"]
    }
    
    var iconName: String? {
        switch self {
        case .ascending:
            return "focus_record_order_ascending_24"
        case .descending:
            return "focus_record_order_descending_24"
        }
    }
}
