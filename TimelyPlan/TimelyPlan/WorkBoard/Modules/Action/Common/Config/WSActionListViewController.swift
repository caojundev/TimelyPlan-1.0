//
//  WSActionListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/14.
//

import Foundation
import UIKit

// MARK: - 分组

/// 动作配置列表的分组
class WSActionGroup: NSObject, GroupRepresentable {

    /// 分组唯一标识
    let identifier: String

    /// 分组内动作条目
    var actionItems: [WSActionListItem]?

    init(identifier: String) {
        self.identifier = identifier
    }

    // MARK: - GroupRepresentable
    var items: [ListDiffable]? {
        return actionItems
    }

    // MARK: - ListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }

    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? WSActionGroup else {
            return false
        }

        return identifier == other.identifier
    }
}

// MARK: - 条目

/// 动作配置列表的条目。列表数据需要 `ListDiffable`，这里对动作做一层包装。
class WSActionListItem: NSObject {

    /// 动作
    let action: WSActionItem

    /// 条目唯一标识
    private let identifier = UUID().uuidString

    init(action: WSActionItem) {
        self.action = action
        super.init()
    }

    // MARK: - ListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }

    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? WSActionListItem else {
            return false
        }

        return identifier == other.identifier
    }
}

// MARK: - 列表单元格

/// 动作配置列表的单元格：左侧颜色竖条，中间动作名称，右侧区分方式的图标。
class WSActionSelectCell: TPBaseTableCell {

    /// 布局尺寸
    private enum Metrics {

        /// 颜色竖条尺寸及其与名称的间距
        static let colorSize = CGSize(width: 6.0, height: 16.0)
        static let colorSpacing: CGFloat = 8.0

        /// 名称字号
        static let titleFont = UIFont.systemFont(ofSize: 15.0, weight: .medium)

        /// 右侧图标尺寸及其与名称的间距
        static let iconSize = CGSize(width: 16.0, height: 16.0)
        static let iconSpacing: CGFloat = 6.0
    }

    /// 当前展示的动作
    var action: WSActionItem? {
        didSet {
            updateAction()
        }
    }

    /// 颜色竖条
    private let colorView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = Metrics.colorSize.width / 2.0
        return view
    }()

    /// 动作名称
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.titleFont
        label.textColor = .label
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    /// 方式图标：添加为加号，跳转为箭头
    private lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .secondaryLabel
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 14.0,
                                                                            weight: .semibold)
        return imageView
    }()

    override func setupContentSubviews() {
        super.setupContentSubviews()

        contentView.addSubview(colorView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(iconView)
    }

    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()

        let layoutFrame = contentView.layoutFrame()
        guard layoutFrame.width > 0.0, layoutFrame.height > 0.0 else {
            return
        }

        colorView.size = Metrics.colorSize
        colorView.left = layoutFrame.minX
        colorView.centerY = layoutFrame.midY

        iconView.size = Metrics.iconSize
        iconView.right = layoutFrame.maxX
        iconView.centerY = layoutFrame.midY

        let titleLeft = colorView.right + Metrics.colorSpacing
        let titleRight = iconView.left - Metrics.iconSpacing
        titleLabel.frame = CGRect(x: titleLeft,
                                  y: layoutFrame.minY,
                                  width: max(titleRight - titleLeft, 0.0),
                                  height: layoutFrame.height)
    }

    // MARK: - 渲染
    private func updateAction() {
        guard let action = action else {
            colorView.backgroundColor = nil
            titleLabel.text = nil
            iconView.image = nil
            return
        }

        colorView.backgroundColor = action.color ?? .primary
        titleLabel.text = action.title
        iconView.image = UIImage(systemName: action.mode == .add ? "plus" : "arrow.right")
    }
}

// MARK: - 动作列表

