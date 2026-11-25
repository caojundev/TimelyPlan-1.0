//
//  WSQuadrantMediumTaskListContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/31.
//

import Foundation

// MARK: - 内容交互器

/// 四象限·中·任务列表的内容交互器。
///
/// 取数与交互沿用单象限任务列表交互器，仅画廊预览固定使用第二象限样式。
class WSQuadrantMediumTaskListContentInteractor: WSQuadrantTaskListContentInteractor {
    
    override var previewQuadrant: Quadrant {
        return .notUrgentImportant
    }
}
