//
//  WSTodoListPluginContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/3.
//

import Foundation

// MARK: - 内容交互器基类

/// 待办清单组件的内容交互器基类。
///
/// 统一注册待办清单数据观察者，清单增删改、移动或排序后都重新取数；
/// 子类只需实现取数与交互。
class WSTodoListPluginContentInteractor: WSPluginContentInteractor,
                                       TodoListProcessorDelegate {
    
    override init(plugin: WSPlugin, context: WSPluginContext) {
        super.init(plugin: plugin, context: context)
        
        /// 观察者由数据仓库弱引用持有，无需手动移除
        TodoRepository.addUpdater(self, for: .list)
    }
    
    // MARK: - 交互
    /// 点击组件主体：与长按菜单的「配置」一致，打开配置界面
    override func performPrimaryAction() {
        configActionHandler?()
    }
    
    // MARK: - TodoListProcessorDelegate
    /// 远程变更无法比对，保守地重新取数
    func didChangeRemoteTodoList(with results: EntityChangeResults<TodoList>?) {
        pluginDataDidChange()
    }
    
    func didCreateTodoList(_ list: TodoList) {
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
    
    func didMoveTodoList(_ list: TodoList, to parent: TodoList?) {
        pluginDataDidChange()
    }
    
    /// 排序变化会影响列表类组件的展示顺序
    func didReorderTodoList(_ list: TodoList) {
        pluginDataDidChange()
    }
}
