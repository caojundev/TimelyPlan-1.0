//
//  GanttEvent.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/24.
//

import Foundation

// MARK: - 数据模型
struct GanttEvent {
    let id: String
    let name: String
    let startDate: Date
    let endDate: Date
    let progress: CGFloat
    let color: UIColor
}
