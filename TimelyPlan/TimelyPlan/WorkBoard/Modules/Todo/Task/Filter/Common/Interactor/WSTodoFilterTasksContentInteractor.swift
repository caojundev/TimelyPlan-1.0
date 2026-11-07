//
//  WSTodoFilterTasksContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation

// MARK: - 内容交互器

/// 待办自选过滤器任务组件的内容交互器。
///
/// 读取配置中选中的过滤器及其未完成任务；过滤器增删改或任务变化时重新取数，
/// 点击任务与完成状态沿用待办任务交互器基类。
class WSTodoFilterTasksContentInteractor: WSTodoGroupTasksContentInteractor,
                                         TodoFilterProcessorDelegate {
    
    /// 过滤器头部图标
    private let titleIcon = TPIcon(name: "todo_home_filter_24")
    
    override init(plugin: WSPlugin,
         context: WSPluginContext,
         maximumItemCount: Int,
         option: TodoTaskDetailOption) {
        super.init(plugin: plugin,
                   context: context,
                   maximumItemCount: maximumItemCount,
                   option: option)
        
        /// 头部展示的过滤器名称与颜色需要随过滤器变化刷新
        TodoRepository.addUpdater(self, for: .filter)
    }
    
    /// 用户选中的过滤器标识
    private var selectedIdentifier: String? {
        return plugin.configuration(as: WSTodoFilterSelectedFilterConfiguration.self)?.filterIdentifier
    }
    
    // MARK: - 取数
    /// 读取选中的过滤器与其中的未完成任务。未配置或过滤器已删除时不展示内容
    override func fetchGroup(completion: @escaping (WSTodoTaskGroup?) -> Void) {
        guard let identifier = selectedIdentifier, !identifier.isEmpty else {
            /// 用户未选择过滤器时交给空白内容视图
            completion(nil)
            return
        }
        
        let titleIcon = self.titleIcon
        TodoRepository.fetchFilters(of: [identifier]) { filters in
            guard let filter = filters?.first else {
                completion(nil)
                return
            }
            
            TodoRepository.fetchTasks(filter: filter, showCompleted: false) { tasks in
                let item = WSTodoFilterDataItem(filter: filter)
                let info = WSTodoGroupInfo(title: item.title,
                                           icon: titleIcon,
                                           color: item.color)
                completion(WSTodoTaskGroup(info: info, tasks: tasks ?? []))
            }
        }
    }
    
    // MARK: - 交互
    /// 打开所选过滤器的详情
    override func openDetail() {
        guard let identifier = selectedIdentifier,
              let filter = TodoRepository.getFilter(of: identifier) else {
            return
        }
        
        WSTodoFilterDetailPresenter.showDetail(for: filter)
    }
    
    // MARK: - 预览数据
    override func previewGroupInfo() -> WSTodoGroupInfo? {
        let item = WSTodoFilterDataItem(previewIdentifier: "preview.filterTasks",
                                        title: resGetString("Study"),
                                        color: TodoFilter.colors.first ?? TodoFilter.defaultColor)
        return WSTodoGroupInfo(title: item.title, icon: titleIcon, color: item.color)
    }
    
    // MARK: - TodoFilterProcessorDelegate
    /// 远程变更无法比对，保守地重新取数
    func didChangeRemoteTodoFilter(with results: EntityChangeResults<TodoFilter>?) {
        pluginDataDidChange()
    }
    
    func didUpdateTodoFilter(_ filter: TodoFilter, with editingFilter: TodoEditingFilter) {
        pluginDataDidChange()
    }
    
    func didDeleteTodoFilter(_ filter: TodoFilter) {
        pluginDataDidChange()
    }
}
