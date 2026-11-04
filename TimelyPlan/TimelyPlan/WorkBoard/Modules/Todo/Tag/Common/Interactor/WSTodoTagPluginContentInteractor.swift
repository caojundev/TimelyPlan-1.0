//
//  WSTodoTagPluginContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation

// MARK: - 内容交互器基类

/// 待办标签组件的内容交互器基类。
///
/// 统一注册待办标签数据观察者，标签增删改、排序后都重新取数；
/// 子类只需实现取数与交互。
class WSTodoTagPluginContentInteractor: WSPluginContentInteractor,
                                        TodoTagProcessorDelegate {
    
    override init(plugin: WSPlugin, context: WSPluginContext) {
        super.init(plugin: plugin, context: context)
        
        /// 观察者由数据仓库弱引用持有，无需手动移除
        TodoRepository.addUpdater(self, for: .tag)
    }
    
    // MARK: - 交互
    /// 点击组件主体：与长按菜单的「配置」一致，打开配置界面
    override func performPrimaryAction() {
        configActionHandler?()
    }
    
    // MARK: - TodoTagProcessorDelegate
    func didChangeRemoteTodoTag(with results: EntityChangeResults<TodoTag>?) {
        pluginDataDidChange()
    }
    
    func didCreateTodoTag(_ tag: TodoTag) {
        pluginDataDidChange()
    }
    
    func didDeleteTodoTag(_ tag: TodoTag) {
        pluginDataDidChange()
    }
    
    func didUpdateTodoTag(_ tag: TodoTag, with editingTag: TodoEditingTag) {
        pluginDataDidChange()
    }
    
    /// 排序变化会影响列表类组件的展示顺序
    func didRecorderTodoTag(in tags: [TodoTag], fromIndex: Int, toIndex: Int) {
        pluginDataDidChange()
    }
}
