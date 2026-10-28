//
//  WSGoalPlanMediumPlanRingsConfigViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/28.
//

import Foundation
import UIKit

// MARK: - 配置界面

/// 目标·中·自选三环的配置界面，用于多选要展示的目标计划
class WSGoalPlanMediumPlanRingsConfigViewController: WSPluginConfigViewController {
    
    /// 当前配置
    private lazy var config: WSGoalPlanSelectedPlansConfiguration = {
        return configuration(as: WSGoalPlanSelectedPlansConfiguration.self)
            ?? WSGoalPlanSelectedPlansConfiguration()
    }()
    
    /// 目标计划多选列表
    private lazy var selectionViewController: WSGoalPlanMultiSelectionViewController = {
        let viewController = WSGoalPlanMultiSelectionViewController(selectedIdentifiers: config.planIdentifiers,
                                                                   maximumSelectionCount: WSGoalPlanItemCount.mediumPlanRings)
        viewController.didChangeSelection = { [weak self] identifiers in
            self?.updateSelectedPlans(identifiers)
        }
        return viewController
    }()
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Select Goal")
        contentViewController = selectionViewController
    }
    
    // MARK: - 选择
    /// 保存用户选择的目标计划
    private func updateSelectedPlans(_ identifiers: [String]) {
        var config = self.config
        config.planIdentifiers = identifiers
        self.config = config
        updateConfiguration(config)
    }
}
