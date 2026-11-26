//
//  WSTodoFilterPluginContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation

// MARK: - 内容交互器基类

/// 待办过滤器组件的内容交互器基类。
///
/// 统一注册待办过滤器数据观察者，过滤器增删改、排序后都重新取数；
/// 子类只需实现取数与交互。
class WSTodoFilterPluginContentInteractor: WSPluginContentInteractor,
                                           TodoFilterProcessorDelegate {
    
    override init(plugin: WSPlugin, context: WSPluginContext) {
        super.init(plugin: plugin, context: context)
        
        /// 观察者由数据仓库弱引用持有，无需手动移除
        TodoRepository.addUpdater(self, for: .filter)
    }
    
    // MARK: - 交互
    /// 点击组件主体：与长按菜单的「配置」一致，打开配置界面
    override func performPrimaryAction() {
        configActionHandler?()
    }
    
    // MARK: - TodoFilterProcessorDelegate
    func didChangeRemoteTodoFilter(with results: EntityChangeResults<TodoFilter>?) {
        pluginDataDidChange()
    }
    
    func didCreateTodoFilter(_ filter: TodoFilter) {
        pluginDataDidChange()
    }
    
    func didDeleteTodoFilter(_ filter: TodoFilter) {
        pluginDataDidChange()
    }
    
    func didUpdateTodoFilter(_ filter: TodoFilter, with editingFilter: TodoEditingFilter) {
        pluginDataDidChange()
    }
    
    /// 排序变化会影响列表类组件的展示顺序
    func didReorderTodoFilter(in filters: [TodoFilter], fromIndex: Int, toIndex: Int) {
        pluginDataDidChange()
    }
}
