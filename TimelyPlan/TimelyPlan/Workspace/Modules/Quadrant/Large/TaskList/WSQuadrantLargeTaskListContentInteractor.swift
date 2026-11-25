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
        return 12
    }
    
    /// 任务详情的展示项：计划、步骤、进度与标签
    override var option: TodoTaskDetailOption? {
        return [.schedule, .step, .progress, .tag]
    }
    
    override var previewQuadrant: Quadrant {
        return .urgentNotImportant
    }
}
