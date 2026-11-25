//
//  WSTodoTagTasksContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation

// MARK: - 内容交互器

/// 待办自选标签任务组件的内容交互器。
///
/// 读取配置中选中的标签及其未完成任务；标签增删改或任务变化时重新取数，
/// 点击任务与完成状态沿用待办任务交互器基类。
class WSTodoTagTasksContentInteractor: WSTodoGroupTasksContentInteractor,
                                      TodoTagProcessorDelegate {
    
    /// 标签头部图标
    private let titleIcon = TPIcon(name: "todo_task_tag_24")
    
    override init(plugin: WSPlugin,
         context: WSPluginContext,
         maximumItemCount: Int,
         option: TodoTaskDetailOption) {
        super.init(plugin: plugin,
                   context: context,
                   maximumItemCount: maximumItemCount,
                   option: option)
        
        /// 头部展示的标签名称与颜色需要随标签变化刷新
        TodoRepository.addUpdater(self, for: .tag)
    }
    
    /// 用户选中的标签标识
    private var selectedIdentifier: String? {
        return plugin.configuration(as: WSTodoTagSelectedTagConfiguration.self)?.tagIdentifier
    }
    
    // MARK: - 取数
    /// 读取选中的标签与其中的未完成任务。未配置或标签已删除时不展示内容
    override func fetchGroup(completion: @escaping (WSTodoTaskGroup?) -> Void) {
        guard let identifier = selectedIdentifier, !identifier.isEmpty else {
            /// 用户未选择标签时交给空白内容视图
            completion(nil)
            return
        }
        
        let titleIcon = self.titleIcon
        TodoRepository.fetchTags(of: [identifier]) { tags in
            guard let tag = tags?.first else {
                completion(nil)
                return
            }
            
            TodoRepository.fetchTasks(tag: tag, showCompleted: false) { tasks in
                let item = WSTodoTagDataItem(tag: tag)
                let info = WSTodoGroupInfo(title: item.title,
                                           icon: titleIcon,
                                           color: item.color)
                completion(WSTodoTaskGroup(info: info, tasks: tasks ?? []))
            }
        }
    }
    
    // MARK: - 交互
    /// 打开所选标签的详情
    override func openDetail() {
        guard let identifier = selectedIdentifier,
              let tag = TodoRepository.getTag(with: identifier) else {
            return
        }
        
        WSTodoTagDetailPresenter.showDetail(for: tag)
    }
    
    // MARK: - 预览数据
    override func previewGroupInfo() -> WSTodoGroupInfo? {
        let item = WSTodoTagDataItem(previewIdentifier: "preview.tagTasks",
                                     title: resGetString("Study"),
                                     color: TodoTag.colors.first ?? .primary)
        return WSTodoGroupInfo(title: item.title, icon: titleIcon, color: item.color)
    }
    
    // MARK: - TodoTagProcessorDelegate
    /// 远程变更无法比对，保守地重新取数
    func didChangeRemoteTodoTag(with results: EntityChangeResults<TodoTag>?) {
        pluginDataDidChange()
    }
    
    func didUpdateTodoTag(_ tag: TodoTag, with editingTag: TodoEditingTag) {
        pluginDataDidChange()
    }
    
    func didDeleteTodoTag(_ tag: TodoTag) {
        pluginDataDidChange()
    }
}
