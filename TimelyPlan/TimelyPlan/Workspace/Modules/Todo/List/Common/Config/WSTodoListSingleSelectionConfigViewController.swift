//
//  WSTodoListSingleSelectionConfigViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 配置界面

/// 待办清单单选组件的配置界面，用于选择要展示的清单。
class WSTodoListSingleSelectionConfigViewController: WSPluginConfigViewController {
    
    /// 当前配置
    private lazy var config: WSTodoListSelectedListConfiguration = {
        return configuration(as: WSTodoListSelectedListConfiguration.self)
            ?? WSTodoListSelectedListConfiguration()
    }()
    
    /// 清单单选列表
    private lazy var selectionViewController: WSTodoListSingleSelectionViewController = {
        let viewController = WSTodoListSingleSelectionViewController(selectedIdentifier: config.listIdentifier)
        viewController.didChangeSelection = { [weak self] identifier in
            self?.updateSelectedList(identifier)
        }
        return viewController
    }()
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Select List")
        contentViewController = selectionViewController
    }
    
    // MARK: - 选择
    /// 记录用户选择的清单，点击完成时保存
    private func updateSelectedList(_ identifier: String?) {
        var config = self.config
        config.listIdentifier = identifier
        self.config = config
        updateConfiguration(config)
    }
}
