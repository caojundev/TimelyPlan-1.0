//
//  WSTodoFilterSingleSelectionConfigViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 配置界面

/// 待办过滤器单选组件的配置界面，用于选择要展示的过滤器。
class WSTodoFilterSingleSelectionConfigViewController: WSPluginConfigViewController {
    
    /// 当前配置
    private lazy var config: WSTodoFilterSelectedFilterConfiguration = {
        return configuration(as: WSTodoFilterSelectedFilterConfiguration.self)
            ?? WSTodoFilterSelectedFilterConfiguration()
    }()
    
    /// 过滤器单选列表
    private lazy var selectionViewController: WSTodoFilterSingleSelectionViewController = {
        let viewController = WSTodoFilterSingleSelectionViewController(selectedIdentifier: config.filterIdentifier)
        viewController.didChangeSelection = { [weak self] identifier in
            self?.updateSelectedFilter(identifier)
        }
        return viewController
    }()
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Select Filter")
        contentViewController = selectionViewController
    }
    
    // MARK: - 选择
    /// 记录用户选择的过滤器，点击完成时保存
    private func updateSelectedFilter(_ identifier: String?) {
        var config = self.config
        config.filterIdentifier = identifier
        self.config = config
        updateConfiguration(config)
    }
}
