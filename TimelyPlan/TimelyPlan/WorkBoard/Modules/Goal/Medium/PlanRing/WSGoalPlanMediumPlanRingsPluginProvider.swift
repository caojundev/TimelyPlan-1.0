//
//  WSGoalPlanMediumPlanRingsPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/28.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 目标·中·自选三环。以三个环展示所选目标计划的任务进度。
class WSGoalPlanMediumPlanRingsPluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .goalMediumPlanRings
    }
    
    /// 该组件尺寸
    var size: WSPluginSize {
        return .medium
    }
    
    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSGoalPlanMediumPlanRingsContentView()
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSGoalPlanMediumPlanRingsContentInteractor(plugin: plugin,
                                                          context: context,
                                                          maximumItemCount: WSGoalPlanItemCount.mediumPlanRings)
    }
    
    func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return WSGoalPlanMediumPlanRingsConfigViewController(plugin: plugin)
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

class WSGoalPlanMediumPlanRingsContentInteractor: WSGoalPlanPluginContentInteractor {
    
    /// 最多展示的目标计划数目
    private let maximumItemCount: Int
    
    init(plugin: WSPlugin, context: WSPluginContext, maximumItemCount: Int) {
        self.maximumItemCount = maximumItemCount
        super.init(plugin: plugin, context: context)
    }
    
    /// 配置中选择的目标计划标识，按选择顺序排列
    private var selectedIdentifiers: [String] {
        return plugin.configuration(as: WSGoalPlanSelectedPlansConfiguration.self)?.planIdentifiers ?? []
    }
    
    // MARK: - 取数
    /// 按选择顺序读取目标计划
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let identifiers = Array(selectedIdentifiers.prefix(maximumItemCount))
        let goalPlans = identifiers
            .compactMap { GoalRepository.getGoalPlan(withIdentifier: $0) }
            .filter { !$0.isArchived }
        
        guard !goalPlans.isEmpty else {
            /// 没有可展示的计划时交给空白内容视图
            completion(nil)
            return
        }
        
        let items = goalPlans.map { WSGoalPlanDataItem(goalPlan: $0) }
        completion(WSGoalPlanRowsDataItem(items: items))
    }
    
    // MARK: - 交互
    /// 点击计划：打开计划详情
    override func performAction(with dataItem: WSPluginDataItem) {
        guard let dataItem = dataItem as? WSGoalPlanDataItem,
              let goalPlan = GoalRepository.getGoalPlan(withIdentifier: dataItem.planIdentifier) else {
            return
        }
        
        WSGoalPlanDetailPresenter.showDetail(for: goalPlan)
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：固定展示三个示例计划，不受用户配置影响
    override func previewDataItem() -> WSPluginDataItem? {
        let now = Date()
        let examples: [(title: String, progress: Double, colorHex: UInt64)] = [
            (resGetString("Annual Plan"), 0.65, 0xE84F01),
            (resGetString("Reading"), 0.4, 0x8C36FF),
            (resGetString("Workout"), 0.85, 0xFCB100)
        ]
        
        let items = examples.prefix(maximumItemCount).enumerated().map { index, example -> WSGoalPlanDataItem in
            let startDate = now.dateByAddingDays(-30 - index * 10) ?? now
            let endDate = now.dateByAddingDays(60 - index * 10) ?? now
            let goalPlan = GoalPlan(identifier: "preview.\(example.title)",
                                    name: example.title,
                                    colorHex: Color(example.colorHex).hexString,
                                    startDate: startDate,
                                    endDate: endDate,
                                    progress: example.progress)
            return WSGoalPlanDataItem(goalPlan: goalPlan)
        }
        
        return WSGoalPlanRowsDataItem(items: items)
    }
}
