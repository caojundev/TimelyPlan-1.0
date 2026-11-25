//
//  WSSeparatorConfigViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/11.
//

import Foundation
import UIKit

// MARK: - 配置界面

/// 分割线组件的配置界面，用于选择分割线样式
class WSSeparatorConfigViewController: WSPluginConfigViewController {

    /// 当前配置
    private lazy var config: WSSeparatorConfiguration = {
        return configuration(as: WSSeparatorConfiguration.self) ?? WSSeparatorConfiguration()
    }()

    /// 样式选择列表
    private lazy var selectionViewController: WSSeparatorStyleSelectionViewController = {
        let viewController = WSSeparatorStyleSelectionViewController(selectedStyle: config.style ?? .solid)
        viewController.didChangeSelection = { [weak self] style in
            guard let self = self else {
                return
            }

            var config = self.config
            config.style = style
            self.config = config
            self.updateConfiguration(config)
        }
        return viewController
    }()

    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Separator")
        contentViewController = selectionViewController
    }
}

// MARK: - 样式选择

/// 分割线样式选择列表。点击即选中，选择结果实时回调。
class WSSeparatorStyleSelectionViewController: TPViewController, TPGroupTableViewDelegate {

    /// 选择变化回调
    var didChangeSelection: ((WSSeparatorStyle) -> Void)?

    /// 当前选中的样式
    private(set) var selectedStyle: WSSeparatorStyle

    /// 分组标识
    private let groupIdentifier = "WSSeparatorStyleSelectionGroup"

    /// 单元格样式
    private lazy var cellStyle: TPTableCellStyle = {
        let style = TPTableCellStyle()
        style.backgroundColor = .secondarySystemGroupedBackground
        style.selectedBackgroundColor = .tertiarySystemFill
        return style
    }()

    /// 样式列表视图
    private lazy var listView: TPGroupTableView = {
        let view = TPGroupTableView(frame: .zero, style: .insetGrouped)
        view.delegate = self
        return view
    }()

    /// 可选样式，顺序即列表展示顺序
    private let styles = WSSeparatorStyle.allCases

    init(selectedStyle: WSSeparatorStyle) {
        self.selectedStyle = selectedStyle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGroupedBackground
        view.addSubview(listView)

        let group = WSSeparatorStyleGroup(identifier: groupIdentifier)
        group.styleItems = styles.map { WSSeparatorStyleItem(style: $0) }
        listView.groups = [group]
        listView.reloadData()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        listView.frame = view.bounds
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    // MARK: - TPGroupTableViewDelegate
    func groupTableView(_ tableView: TPGroupTableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5.0
    }

    func groupTableView(_ tableView: TPGroupTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    func groupTableView(_ tableView: TPGroupTableView, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return WSSeparatorStyleSelectCell.self
    }

    func groupTableView(_ tableView: TPGroupTableView, didDequeCell cell: UITableViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? WSSeparatorStyleSelectCell else {
            return
        }

        cell.style = cellStyle
        cell.separatorStyle = style(at: indexPath)
    }

    func groupTableView(_ tableView: TPGroupTableView, shouldShowCheckmarkForRowAt indexPath: IndexPath) -> Bool {
        return style(at: indexPath) == selectedStyle
    }

    func groupTableView(_ tableView: TPGroupTableView, didSelectRowAt indexPath: IndexPath) {
        guard let style = style(at: indexPath), style != selectedStyle else {
            return
        }

        selectedStyle = style
        TPImpactFeedback.impactWithSoftStyle()
        tableView.updateCheckmarks()
        didChangeSelection?(style)
    }

    // MARK: - 数据
    /// 索引处对应的样式
    private func style(at indexPath: IndexPath) -> WSSeparatorStyle? {
        return (listView.item(at: indexPath) as? WSSeparatorStyleItem)?.style
    }
}
