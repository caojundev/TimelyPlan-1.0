//
//  WSTodoGroupTasksContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation

// MARK: - 内容交互器基类

/// 按集合筛选任务组件的内容交互器基类。
///
/// 统一任务行生成、点击任务编辑与更多入口，各业务只需实现集合与任务的取数：
/// 清单、标签等集合的读取与详情展示由子类提供。
class WSTodoGroupTasksContentInteractor: WSTodoTaskContentInteractor {
    
    /// 最多展示的任务数目
    private let maximumItemCount: Int
    
    /// 任务详情的展示项
    private let option: TodoTaskDetailOption
    
    init(plugin: WSPlugin,
         context: WSPluginContext,
         maximumItemCount: Int,
         option: TodoTaskDetailOption) {
        self.maximumItemCount = max(maximumItemCount, 1)
        self.option = option
        super.init(plugin: plugin, context: context)
    }
    
    // MARK: - 取数
    /// 读取选中的集合与任务。未配置或集合已删除时不展示内容
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        fetchGroup { [weak self] group in
            guard let self = self, let group = group else {
                completion(nil)
                return
            }
            
            let items = group.tasks.map { WSTodoTaskRowItem(task: $0, option: self.option) }
            completion(WSTodoGroupTasksDataItem(group: group.info, items: items))
        }
    }
    
    /// 读取选中的集合及其任务。子类实现
    func fetchGroup(completion: @escaping (WSTodoTaskGroup?) -> Void) {
        completion(nil)
    }
    
    // MARK: - 交互
    /// 打开选中集合的详情
    func selectMore() {
        openDetail()
    }
    
    /// 打开集合详情。子类实现
    func openDetail() {
        
    }
    
    /// 点击组件主体：打开选中集合的详情
    override func performPrimaryAction() {
        selectMore()
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：固定展示一组示例任务，不受用户配置影响，条数与真实展示一致
    override func previewDataItem() -> WSPluginDataItem? {
        guard let group = previewGroupInfo() else {
            return nil
        }
        
        let titles = [resGetString("Reading"),
                      resGetString("Workout"),
                      resGetString("Writing"),
                      resGetString("Planning"),
                      resGetString("Review"),
                      resGetString("Deep Work"),
                      resGetString("Coding"),
                      resGetString("Meditation"),
                      resGetString("Coffee Break"),
                      resGetString("Family Trip")]
        /// 行颜色统一取任务优先级颜色
        let priorities: [TodoTaskPriority] = [.high, .medium, .low, .none]
        /// 示例详情：展示计划与进度，与待办任务详情一致
        let detail: ASAttributedString = Date().monthDayString.attributedString(textColor: .secondaryLabel)
        
        let items = titles.prefix(maximumItemCount).enumerated().map {
            (index: Int, title: String) -> WSTodoTaskRowItem in
            let priority: TodoTaskPriority = priorities[index % priorities.count]
            let checkType: TodoTaskCheckType = index % 3 == 0 ? .decrease : .increase
            let taskItem = WSTodoTaskItem(identifier: "preview.groupTasks.\(index)",
                                          name: title,
                                          isCompleted: index == 1,
                                          checkType: checkType,
                                          progress: CGFloat(index + 1) / 5.0,
                                          isProgressSet: index % 2 == 0,
                                          detail: detail)
            return WSTodoTaskRowItem(taskItem: taskItem, color: priority.color)
        }
        
        return WSTodoGroupTasksDataItem(group: group, items: items)
    }
    
    /// 画廊预览的集合信息。子类实现
    func previewGroupInfo() -> WSTodoGroupInfo? {
        return nil
    }
}
