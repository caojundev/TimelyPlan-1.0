//
//  WSCountdownSmallSelectedConfigViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/19.
//

import Foundation
import UIKit

/// 倒数日·小·自选的配置界面，用于选择要展示的倒数日事件。
///
/// 事项选择复用任务绑定中的 `CountdownEventBindViewController`：
/// 列表样式、选中勾选、数据变更刷新与占位视图都与「绑定倒数日」保持一致。
/// 搜索交互参考 `TaskBindViewController`：搜索时切换到搜索结果视图，结束后回到列表。
class WSCountdownSmallSelectedConfigViewController: WSPluginConfigViewController,
                                                  TaskBindViewControllerDelegate,
                                                  UISearchControllerDelegate {
    
    /// 当前配置
    private lazy var config: WSCountdownSelectedConfiguration = {
        return configuration(as: WSCountdownSelectedConfiguration.self)
            ?? WSCountdownSelectedConfiguration()
    }()
    
    /// 已选中的事项特征值。用于列表与搜索结果展示选中勾选
    private lazy var selectedFeature: TaskFeature? = {
        guard let eventIdentifier = config.eventIdentifier,
              let event = CountdownRepository.getEvent(withIdentifier: eventIdentifier) else {
            return nil
        }
        
        return event.feature
    }()
    
    /// 倒数日事项选择列表
    private lazy var bindViewController: CountdownEventBindViewController = {
        let viewController = CountdownEventBindViewController(selectedFeature: selectedFeature)
        viewController.delegate = self
        return viewController
    }()
    
    /// 搜索结果视图控制器。仅在搜索展示期间存在
    private var searchResultViewController: TaskBindSearchResultViewController?
    
    /// 搜索控制器
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        let searchBar = searchController.searchBar
        searchBar.placeholder = resGetString("Search Countdown")
        searchBar.tintColor = Color(light: 0x1F212C, dark: 0xD1DAFF)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.delegate = self
        return searchController
    }()
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Select Countdown")
        contentViewController = bindViewController
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    // MARK: - 选择
    /// 保存用户选择的倒数日事项
    private func selectEvent(_ event: CountdownEvent) {
        var config = self.config
        config.eventIdentifier = event.identifier
        self.config = config
        updateConfiguration(config)
        
        if let presentingVC = presentingViewController {
            presentingVC.dismiss(animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - TaskBindViewControllerDelegate
    func taskBindViewController(_ viewController: UIViewController, didSelectTask task: TaskRepresentable) {
        guard let event = task as? CountdownEvent else {
            return
        }
        
        selectEvent(event)
    }
    
    // MARK: - UISearchControllerDelegate
    func willPresentSearchController(_ searchController: UISearchController) {
        /// 只搜索倒数日事项，与事项绑定保持一致
        let viewController = TaskBindSearchResultViewController(selectedTaskFeature: selectedFeature,
                                                                allowTypes: [.countdown])
        viewController.delegate = self
        searchResultViewController = viewController
        
        searchController.searchResultsUpdater = viewController
        contentViewController = viewController
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        searchResultViewController = nil
        contentViewController = bindViewController
    }
}
