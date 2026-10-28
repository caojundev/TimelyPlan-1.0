//
//  WSGoalPlanSelectedConfigViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/28.
//

import Foundation
import UIKit

// MARK: - 配置

/// 目标计划·小·自选的配置
struct WSGoalPlanSelectedConfiguration: Codable {
    
    /// 用户选择的目标计划标识
    var planIdentifier: String?
}

// MARK: - 配置界面

/// 目标计划·小·自选的配置界面，用于选择要展示的目标计划
class WSGoalPlanSelectedConfigViewController: WSPluginConfigViewController,
                                              WSGoalPlanBindViewControllerDelegate {
    
    /// 当前配置
    private lazy var config: WSGoalPlanSelectedConfiguration = {
        return configuration(as: WSGoalPlanSelectedConfiguration.self)
            ?? WSGoalPlanSelectedConfiguration()
    }()
    
    /// 目标计划选择列表
    private lazy var bindViewController: WSGoalPlanBindViewController = {
        let viewController = WSGoalPlanBindViewController(selectedIdentifier: config.planIdentifier)
        viewController.delegate = self
        return viewController
    }()
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Select Goal")
        contentViewController = bindViewController
    }
    
    // MARK: - 选择
    /// 保存用户选择的目标计划
    private func selectGoalPlan(_ goalPlan: GoalPlan) {
        var config = self.config
        config.planIdentifier = goalPlan.identifier
        self.config = config
        updateConfiguration(config)
        
        if let presentingVC = presentingViewController {
            presentingVC.dismiss(animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - WSGoalPlanBindViewControllerDelegate
    func goalPlanBindViewController(_ viewController: WSGoalPlanBindViewController, didSelect goalPlan: GoalPlan) {
        selectGoalPlan(goalPlan)
    }
}
