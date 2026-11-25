//
//  WSTodoTagDetailPresenter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 详情展示

/// 待办标签详情展示。
///
/// 标签详情原本依附于待办主界面的多栏容器，工作台等独立场景以弹窗展示，
/// 并把左上角的返回换成关闭。
enum WSTodoTagDetailPresenter {
    
    static func showDetail(for tag: TodoTag) {
        guard let configuration = TodoListConfiguration.configuration(for: tag) else {
            return
        }
        
        let viewController = WSTodoTagDetailSheetViewController(configuration: configuration)
        viewController.showAsNavigationRoot()
    }
}

/// 弹窗形态的待办标签详情
private class WSTodoTagDetailSheetViewController: TodoDetailViewController {
    
    override func leftBarButtonItems() -> [UIBarButtonItem]? {
        return [chevronDownCancelButtonItem]
    }
}
