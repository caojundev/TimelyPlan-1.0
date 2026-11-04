//
//  TodoListDetailPresenter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/3.
//

import Foundation
import UIKit

// MARK: - 详情展示

/// 待办清单详情展示。
///
/// 清单详情原本依附于待办主界面的多栏容器，工作台等独立场景以弹窗展示，
/// 并把左上角的返回换成关闭。
enum TodoListDetailPresenter {
    
    static func showDetail(for list: TodoList) {
        guard let configuration = TodoListConfiguration.configuration(for: list) else {
            return
        }
        
        let viewController = TodoListDetailSheetViewController(configuration: configuration)
        viewController.showAsNavigationRoot()
    }
}

/// 弹窗形态的待办清单详情
private class TodoListDetailSheetViewController: TodoDetailViewController {
    
    override func leftBarButtonItems() -> [UIBarButtonItem]? {
        return [chevronDownCancelButtonItem]
    }
}
