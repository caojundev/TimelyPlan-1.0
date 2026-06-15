//
//  TodoDetailCoordinator.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/2.
//

import Foundation
import UIKit

class TodoDetailCoordinator: TodoListProcessorDelegate,
                                TodoTagProcessorDelegate {
    
    /// 多边栏视图管理器
    private(set) weak var multiColumnVC: TPMultiColumnViewController?
    
    private var configuration: TodoListConfiguration?
    
    init(multiColumnViewController: TPMultiColumnViewController) {
        self.multiColumnVC = multiColumnViewController
        TodoRepository.addUpdater(self)
    }
    
    /// 显示用户列表详情
    func showDetail(for item: Any) {
        self.replaceDetail(for: item)
        self.multiColumnVC?.showDetailView()
    }
    
    private func replaceDetail(for item: Any) {
        guard let multiColumnVC = multiColumnVC else {
            return
        }
        
        let newConfiguration = TodoListConfiguration.configuration(for: item)!
        guard newConfiguration != self.configuration else {
            return
        }
        
        self.configuration = newConfiguration
        let vc = TodoDetailViewController(configuration: newConfiguration)
        let navController = UINavigationController(rootViewController: vc)
        multiColumnVC.replaceDetail(with: navController)
    }
    
    // MARK: - TodoListProcessorDelegate
    func didDeleteTodoLists(_ lists: [TodoList]) {
        guard let configuration = self.configuration as? TodoUserListConfiguration else {
            return
        }
        
        if lists.contains(configuration.list) {
            /// 显示默认的收件箱列表
            replaceDetail(for: TodoSmartList.inbox)
        }
    }
    
    // MARK: - TodoTagProcessorDelegate
    func didDeleteTodoTag(_ tag: TodoTag) {
        guard let configuration = self.configuration as? TodoTagListConfiguration else {
            return
        }
        
        if tag.identifier == configuration.identifier {
            replaceDetail(for: TodoSmartList.inbox)
        }
    }
}
