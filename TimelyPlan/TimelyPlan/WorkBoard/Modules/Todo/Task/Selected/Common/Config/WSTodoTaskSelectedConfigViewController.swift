//
//  WSTodoTaskSelectedConfigViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/5.
//

import Foundation
import UIKit

// MARK: - 配置界面

/// 待办自选任务组件的配置界面，用于多选要展示的任务
class WSTodoTaskSelectedConfigViewController: WSPluginConfigViewController {

    /// 最多可选择的任务数量
    private let maximumSelectionCount: Int

    /// 当前配置
    private lazy var config: WSTodoTaskSelectedTasksConfiguration = {
        return configuration(as: WSTodoTaskSelectedTasksConfiguration.self)
            ?? WSTodoTaskSelectedTasksConfiguration()
    }()

    /// 待办任务多选列表
    private lazy var selectionViewController: WSTodoTaskMultiSelectionViewController = {
        let viewController = WSTodoTaskMultiSelectionViewController(selectedIdentifiers: config.taskIdentifiers,
                                                                   maximumSelectionCount: maximumSelectionCount)
        viewController.didChangeSelection = { [weak self] identifiers in
            self?.updateSelectedTasks(identifiers)
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
        self.title = resGetString("Select Tasks")
        contentViewController = selectionViewController
    }

    // MARK: - 选择
    /// 保存用户选择的待办任务
    private func updateSelectedTasks(_ identifiers: [String]) {
        var config = self.config
        config.taskIdentifiers = identifiers
        self.config = config
        updateConfiguration(config)
    }
}
