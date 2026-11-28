//
//  WSQuadrantLargeTaskListContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/31.
//

import Foundation

// MARK: - 内容交互器

/// 四象限·大·任务列表的内容交互器。
///
/// 取数与交互沿用单象限任务列表交互器，卡片高度更大，可展示更多任务，因此下发更多条数。
class WSQuadrantLargeTaskListContentInteractor: WSQuadrantTaskListContentInteractor {
    
    override var maximumTaskCount: Int {
        return 8
    }

    override var previewQuadrant: Quadrant {
        return .urgentNotImportant
    }
}
