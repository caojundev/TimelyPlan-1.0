//
//  WSGoalPlanDetailPresenter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/28.
//

import Foundation
import UIKit

// MARK: - 详情展示

/// 目标计划详情展示。
///
/// 目标计划详情原本依附于多栏容器，工作台等独立场景以弹窗展示，并把左上角的返回换成关闭。
enum WSGoalPlanDetailPresenter {
    
    static func showDetail(for goalPlan: GoalPlan) {
        let configuration = GoalPlanConfiguration(goalPlan: goalPlan)
        let viewController = WSGoalPlanDetailSheetViewController(configuration: configuration)
        viewController.showAsNavigationRoot()
    }
    
    static func showInboxDetail() {
        let viewController = WSGoalInboxDetailSheetViewController(configuration: GoalInboxConfiguration())
        viewController.showAsNavigationRoot()
    }
}

/// 弹窗形态的目标计划详情
private class WSGoalPlanDetailSheetViewController: GoalDetailViewController {
    
    override func leftBarButtonItems() -> [UIBarButtonItem]? {
        return [chevronDownCancelButtonItem]
    }
}

/// 弹窗形态的收件箱详情
private class WSGoalInboxDetailSheetViewController: GoalInboxViewController {
    
    override func leftBarButtonItems() -> [UIBarButtonItem]? {
        return [chevronDownCancelButtonItem]
    }
}
