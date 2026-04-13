//
//  TodoDetailCoordinator.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/2.
//

import Foundation
import UIKit

class TodoDetailCoordinator: TodoListProcessorDelegate {
    
    /// 多边栏视图管理器
    private(set) weak var multiColumnVC: TPMultiColumnViewController?
    
    private var configuration: TodoListConfiguration?
    
    init(multiColumnViewController: TPMultiColumnViewController) {
        self.multiColumnVC = multiColumnViewController
        todo.addUpdater(self)
    }
    
    /// 显示用户列表详情
    func showDetail(for item: Any) {
        guard let multiColumnVC = multiColumnVC else {
            return
        }
        
        self.configuration = TodoListConfiguration.configuration(for: item)
        if let configuration = self.configuration {
            let vc = TodoDetailViewController(configuration: configuration)
            let navController = UINavigationController(rootViewController: vc)
            multiColumnVC.replaceDetail(with: navController)
            multiColumnVC.showDetailView()
        }
    }
    
    // MARK: - TodoListProcessorDelegate
    func didDeleteTodoLists(_ lists: [TodoList]) {
        guard let configuration = self.configuration as? TodoUserListConfiguration else {
            return
        }
        
        if lists.contains(configuration.list) {
            /// 显示默认的收件箱列表
            showDetail(for: TodoSmartList.inbox)
        }
    }
    
}
