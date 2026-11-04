//
//  WSTodoFilterDetailPresenter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 详情展示

/// 待办过滤器详情展示。
///
/// 过滤器详情原本依附于待办主界面的多栏容器，工作台等独立场景以弹窗展示，
/// 并把左上角的返回换成关闭。
enum WSTodoFilterDetailPresenter {
    
    static func showDetail(for filter: TodoFilter) {
        guard let configuration = TodoListConfiguration.configuration(for: filter) else {
            return
        }
        
        let viewController = WSTodoFilterDetailSheetViewController(configuration: configuration)
        viewController.showAsNavigationRoot()
    }
}

/// 弹窗形态的待办过滤器详情
private class WSTodoFilterDetailSheetViewController: TodoDetailViewController {
    
    override func leftBarButtonItems() -> [UIBarButtonItem]? {
        return [chevronDownCancelButtonItem]
    }
}
