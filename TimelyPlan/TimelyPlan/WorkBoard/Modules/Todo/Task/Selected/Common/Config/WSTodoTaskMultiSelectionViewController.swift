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
/// 复用待办的任务选择视图按清单分组展示全部未完成任务，点击切换选中状态，超出上限的选择会被忽略；
/// 底部展示已选数量与上限，选择顺序即组件内的展示顺序。
class WSTodoTaskMultiSelectionViewController: TPViewController,
                                             TodoTaskSelectViewDelegate {

    /// 选择变化回调，按选择顺序返回任务标识
    var didChangeSelection: (([String]) -> Void)?

    /// 已选任务标识，保持选择顺序
    private(set) var selectedIdentifiers: [String]

    /// 最多可选择的任务数量
    private let maximumSelectionCount: Int

    /// 选中数量标签高度
    private let selectionCountLabelHeight: CGFloat = 36.0

    /// 任务分组与加载状态。已完成任务同样可选，与组件的展示保持一致
    private let viewModel = TodoTaskSelectViewModel(showCompleted: true)

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

    init(selectedIdentifiers: [String], maximumSelectionCount: Int) {
        self.selectedIdentifiers = selectedIdentifiers
        self.maximumSelectionCount = max(maximumSelectionCount, 1)
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

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    // MARK: - 数据
    /// 任务或分组变化后刷新列表
    private func updateGroups() {
        selectView.groups = viewModel.groups
        selectView.reloadData()

        filterSelection()
        updateSelectionCount()
    }

    /// 已删除或已完成的任务不再保留在选择列表中
    private func filterSelection() {
        let validIdentifiers = Set((viewModel.tasks ?? []).map { $0.identifier })
        guard !validIdentifiers.isEmpty else {
            return
        }

        let filteredIdentifiers = selectedIdentifiers.filter { validIdentifiers.contains($0) }
        guard filteredIdentifiers != selectedIdentifiers else {
            return
        }

        selectedIdentifiers = filteredIdentifiers
        didChangeSelection?(filteredIdentifiers)
    }

    /// 更新已选数量与上限提示
    private func updateSelectionCount() {
        let countText = String(format: resGetString("%ld selected"), selectedIdentifiers.count)
        let maximumText = String(format: resGetString("Up to %ld"), maximumSelectionCount)
        selectionCountLabel.text = "\(countText) · \(maximumText)"
    }

    // MARK: - TodoTaskSelectViewDelegate
    /// 点击任务：切换选中状态
    func todoTaskSelectView(_ view: TodoTaskSelectView, didSelectTask task: TodoTask) {
        if let index = selectedIdentifiers.firstIndex(of: task.identifier) {
            selectedIdentifiers.remove(at: index)
            TPImpactFeedback.impactWithSoftStyle()
        } else {
            /// 超出上限时不再加入，给出重一点的反馈
            guard selectedIdentifiers.count < maximumSelectionCount else {
                TPImpactFeedback.impactWithRigidStyle()
                return
            }

            selectedIdentifiers.append(task.identifier)
            TPImpactFeedback.impactWithSoftStyle()
        }

        updateSelectionCount()
        didChangeSelection?(selectedIdentifiers)
    }

    func todoTaskSelectView(_ view: TodoTaskSelectView, isSelectedTask task: TodoTask) -> Bool {
        return selectedIdentifiers.contains(task.identifier)
    }
}
