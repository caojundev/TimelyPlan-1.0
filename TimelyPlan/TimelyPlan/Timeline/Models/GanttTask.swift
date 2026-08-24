//
//  GanttTask.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/24.
//

import Foundation

// MARK: - 数据模型
struct GanttTask {
    let id: String
    let name: String
    let startDate: Date
    let endDate: Date
    let progress: CGFloat
    let color: UIColor
    let level: Int
    var isExpanded: Bool = true
    var children: [GanttTask]? = nil
    var isGroup: Bool { return children != nil && !children!.isEmpty }
}
