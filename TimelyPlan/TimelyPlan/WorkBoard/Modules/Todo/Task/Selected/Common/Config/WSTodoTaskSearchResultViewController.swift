//
//  WSTodoTaskSearchResultViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/5.
//

import Foundation
import UIKit

// MARK: - 搜索结果

/// 自选待办任务的搜索结果。
///
/// 复用待办任务的搜索分组与单元格，多选规则与任务列表一致；
/// 选择状态由外部共享，搜索期间的选择变化通过回调同步给配置界面。
class WSTodoTaskSearchResultViewController: TPTableSectionsViewController,
                                            UISearchResultsUpdating,
                                            TPTableSectionControllerDelegate {

    /// 选择变化回调，按选择顺序返回任务标识
    var didChangeSelection: (([String]) -> Void)?

    /// 选择状态，与任务列表共用
    private let selection: WSTodoTaskSelectionState

    /// 待办任务搜索结果
    private lazy var resultSectionController: TodoTaskBindSearchResultSectionController = {
        let sectionController = TodoTaskBindSearchResultSectionController()
        sectionController.delegate = self
        return sectionController
    }()

    init(selection: WSTodoTaskSelectionState) {
        self.selection = selection
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()

        let provider = TPDefaultPlaceholderProvider()
        provider.emptyImage = resGetImage("placeholder_noSearchResult_80")
        wrapperView.placeholderProvider = provider
        wrapperView.shouldShowPlaceholder = { [weak self] in
            guard let self = self else {
                return false
            }

            return !self.adapter.hasItem
        }

        wrapperView.isKeyboardAdjusterEnabled = true
        wrapperView.keyboardDismissMode = .onDrag
        sectionControllers = [resultSectionController]
        reloadData()
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        guard let sectionController = resultSectionController as? UISearchResultsUpdating else {
            return
        }

        sectionController.updateSearchResults(for: searchController)
    }

    // MARK: - TPTableSectionControllerDelegate
    func tableSectionController(_ sectionController: TPTableBaseSectionController,
                                didSelectRowAt index: Int) {
        guard let task = sectionController.item(at: index) as? TodoTask,
              selection.toggle(task.identifier) else {
            return
        }

        adapter.updateCheckmarks()
        didChangeSelection?(selection.identifiers)
    }

    func tableSectionController(_ sectionController: TPTableBaseSectionController,
                                shouldShowCheckmarkForRowAt index: Int) -> Bool {
        guard let task = sectionController.item(at: index) as? TodoTask else {
            return false
        }

        return selection.contains(task.identifier)
    }
}
