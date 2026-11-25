//
//  WorkspaceDashboardProcessorUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/17.
//

import Foundation

/// 工作台面板改变
enum WorkspaceDashboardChange: Equatable {
    
    /// 名称
    case name(oldValue: String?, newValue: String?)
}

protocol WorkspaceDashboardProcessorDelegate: AnyObject {
    
    /// 远程面板发生变更
    func didChangeRemoteWorkspaceDashbaord()
    
    /// 创建新面板
    func didCreateWorkspaceDashbaord(_ board: WSDashboard)
    
    /// 删除面板
    func didDeleteWorkspaceDashbaord(_ board: WSDashboard)
    
    /// 通知面板顺序发生改变
    func didReorderWorkspaceDashbaord()
    
    /// 面板更新
    func didUpdateWorkspaceDashbaord(_ board: WSDashboard, with change: WorkspaceDashboardChange)
}

extension WorkspaceDashboardProcessorDelegate {
    
    func didChangeRemoteWorkspaceDashbaord() {}
    
    func didCreateWorkspaceDashbaord(_ board: WSDashboard) {}
    
    func didDeleteWorkspaceDashbaord(_ board: WSDashboard) {}
    
    func didReorderWorkspaceDashbaord() {}
    
    func didUpdateWorkspaceDashbaord(_ board: WSDashboard, with change: WorkspaceDashboardChange) {}
}

class WorkspaceDashboardProcessorUpdater: NSObject,
                                          WorkspaceDashboardProcessorDelegate {
    
    func didChangeRemoteWorkspaceDashbaord() {
        notifyDelegates { (delegate: WorkspaceDashboardProcessorDelegate) in
            delegate.didChangeRemoteWorkspaceDashbaord()
        }
    }
    
    func didCreateWorkspaceDashbaord(_ board: WSDashboard) {
        notifyDelegates { (delegate: WorkspaceDashboardProcessorDelegate) in
            delegate.didCreateWorkspaceDashbaord(board)
        }
    }
    
    func didDeleteWorkspaceDashbaord(_ board: WSDashboard) {
        notifyDelegates { (delegate: WorkspaceDashboardProcessorDelegate) in
            delegate.didDeleteWorkspaceDashbaord(board)
        }
    }
    
    func didReorderWorkspaceDashbaord() {
        notifyDelegates { (delegate: WorkspaceDashboardProcessorDelegate) in
            delegate.didReorderWorkspaceDashbaord()
        }
    }
    
    func didUpdateWorkspaceDashbaord(_ board: WSDashboard,
                                     with change: WorkspaceDashboardChange) {
        notifyDelegates { (delegate: WorkspaceDashboardProcessorDelegate) in
            delegate.didUpdateWorkspaceDashbaord(board, with: change)
        }
    }
}
