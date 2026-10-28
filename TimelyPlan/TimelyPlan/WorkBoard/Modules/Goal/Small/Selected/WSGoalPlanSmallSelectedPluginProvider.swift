//
//  WSGoalPlanSmallSelectedPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/28.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 目标计划·小·自选。展示用户自己选择的一个目标计划。
class WSGoalPlanSmallSelectedPluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .goalSmallSelected
    }
    
    /// 该组件尺寸
    var size: WSPluginSize {
        return .small
    }
    
    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSGoalPlanSmallSelectedContentView()
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSGoalPlanSelectedContentInteractor(plugin: plugin, context: context)
    }
    
    func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return WSGoalPlanSelectedConfigViewController(plugin: plugin)
    }
    
    /// 未选择目标计划时提示配置
    func makeEmptyPlaceholderConfiguration() -> WSPluginEmptyPlaceholderConfiguration? {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.iconName = "target"
        configuration.title = resGetString("No Goal Selected")
        return configuration
    }
}

// MARK: - 内容交互器

class WSGoalPlanSelectedContentInteractor: WSGoalPlanPluginContentInteractor {
    
    /// 配置中选择的目标计划标识
    private var selectedPlanIdentifier: String? {
        return plugin.configuration(as: WSGoalPlanSelectedConfiguration.self)?.planIdentifier
    }
    
    override var goalPlanIdentifier: String? {
        return selectedPlanIdentifier
    }
    
    // MARK: - 取数
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        guard let identifier = selectedPlanIdentifier,
              let goalPlan = GoalRepository.getGoalPlan(withIdentifier: identifier),
              !goalPlan.isArchived else {
            completion(nil)
            return
        }
        
        completion(WSGoalPlanDataItem(goalPlan: goalPlan))
    }
    
    // MARK: - 主操作
    /// 点击组件：打开所选目标计划的详情
    override func performPrimaryAction() {
        guard let dataItem = dataItem as? WSGoalPlanDataItem,
              let goalPlan = GoalRepository.getGoalPlan(withIdentifier: dataItem.planIdentifier) else {
            return
        }
        
        WSGoalPlanDetailPresenter.showDetail(for: goalPlan)
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：固定展示一个示例目标计划，不受用户配置影响
    override func previewDataItem() -> WSPluginDataItem? {
        let startDate = Date().dateByAddingDays(-30) ?? Date()
        let endDate = Date().dateByAddingDays(60) ?? Date()
        let goalPlan = GoalPlan(identifier: "preview.goalPlan",
                                name: resGetString("Annual Plan"),
                                colorHex: GoalConfig.goalPlanDefaultColor.hexString,
                                startDate: startDate,
                                endDate: endDate,
                                progress: 0.45)
        return WSGoalPlanDataItem(goalPlan: goalPlan)
    }
}
