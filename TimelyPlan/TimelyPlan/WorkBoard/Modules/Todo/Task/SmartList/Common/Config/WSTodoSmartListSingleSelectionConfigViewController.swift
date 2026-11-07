//
//  WSTodoSmartListSingleSelectionConfigViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation
import UIKit

// MARK: - 配置界面

/// 待办智能清单单选组件的配置界面，用于选择要展示的智能清单。
class WSTodoSmartListSingleSelectionConfigViewController: WSPluginConfigViewController {
    
    /// 当前配置
    private lazy var config: WSTodoSmartListSelectedSmartListConfiguration = {
        return configuration(as: WSTodoSmartListSelectedSmartListConfiguration.self)
            ?? WSTodoSmartListSelectedSmartListConfiguration()
    }()
    
    /// 智能清单单选列表
    private lazy var selectionViewController: WSTodoSmartListSingleSelectionViewController = {
        let viewController = WSTodoSmartListSingleSelectionViewController(selectedIdentifier: config.smartListIdentifier)
        viewController.didChangeSelection = { [weak self] identifier in
            self?.updateSelectedSmartList(identifier)
        }
        return viewController
    }()
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Select Smart List")
        contentViewController = selectionViewController
    }
    
    // MARK: - 选择
    /// 记录用户选择的智能清单，点击完成时保存
    private func updateSelectedSmartList(_ identifier: String?) {
        var config = self.config
        config.smartListIdentifier = identifier
        self.config = config
        updateConfiguration(config)
    }
}
