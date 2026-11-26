//
//  WSTodoListSelectedConfigViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 配置界面

/// 待办清单组件的配置界面，用于多选要展示的清单
class WSTodoListSelectedConfigViewController: WSPluginConfigViewController {
    
    /// 最多可选择的清单数量
    private let maximumSelectionCount: Int
    
    /// 当前配置
    private lazy var config: WSTodoListSelectedListsConfiguration = {
        return configuration(as: WSTodoListSelectedListsConfiguration.self)
            ?? WSTodoListSelectedListsConfiguration()
    }()
    
    /// 清单多选列表
    private lazy var selectionViewController: WSTodoListMultiSelectionViewController = {
        let viewController = WSTodoListMultiSelectionViewController(selectedIdentifiers: config.listIdentifiers,
                                                                   maximumSelectionCount: maximumSelectionCount)
        viewController.didChangeSelection = { [weak self] identifiers in
            self?.updateSelectedLists(identifiers)
        }
        return viewController
    }()
    
    init(plugin: WSPlugin, maximumSelectionCount: Int) {
        self.maximumSelectionCount = maximumSelectionCount
        super.init(plugin: plugin)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Select Lists")
        contentViewController = selectionViewController
    }
    
    // MARK: - 选择
    /// 记录用户选择的清单，点击完成时保存
    private func updateSelectedLists(_ identifiers: [String]) {
        var config = self.config
        config.listIdentifiers = identifiers
        self.config = config
        updateConfiguration(config)
    }
}
