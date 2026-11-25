//
//  WSTodoTaskMultiSelectionViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/5.
//

import Foundation
import UIKit

// MARK: - 多选列表

/// 待办任务多选列表。
///
/// 复用待办的任务选择视图按清单分组展示全部任务，点击切换选中状态，超出上限的选择会被忽略；
/// 底部展示已选数量与上限，选择顺序即组件内的展示顺序。
class WSTodoTaskMultiSelectionViewController: TPViewController,
                                             TodoTaskSelectViewDelegate {

    /// 选择变化回调，按选择顺序返回任务标识
    var didChangeSelection: (([String]) -> Void)?

    /// 选择状态，与搜索结果共用
    let selection: WSTodoTaskSelectionState

    /// 已选任务标识，保持选择顺序
    var selectedIdentifiers: [String] {
        return selection.identifiers
    }

    /// 选中数量标签高度
    private let selectionCountLabelHeight: CGFloat = 36.0

    /// 更多菜单按钮
    private lazy var moreBarButtonItem: WSTodoTaskMoreBarButtonItem = {
        let item = WSTodoTaskMoreBarButtonItem()
        item.showCompleted = viewModel.showCompleted
        item.didSelectType = { [weak self] type in
            self?.didSelectMoreMenuType(type)
        }
        return item
    }()

    /// 任务分组与加载状态。默认不包含已完成任务，由更多菜单控制
    private let viewModel = TodoTaskSelectViewModel(showCompleted: false)

    /// 选中数量标签
    private lazy var selectionCountLabel: TPLabel = {
        let label = TPLabel()
        label.font = .boldSystemFont(ofSize: 11.0)
        label.numberOfLines = 2
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.backgroundColor = themeBackgroundColor
        label.edgeInsets = UIEdgeInsets(horizontal: 16.0, top: 4.0)
        return label
    }()

    /// 任务选择视图
    private lazy var selectView: TodoTaskSelectView = {
        let view = TodoTaskSelectView(frame: .zero)
        view.placeholderProvider = viewModel.placeholderProvider
        view.showDetail = true
        view.delegate = self
        return view
    }()

    init(selection: WSTodoTaskSelectionState) {
        self.selection = selection
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(selectView)
        view.addSubview(selectionCountLabel)
        selectionCountLabel.addSeparator(position: .top)

        updateSelectionCount()

        viewModel.onGroupsChanged = { [weak self] in
            self?.updateGroups()
        }
        viewModel.loadGroups()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        /// 选中数量标签位于底部，列表相应缩短
        var listFrame = view.bounds
        listFrame.size.height = max(listFrame.height - selectionCountLabelHeight, 0.0)
        selectView.frame = listFrame
        selectionCountLabel.frame = CGRect(x: 0.0,
                                           y: listFrame.maxY,
                                           width: view.width,
                                           height: selectionCountLabelHeight)
    }

    /// 作为配置界面的内容视图时，把更多菜单放到父级导航栏右侧
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        parent?.navigationItem.rightBarButtonItem = moreBarButtonItem
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    // MARK: - 更多菜单
    private func didSelectMoreMenuType(_ type: WSTodoTaskMoreMenuType) {
        switch type {
        case .showCompleted:
            updateShowCompleted(!viewModel.showCompleted)
        }
    }

    /// 切换是否获取已完成任务。菜单状态不持久化，仅对当前配置界面生效
    private func updateShowCompleted(_ showCompleted: Bool) {
        moreBarButtonItem.showCompleted = showCompleted
        viewModel.setShowCompleted(showCompleted)
    }

    // MARK: - 数据
    /// 任务或分组变化后刷新列表
    private func updateGroups() {
        selectView.groups = viewModel.groups
        selectView.reloadData()

        filterSelection()
        updateSelectionCount()
    }

    /// 已删除的任务不再保留在选择列表中。已完成任务是否展示由菜单控制，不影响已选状态
    private func filterSelection() {
        let filteredIdentifiers = selection.identifiers.filter { identifier in
            guard let task = TodoRepository.getTask(with: identifier) else {
                return false
            }

            return !task.isRemoved
        }
        guard filteredIdentifiers != selection.identifiers else {
            return
        }

        selection.update(filteredIdentifiers)
        updateSelectionCount()
        didChangeSelection?(filteredIdentifiers)
    }

    /// 更新已选数量与上限提示
    private func updateSelectionCount() {
        let countText = String(format: resGetString("%ld selected"), selection.identifiers.count)
        let maximumText = String(format: resGetString("Up to %ld"), selection.maximumSelectionCount)
        selectionCountLabel.text = "\(countText) · \(maximumText)"
    }

    // MARK: - 选择
    /// 同步搜索结果中的选择变化，保持已选数量与勾选状态一致
    func updateSelectedIdentifiers(_ identifiers: [String]) {
        selection.update(identifiers)
        updateSelectionCount()
        selectView.reloadData()
    }

    // MARK: - TodoTaskSelectViewDelegate
    /// 点击任务：切换选中状态
    func todoTaskSelectView(_ view: TodoTaskSelectView, didSelectTask task: TodoTask) {
        guard selection.toggle(task.identifier) else {
            return
        }

        updateSelectionCount()
        didChangeSelection?(selection.identifiers)
    }

    func todoTaskSelectView(_ view: TodoTaskSelectView, isSelectedTask task: TodoTask) -> Bool {
        return selection.contains(task.identifier)
    }
}