/// 动作配置列表。
///
/// 展示已配置的动作，点击进入编辑，左滑可编辑或删除，长按可拖动调整顺序。
class WSActionListViewController: TPViewController,
                                   TPGroupTableViewDelegate,
                                   TPTableDragInsertReorderDelegate {

    /// 布局尺寸
    private enum Metrics {

        /// 首个区块顶部间距
        static let headerHeight: CGFloat = 5.0

        /// 单元格高度
        static let cellHeight: CGFloat = 55.0
    }

    /// 点击动作回调，参数为动作位置
    var didSelectAction: ((Int) -> Void)?

    /// 动作变化回调，删除或排序后回调最新的动作列表
    var didChangeActions: (([WSActionItem]) -> Void)?

    /// 当前配置的动作
    private(set) var actions: [WSActionItem]

    /// 排序管理器
    private var reorder: TPTableDragInsertReorder?

    /// 分组标识
    private let groupIdentifier = "WSActionListGroup"

    /// 单元格样式
    private lazy var cellStyle: TPTableCellStyle = {
        let style = TPTableCellStyle()
        style.backgroundColor = .secondarySystemGroupedBackground
        style.selectedBackgroundColor = .tertiarySystemFill
        return style
    }()

    /// 动作列表视图
    private lazy var listView: TPGroupTableView = {
        let view = TPGroupTableView(frame: .zero, style: .insetGrouped)
        view.delegate = self
        return view
    }()

    /// 占位视图提供者
    private lazy var placeholderProvider: TPDefaultPlaceholderProvider = {
        let provider = TPDefaultPlaceholderProvider()
        provider.emptyTitle = resGetString("No Actions")
        return provider
    }()

    init(actions: [WSActionItem]) {
        self.actions = actions
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGroupedBackground
        listView.placeholderProvider = placeholderProvider
        view.addSubview(listView)

        reloadList()
        setupReorder()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        listView.frame = view.bounds
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    // MARK: - 数据
    /// 更新动作列表
    func update(actions: [WSActionItem]) {
        self.actions = actions
        reloadList()
    }

    private func updateGroups() {
        let group = WSActionGroup(identifier: groupIdentifier)
        group.actionItems = actions.map { WSActionListItem(action: $0) }
        listView.groups = [group]
    }
    
    private func reloadList() {
        updateGroups()
        listView.reloadData()
    }

    /// 索引路径对应的动作条目
    private func actionItem(at indexPath: IndexPath) -> WSActionListItem? {
        return listView.item(at: indexPath) as? WSActionListItem
    }

    // MARK: - 删除
    /// 删除指定位置的动作并刷新列表
    func deleteAction(at index: Int) {
        guard index < actions.count else {
            return
        }

        actions.remove(at: index)
        updateGroups()
        listView.performUpdate(with: .fade)
        didChangeActions?(actions)
    }

    // MARK: - 排序
    /// 初始化长按拖动排序管理器
    private func setupReorder() {
        let reorder = TPTableDragInsertReorder(tableView: listView.adapter.tableView)
        reorder.indicatorBackColor = Color(0xFFFFFF, 0.1)
        reorder.isEnabled = true
        reorder.delegate = self
        self.reorder = reorder
    }

    // MARK: - TPGroupTableViewDelegate
    func groupTableView(_ tableView: TPGroupTableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Metrics.headerHeight
    }

    func groupTableView(_ tableView: TPGroupTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Metrics.cellHeight
    }

    func groupTableView(_ tableView: TPGroupTableView, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return WSActionSelectCell.self
    }

    func groupTableView(_ tableView: TPGroupTableView, didDequeCell cell: UITableViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? WSActionSelectCell else {
            return
        }

        cell.style = cellStyle
        cell.action = actionItem(at: indexPath)?.action
    }

    func groupTableView(_ tableView: TPGroupTableView, didSelectRowAt indexPath: IndexPath) {
        didSelectAction?(indexPath.row)
    }

    func groupTableView(_ tableView: TPGroupTableView,
                        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        /// 编辑
        let editAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completion in
            self?.didSelectAction?(indexPath.row)
            completion(true)
        }

        editAction.backgroundColor = Color(0x0091FF)
        editAction.image = resGetImage("edit_24", color: .white)

        /// 删除
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            self?.deleteAction(at: indexPath.row)
            completion(true)
        }

        deleteAction.image = resGetImage("trash_24", color: .white)

        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }

    // MARK: - TPTableDragInsertReorderDelegate
    func tableDragReorder(_ reorder: TPTableDragReorder, canMoveRowAt indexPath: IndexPath) -> Bool {
        return actions.count > 1
    }

    func tableDragReorder(_ reorder: TPTableDragReorder, willBeginAt indexPath: IndexPath) {
        reorder.tableView.setEditing(false, animated: false)
    }

    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder,
                                canInsertRowTo targetIndexPath: IndexPath,
                                from sourceIndexPath: IndexPath) -> Bool {
        return true
    }

    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder,
                                inserRowTo targetIndexPath: IndexPath,
                                from sourceIndexPath: IndexPath,
                                depth: Int) -> IndexPath? {
        guard targetIndexPath.row != sourceIndexPath.row else {
            return nil
        }

        actions.moveObject(fromIndex: sourceIndexPath.row, toIndex: targetIndexPath.row)
        didChangeActions?(actions)
        listView.moveRow(at: sourceIndexPath, to: targetIndexPath)
        return targetIndexPath
    }
}
