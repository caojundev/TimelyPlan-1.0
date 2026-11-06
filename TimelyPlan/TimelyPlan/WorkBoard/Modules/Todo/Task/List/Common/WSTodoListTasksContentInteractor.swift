//
//  WSTodoListTasksContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation

// MARK: - 内容交互器

/// 待办自选清单任务组件的内容交互器。
///
/// 读取配置中选中的用户清单及其未完成任务，换算成行数据后下发；
/// 清单或任务变化时重新取数，点击任务与完成状态沿用待办任务交互器基类。
class WSTodoListTasksContentInteractor: WSTodoTaskContentInteractor,
                                       TodoListProcessorDelegate {
    
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
        
        /// 头部展示的清单名称与颜色需要随清单变化刷新
        TodoRepository.addUpdater(self, for: .list)
    }
    
    // MARK: - 取数
    /// 用户选中的清单标识
    private var selectedIdentifier: String? {
        return plugin.configuration(as: WSTodoListSelectedListConfiguration.self)?.listIdentifier
    }
    
    /// 读取选中的清单与其中的未完成任务。未配置或清单已删除时不展示内容
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        guard let identifier = selectedIdentifier, !identifier.isEmpty else {
            /// 用户未选择清单时交给空白内容视图
            completion(nil)
            return
        }
        
        let option = self.option
        TodoRepository.fetchUserLists(of: [identifier]) { lists in
            guard let list = lists?.first else {
                completion(nil)
                return
            }
            
            TodoRepository.fetchUserListTasks(in: list, showCompleted: false) { tasks in
                let items = (tasks ?? []).map { WSTodoTaskRowItem(task: $0, option: option) }
                completion(WSTodoListTasksDataItem(listItem: WSTodoListDataItem(list: list),
                                                  items: items))
            }
        }
    }
    
    // MARK: - 交互
    /// 打开所选清单的详情
    func selectMore() {
        guard let dataItem = self.dataItem as? WSTodoListTasksDataItem,
              let list = dataItem.listItem.list else {
            return
        }
        
        WSTodoListDetailPresenter.showDetail(for: list)
    }
    
    /// 点击组件主体：打开所选清单的详情
    override func performPrimaryAction() {
        selectMore()
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：固定展示一组示例任务，不受用户配置影响，条数与真实展示一致
    override func previewDataItem() -> WSPluginDataItem? {
        let listItem = WSTodoListDataItem(previewIdentifier: "preview.listTasks",
                                          title: resGetString("Study"),
                                          icon: TPIcon(name: "todo_list_24"),
                                          color: Color(0x09AFFF))
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
            let taskItem = WSTodoTaskItem(identifier: "preview.listTasks.\(index)",
                                          name: title,
                                          isCompleted: index == 1,
                                          checkType: checkType,
                                          progress: CGFloat(index + 1) / 5.0,
                                          isProgressSet: index % 2 == 0,
                                          detail: detail)
            return WSTodoTaskRowItem(taskItem: taskItem, color: priority.color)
        }
        
        return WSTodoListTasksDataItem(listItem: listItem, items: items)
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
