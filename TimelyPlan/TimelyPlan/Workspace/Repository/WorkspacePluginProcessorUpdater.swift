//
//  WorkspacePluginProcessorUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/17.
//

import Foundation

/// 工作台插件改变
enum WorkspacePluginChange: Equatable {
    
    /// 插件配置
    case configJSON(oldValue: String?, newValue: String?)
}

protocol WorkspacePluginProcessorDelegate: AnyObject {
    
    /// 远程插件发生变更
    func didChangeRemoteWorkspacePlugin()
    
    /// 创建新插件
    func didCreateWorkspacePlugin(_ plugin: WSPlugin)
    
    /// 删除插件
    func didDeleteWorkspacePlugin(_ plugin: WSPlugin)
    
    /// 通知插件顺序发生改变
    func didReorderWorkspacePlugin()
    
    /// 插件更新
    func didUpdateWorkspacePlugin(_ plugin: WSPlugin, with change: WorkspacePluginChange)
}

extension WorkspacePluginProcessorDelegate {
    
    func didChangeRemoteWorkspacePlugin() {}
    
    func didCreateWorkspacePlugin(_ plugin: WSPlugin) {}
    
    func didDeleteWorkspacePlugin(_ plugin: WSPlugin) {}
    
    func didReorderWorkspacePlugin() {}
    
    func didUpdateWorkspacePlugin(_ plugin: WSPlugin, with change: WorkspacePluginChange) {}
}

class WorkspacePluginProcessorUpdater: NSObject,
                                       WorkspacePluginProcessorDelegate {
    
    func didChangeRemoteWorkspacePlugin() {
        notifyDelegates { (delegate: WorkspacePluginProcessorDelegate) in
            delegate.didChangeRemoteWorkspacePlugin()
        }
    }
    
    func didCreateWorkspacePlugin(_ plugin: WSPlugin) {
        notifyDelegates { (delegate: WorkspacePluginProcessorDelegate) in
            delegate.didCreateWorkspacePlugin(plugin)
        }
    }
    
    func didDeleteWorkspacePlugin(_ plugin: WSPlugin) {
        notifyDelegates { (delegate: WorkspacePluginProcessorDelegate) in
            delegate.didDeleteWorkspacePlugin(plugin)
        }
    }
    
    func didReorderWorkspacePlugin() {
        notifyDelegates { (delegate: WorkspacePluginProcessorDelegate) in
            delegate.didReorderWorkspacePlugin()
        }
    }
    
    func didUpdateWorkspacePlugin(_ plugin: WSPlugin,
                                  with change: WorkspacePluginChange) {
        notifyDelegates { (delegate: WorkspacePluginProcessorDelegate) in
            delegate.didUpdateWorkspacePlugin(plugin, with: change)
        }
    }
}
