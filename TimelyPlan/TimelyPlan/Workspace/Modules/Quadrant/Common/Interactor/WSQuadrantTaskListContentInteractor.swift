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
/// 只取配置中选择的象限，未选择象限时不展示内容；取数、点击与变更监听逻辑沿用四象限任务交互器。
class WSQuadrantTaskListContentInteractor: WSQuadrantTasksContentInteractor {
    
    /// 配置中选择的象限。未配置时为 nil，由空白内容视图提示选择
    private var selectedQuadrant: Quadrant? {
        return plugin.configuration(as: WSQuadrantTaskConfiguration.self)?.quadrant
    }
    
    /// 画廊预览使用的象限。未配置时取象限布局中的第一个，各尺寸组件可覆写
    var previewQuadrant: Quadrant {
        return selectedQuadrant
            ?? QuadrantSetting.shared.layout.getQuadrants().first
            ?? .urgentImportant
    }
    
    override var targetQuadrants: [Quadrant] {
        return selectedQuadrant.map { [$0] } ?? []
    }
    
    override var previewQuadrants: [Quadrant] {
        return [previewQuadrant]
    }
    
    // MARK: - 取数
    /// 未选择象限时不展示内容，交给空白内容视图
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        guard selectedQuadrant != nil else {
            completion(nil)
            return
        }
        
        super.fetchDataItem(completion: completion)
    }
}
