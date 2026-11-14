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
/// 默认展示已配置的动作列表，右上角添加按钮弹出动作编辑界面；
/// 点击列表项可再次编辑，左滑可编辑或删除，长按可拖动调整顺序。
class WSActionConfigViewController: WSPluginConfigViewController {

    /// 当前配置
    private lazy var config: WSActionConfiguration = {
        return configuration(as: WSActionConfiguration.self) ?? WSActionConfiguration()
    }()

    /// 动作列表
    private lazy var listViewController: WSActionListViewController = {
        let viewController = WSActionListViewController(actions: config.actions ?? [])
        viewController.didSelectAction = { [weak self] index in
            self?.editAction(at: index)
        }

        viewController.didChangeActions = { [weak self] actions in
            /// 删除与排序由列表自行完成，这里只记录配置，避免重复刷新列表
            self?.saveActions(actions, reloadList: false)
        }

        return viewController
    }()

    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = resGetString("Actions")
        navigationItem.rightBarButtonItem = addBarButtonItem
        contentViewController = listViewController
    }

    // MARK: - 添加
    override func clickAdd() {
        super.clickAdd()
        editAction(at: nil)
    }

    // MARK: - 编辑
    /// 编辑指定位置的动作，index 为 nil 时新建
    private func editAction(at index: Int?) {
        let actions = config.actions ?? []
        let viewController = WSActionItemEditViewController(actionItem: index.flatMap { actions[safe: $0] })
        viewController.didEndEditing = { [weak self] action in
            self?.apply(action, at: index)
        }

        viewController.didDeleteAction = { [weak self] in
            guard let index = index else {
                return
            }

            self?.listViewController.deleteAction(at: index)
        }

        viewController.popoverShowAsNavigationRoot()
    }

    /// 保存新建或编辑后的动作
    private func apply(_ action: WSActionItem, at index: Int?) {
        var actions = config.actions ?? []
        if let index = index, index < actions.count {
            actions[index] = action
        } else {
            actions.append(action)
        }

        updateActions(actions)
    }

    // MARK: - 配置保存
    /// 更新配置与列表，配置在点击完成时才回调外部保存
    private func updateActions(_ actions: [WSActionItem]) {
        saveActions(actions, reloadList: true)
    }

    /// 保存动作。`reloadList` 为 false 时不刷新列表，用于排序后保持当前行位置
    private func saveActions(_ actions: [WSActionItem], reloadList: Bool) {
        var config = self.config
        config.actions = actions
        self.config = config
        updateConfiguration(config)

        if reloadList {
            listViewController.update(actions: actions)
        }
    }
}
