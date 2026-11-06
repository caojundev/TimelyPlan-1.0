//
//  WSTodoFilterSelectedConfigViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 配置界面

/// 待办过滤器组件的配置界面，用于多选要展示的过滤器
class WSTodoFilterSelectedConfigViewController: WSPluginConfigViewController {
    
    /// 最多可选择的过滤器数量
    private let maximumSelectionCount: Int
    
    /// 当前配置
    private lazy var config: WSTodoFilterSelectedFiltersConfiguration = {
        return configuration(as: WSTodoFilterSelectedFiltersConfiguration.self)
            ?? WSTodoFilterSelectedFiltersConfiguration()
    }()
    
    /// 过滤器多选列表
    private lazy var selectionViewController: WSTodoFilterMultiSelectionViewController = {
        let viewController = WSTodoFilterMultiSelectionViewController(selectedIdentifiers: config.filterIdentifiers,
                                                                     maximumSelectionCount: maximumSelectionCount)
        viewController.didChangeSelection = { [weak self] identifiers in
            self?.updateSelectedFilters(identifiers)
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
        self.title = resGetString("Select Filters")
        contentViewController = selectionViewController
    }
    
    // MARK: - 选择
    /// 记录用户选择的过滤器，点击完成时保存
    private func updateSelectedFilters(_ identifiers: [String]) {
        var config = self.config
        config.filterIdentifiers = identifiers
        self.config = config
        updateConfiguration(config)
    }
}
