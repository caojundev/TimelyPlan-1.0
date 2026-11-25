//
//  WSTodoTagSingleSelectionConfigViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 配置界面

/// 待办标签单选组件的配置界面，用于选择要展示的标签。
class WSTodoTagSingleSelectionConfigViewController: WSPluginConfigViewController {
    
    /// 当前配置
    private lazy var config: WSTodoTagSelectedTagConfiguration = {
        return configuration(as: WSTodoTagSelectedTagConfiguration.self)
            ?? WSTodoTagSelectedTagConfiguration()
    }()
    
    /// 标签单选列表
    private lazy var selectionViewController: WSTodoTagSingleSelectionViewController = {
        let viewController = WSTodoTagSingleSelectionViewController(selectedIdentifier: config.tagIdentifier)
        viewController.didChangeSelection = { [weak self] identifier in
            self?.updateSelectedTag(identifier)
        }
        return viewController
    }()
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Select Tag")
        contentViewController = selectionViewController
    }
    
    // MARK: - 选择
    /// 记录用户选择的标签，点击完成时保存
    private func updateSelectedTag(_ identifier: String?) {
        var config = self.config
        config.tagIdentifier = identifier
        self.config = config
        updateConfiguration(config)
    }
}
