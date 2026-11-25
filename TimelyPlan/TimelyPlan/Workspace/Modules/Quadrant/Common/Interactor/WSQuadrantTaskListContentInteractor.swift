//
//  WSQuadrantTaskListContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/31.
//

import Foundation

// MARK: - 内容交互器

/// 单个象限任务列表的内容交互器。
///
/// 只取配置中选择的象限，取数、点击与变更监听逻辑沿用四象限任务交互器。
class WSQuadrantTaskListContentInteractor: WSQuadrantTasksContentInteractor {
    
    /// 需要展示的象限，取配置中选择的象限
    private var selectedQuadrant: Quadrant {
        let configuration = plugin.configuration(as: WSQuadrantTaskConfiguration.self)
            ?? WSQuadrantTaskConfiguration()
        return configuration.targetQuadrant
    }
    
    /// 画廊预览使用的象限，默认与展示的象限一致，各尺寸组件可覆写
    var previewQuadrant: Quadrant {
        return selectedQuadrant
    }
    
    override var targetQuadrants: [Quadrant] {
        return [selectedQuadrant]
    }
    
    override var previewQuadrants: [Quadrant] {
        return [previewQuadrant]
    }
}
