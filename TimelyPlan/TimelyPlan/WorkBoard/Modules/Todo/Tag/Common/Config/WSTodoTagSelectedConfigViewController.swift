//
//  WSTodoTagSelectedConfigViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 配置界面

/// 待办标签组件的配置界面，用于多选要展示的标签
class WSTodoTagSelectedConfigViewController: WSPluginConfigViewController {
    
    /// 最多可选择的标签数量
    private let maximumSelectionCount: Int
    
    /// 当前配置
    private lazy var config: WSTodoTagSelectedTagsConfiguration = {
        return configuration(as: WSTodoTagSelectedTagsConfiguration.self)
            ?? WSTodoTagSelectedTagsConfiguration()
    }()
    
    /// 标签多选列表
    private lazy var selectionViewController: WSTodoTagMultiSelectionViewController = {
        let viewController = WSTodoTagMultiSelectionViewController(selectedIdentifiers: config.tagIdentifiers,
                                                                  maximumSelectionCount: maximumSelectionCount)
        viewController.didChangeSelection = { [weak self] identifiers in
            self?.updateSelectedTags(identifiers)
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
        self.title = resGetString("Select Tags")
        contentViewController = selectionViewController
    }
    
    // MARK: - 选择
    /// 保存用户选择的标签
    private func updateSelectedTags(_ identifiers: [String]) {
        var config = self.config
        config.tagIdentifiers = identifiers
        self.config = config
        updateConfiguration(config)
    }
}
