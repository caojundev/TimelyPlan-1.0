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
class WSTodoTaskSelectedConfigViewController: WSPluginConfigViewController,
                                              UISearchControllerDelegate {

    /// 最多可选择的任务数量
    private let maximumSelectionCount: Int

    /// 当前配置
    private lazy var config: WSTodoTaskSelectedTasksConfiguration = {
        return configuration(as: WSTodoTaskSelectedTasksConfiguration.self)
            ?? WSTodoTaskSelectedTasksConfiguration()
    }()

    /// 选择状态，任务列表与搜索结果共用
    private lazy var selection: WSTodoTaskSelectionState = {
        return WSTodoTaskSelectionState(identifiers: config.taskIdentifiers,
                                        maximumSelectionCount: maximumSelectionCount)
    }()

    /// 搜索控制器
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        let searchBar = searchController.searchBar
        searchBar.placeholder = resGetString("Search Task")
        searchBar.tintColor = Color(light: 0x1F212C, dark: 0xD1DAFF)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.delegate = self
        return searchController
    }()

    /// 待办任务多选列表
    private lazy var selectionViewController: WSTodoTaskMultiSelectionViewController = {
        let viewController = WSTodoTaskMultiSelectionViewController(selection: selection)
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

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        contentViewController = selectionViewController
    }

    // MARK: - 选择
    /// 记录用户选择的待办任务。只在配置界面内生效，点击完成时才保存
    private func updateSelectedTasks(_ identifiers: [String]) {
        var config = self.config
        config.taskIdentifiers = identifiers
        self.config = config
        updateConfiguration(config)
    }

    // MARK: - UISearchControllerDelegate
    /// 搜索时切换到搜索结果，多选状态与任务列表共用
    func willPresentSearchController(_ searchController: UISearchController) {
        let resultViewController = WSTodoTaskSearchResultViewController(selection: selection)
        resultViewController.didChangeSelection = { [weak self] identifiers in
            guard let self = self else {
                return
            }

            self.updateSelectedTasks(identifiers)
            self.selectionViewController.updateSelectedIdentifiers(identifiers)
        }

        searchController.searchResultsUpdater = resultViewController
        contentViewController = resultViewController
    }

    /// 结束搜索后恢复任务列表
    func willDismissSearchController(_ searchController: UISearchController) {
        contentViewController = selectionViewController
    }
}
