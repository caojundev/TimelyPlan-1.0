//
//  WSGoalPlanRowsContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/28.
//

import Foundation

// MARK: - 内容交互器

/// 目标计划行组件的内容交互器，各尺寸列表与网格共用。
///
/// 按目标计划列表的顺序读取进行中的计划，换算成行数据后下发；
/// 计划增删改或进度变化时重新取数。
class WSGoalPlanRowsContentInteractor: WSGoalPlanPluginContentInteractor {
    
    /// 最多展示的目标计划数目
    private let maximumItemCount: Int
    
    init(plugin: WSPlugin, context: WSPluginContext, maximumItemCount: Int) {
        self.maximumItemCount = maximumItemCount
        super.init(plugin: plugin, context: context)
    }
    
    // MARK: - 取数
    /// 读取进行中的目标计划，取前若干个
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        GoalRepository.fetchActiveGoalPlans { [weak self] goalPlans in
            guard let self = self else {
                completion(nil)
                return
            }
            
            let goalPlans = Array((goalPlans ?? []).prefix(self.maximumItemCount))
            guard !goalPlans.isEmpty else {
                /// 没有可展示的计划时交给空白内容视图
                completion(nil)
                return
            }
            
            let items = goalPlans.map { WSGoalPlanDataItem(goalPlan: $0) }
            completion(WSGoalPlanRowsDataItem(items: items))
        }
    }
    
    // MARK: - 交互
    /// 点击目标计划：打开计划详情
    override func performAction(with dataItem: WSPluginDataItem) {
        guard let dataItem = dataItem as? WSGoalPlanDataItem,
              let goalPlan = GoalRepository.getGoalPlan(withIdentifier: dataItem.planIdentifier) else {
            return
        }
        
        WSGoalPlanDetailPresenter.showDetail(for: goalPlan)
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：固定展示一组示例计划，不受用户数据影响，条数与真实展示一致
    override func previewDataItem() -> WSPluginDataItem? {
        let now = Date()
        let examples: [WSGoalPlanPreview] = [
            WSGoalPlanPreview(title: resGetString("Annual Plan"),
                              progress: 0.45,
                              startDays: -20,
                              endDays: 40,
                              colorHex: 0xE84F01),
            WSGoalPlanPreview(title: resGetString("Project Launch"),
                              progress: 1.0,
                              startDays: -60,
                              endDays: -1,
                              colorHex: 0x09AFFF),
            WSGoalPlanPreview(title: resGetString("New Semester"),
                              progress: 0.0,
                              startDays: 5,
                              endDays: 40,
                              colorHex: 0x26B450),
            WSGoalPlanPreview(title: resGetString("Reading"),
                              progress: 0.7,
                              startDays: -30,
                              endDays: 10,
                              colorHex: 0x8C36FF),
            WSGoalPlanPreview(title: resGetString("Workout"),
                              progress: 0.25,
                              startDays: -10,
                              endDays: 80,
                              colorHex: 0xFCB100),
            WSGoalPlanPreview(title: resGetString("Family Trip"),
                              progress: 1.0,
                              startDays: -40,
                              endDays: 0,
                              colorHex: 0xFD2504),
            WSGoalPlanPreview(title: resGetString("Graduation"),
                              progress: 0.85,
                              startDays: -120,
                              endDays: -5,
                              colorHex: 0x00786C),
            WSGoalPlanPreview(title: resGetString("Driving Test"),
                              progress: 0.1,
                              startDays: -5,
                              endDays: 14,
                              colorHex: 0x7E22A3)
        ]
        
        let items = examples.prefix(maximumItemCount).map { example -> WSGoalPlanDataItem in
            let startDate = now.dateByAddingDays(example.startDays) ?? now
            let endDate = now.dateByAddingDays(example.endDays) ?? now
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

// MARK: - 预览示例

/// 画廊预览使用的示例计划。
private struct WSGoalPlanPreview {
    
    /// 示例名称
    let title: String
    
    /// 计划进度（0.0 ~ 1.0）
    let progress: Double
    
    /// 开始日期相对今天的天数
    let startDays: Int
    
    /// 结束日期相对今天的天数
    let endDays: Int
    
    /// 示例颜色
    let colorHex: UInt64
}
