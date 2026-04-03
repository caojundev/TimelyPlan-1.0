//
//  TodoDetailCoordinator.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/2.
//

import Foundation
import UIKit

class TodoDetailCoordinator {
    
    /// 多边栏视图管理器
    private(set) weak var multiColumnVC: TPMultiColumnViewController?
    
    init(multiColumnViewController: TPMultiColumnViewController) {
        self.multiColumnVC = multiColumnViewController
    }
    
    /// 显示用户列表详情
    func showDetail(for item: Any) {
        guard let multiColumnVC = multiColumnVC else {
            return
        }
        
        let configuration = TodoListConfiguration.configuration(for: item)!
        let vc = TodoDetailViewController(configuration: configuration)
        let navController = UINavigationController(rootViewController: vc)
        multiColumnVC.replaceDetail(with: navController)
        multiColumnVC.showDetailView()
    }
}
