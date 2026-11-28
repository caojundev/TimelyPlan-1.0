//
//  WSQuadrantLargeTaskListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/31.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 四象限·大·任务列表。展示配置中选择的一个象限的未完成任务。
class WSQuadrantLargeTaskListPluginProvider: WSQuadrantTaskListPluginProvider {
    
    init() {
        super.init(type: .Quadrant.largeTaskList)
    }
    
    /// 创建该组件内容视图。大尺寸高度更大，行高与行间距相应增大
    ///
    /// 任务行需容纳名称（18）、详情（14）、进度（4）及其间距（约 38），
    /// 行高低于该高度时行内的详情会被省略，因此最小行高取 40
    override func makeContentView() -> WSPluginContentView {
        return WSQuadrantTaskListContentView(minimumRowHeight: 40.0, rowSpacing: 3.0)
    }
    
    override func makeContentInteractor(plugin: WSPlugin,
                                        context: WSPluginContext) -> WSPluginContentInteractor {
        return WSQuadrantLargeTaskListContentInteractor(plugin: plugin, context: context)
    }
}
