//
//  FocusRecordEnums.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/21.
//

import Foundation

/// 专注记录列表模式
enum FocusRecordListMode: Int, Codable {
    case detail = 0
    case basic
}

enum FocusRecordSortOrder: Int, Codable {
    case ascending = 0 /// 升序
    case descending    /// 降序
}
