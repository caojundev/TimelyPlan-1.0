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
/// 复用待办任务的搜索选项与单元格，多选规则与任务列表一致；
/// 选择状态由外部共享，搜索期间的选择变化通过回调同步给配置界面。
class WSTodoTaskSearchResultViewController: TPTableSectionsViewController,
                                            UISearchResultsUpdating,
                                            TPTableSectionControllerDelegate {

    /// 选择变化回调，按选择顺序返回任务标识
    var didChangeSelection: (([String]) -> Void)?

    /// 搜索选项高度
    private let optionsViewHeight: CGFloat = 40.0

    /// 选择状态，与任务列表共用
    private let selection: WSTodoTaskSelectionState

    /// 待办任务搜索结果
    private lazy var resultSectionController: WSTodoTaskSearchResultSectionController = {
        let sectionController = WSTodoTaskSearchResultSectionController()
        sectionController.delegate = self
        return sectionController
    }()

    /// 搜索选项：已完成、步骤、备注。不含过滤器
    private lazy var optionsView: TodoSearchResultOptionsView = {
        let frame = CGRect(x: 0.0, y: 0.0, width: view.width, height: optionsViewHeight)
        let view = TodoSearchResultOptionsView(frame: frame,
                                               options: resultSectionController.options,
                                               showsFilter: false)
        view.optionsChanged = { [weak self] options in
            self?.updateSearchOptions(options)
        }
        return view
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
        view.addSubview(optionsView)
        sectionControllers = [resultSectionController]
        reloadData()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        optionsView.frame = CGRect(x: 0.0,
                                   y: 0.0,
                                   width: view.width,
                                   height: optionsViewHeight)
    }

    /// 列表在搜索选项下方展示
    override func tableViewFrame() -> CGRect {
        var frame = super.tableViewFrame()
        frame.origin.y = optionsViewHeight
        frame.size.height = max(frame.height - optionsViewHeight, 0.0)
        return frame
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    // MARK: - 搜索选项
    /// 选项变化后按新的条件重新搜索
    private func updateSearchOptions(_ options: TodoSearchOptions) {
        resultSectionController.options = options
        resultSectionController.refreshSearchResults()
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

// MARK: - 搜索分组

/// 自选任务的搜索分组。支持按搜索选项重新查询，默认包含已完成任务与步骤、备注
class WSTodoTaskSearchResultSectionController: TodoTaskBindSearchResultSectionController {

    /// 搜索选项
    var options = TodoSearchOptions(showCompleted: true,
                                    searchStep: true,
                                    searchNote: true,
                                    filterRule: nil)

    override func fetchResults(containText text: String,
                               completion: @escaping ([ListDiffable]?) -> Void) {
        TodoRepository.searchTasks(matching: text, options: options, completion: completion)
    }
}
