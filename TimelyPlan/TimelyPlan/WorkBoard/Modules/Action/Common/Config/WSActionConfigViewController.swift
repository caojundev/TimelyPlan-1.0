//
//  WSActionConfigViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/13.
//

import Foundation
import UIKit

// MARK: - 配置界面

/// 动作组件的配置界面，各尺寸共用。
///
/// 展示动作列表；添加、编辑、删除与排序均由列表完成，
/// 本界面只负责把最新的动作写入配置。
class WSActionConfigViewController: WSPluginConfigViewController {

    /// 当前配置
    private lazy var config: WSActionConfiguration = {
        return configuration(as: WSActionConfiguration.self) ?? WSActionConfiguration()
    }()

    /// 动作列表
    private lazy var listViewController: WSActionListViewController = {
        let viewController = WSActionListViewController(actions: config.actions ?? [])
        viewController.didChangeActions = { [weak self] actions in
            self?.saveActions(actions)
        }

        return viewController
    }()

    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = resGetString("Actions")
        contentViewController = listViewController
    }

    // MARK: - 配置保存
    /// 记录最新的动作，配置在点击完成时才回调外部保存
    private func saveActions(_ actions: [WSActionItem]) {
        var config = self.config
        config.actions = actions
        self.config = config
        updateConfiguration(config)
    }
}
