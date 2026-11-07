//
//  WSTodoUserListTasksContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation

// MARK: - 内容交互器

/// 待办自选用户清单任务组件的内容交互器。
///
/// 读取配置中选中的用户清单及其未完成任务；清单增删改或任务变化时重新取数，
/// 点击任务与完成状态沿用待办任务交互器基类。
class WSTodoUserListTasksContentInteractor: WSTodoGroupTasksContentInteractor,
                                                TodoListProcessorDelegate {
    
    override init(plugin: WSPlugin,
                  context: WSPluginContext,
                  maximumItemCount: Int,
                  option: TodoTaskDetailOption) {
        super.init(plugin: plugin,
                   context: context,
                   maximumItemCount: maximumItemCount,
                   option: option)
        
        /// 头部展示的清单名称与颜色需要随清单变化刷新
        TodoRepository.addUpdater(self, for: .list)
    }
    
    /// 用户选中的清单标识
    private var selectedIdentifier: String? {
        return plugin.configuration(as: WSTodoListSelectedListConfiguration.self)?.listIdentifier
    }
    
    // MARK: - 取数
    /// 读取选中的清单与其中的未完成任务。未配置或清单已删除时不展示内容
    override func fetchGroup(completion: @escaping (WSTodoTaskGroup?) -> Void) {
        guard let identifier = selectedIdentifier, !identifier.isEmpty else {
            /// 用户未选择清单时交给空白内容视图
            completion(nil)
            return
        }
        
        TodoRepository.fetchUserLists(of: [identifier]) { lists in
            guard let list = lists?.first else {
                completion(nil)
                return
            }
            
            TodoRepository.fetchUserListTasks(in: list, showCompleted: false) { tasks in
                let item = WSTodoListDataItem(list: list)
                let info = WSTodoGroupInfo(title: item.title, icon: item.icon, color: item.color)
                completion(WSTodoTaskGroup(info: info, tasks: tasks ?? []))
            }
        }
    }
    
    // MARK: - 交互
    /// 打开所选用户清单的详情
    override func openDetail() {
        guard let identifier = selectedIdentifier,
              let list = TodoRepository.getUserList(of: identifier) else {
            return
        }
        
        WSTodoListDetailPresenter.showDetail(for: list)
    }
    
    // MARK: - 预览数据
    override func previewGroupInfo() -> WSTodoGroupInfo? {
        let item = WSTodoListDataItem(previewIdentifier: "preview.listTasks",
                                      title: resGetString("Study"),
                                      icon: TPIcon(name: "todo_list_24"),
                                      color: Color(0x09AFFF))
        return WSTodoGroupInfo(title: item.title, icon: item.icon, color: item.color)
    }
    
    // MARK: - TodoListProcessorDelegate
    /// 远程变更无法比对，保守地重新取数
    func didChangeRemoteTodoList(with results: EntityChangeResults<TodoList>?) {
        pluginDataDidChange()
    }
    
    func didUpdateTodoList(_ list: TodoList, with info: TodoUserListUpdateInfo) {
        pluginDataDidChange()
    }
    
    func didDeleteTodoLists(_ lists: [TodoList]) {
        pluginDataDidChange()
    }
    
    func didUngroupList(_ list: TodoList) {
        pluginDataDidChange()
    }
}
