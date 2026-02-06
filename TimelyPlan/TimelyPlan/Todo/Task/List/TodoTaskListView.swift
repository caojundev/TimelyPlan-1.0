//
//  TodoTaskListView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/13.
//

import Foundation
import UIKit

protocol TodoTaskListViewDelegate: AnyObject {
    
    /// 列表待办分组数组
    func todoGroupsForTaskListView(_ listView: TodoTaskListView) -> [TodoGroup]?
    
    /// 通知列表选中任务
    func todoTaskListView(_ listView: TodoTaskListView, didSelectTask task: TodoTask)
    
    /// 通知列表选中任务
    func todoTaskListView(_ listView: TodoTaskListView, didClickCheckboxForTask task: TodoTask)
    
    /// 分组切换了收起 / 展开状态
    func todoTaskListView(_ listView: TodoTaskListView, didChangeCollapsedForGroup group: TodoGroup)
    
    /// 通知列表在选择模式下选中任务发生改变
    func todoTaskListViewDidChangeSelectedTasks(_ listView: TodoTaskListView)
    
    /// 任务对应头部滑动菜单配置
    func todoTaskListView(_ listView: TodoTaskListView, leadingSwipeActionsConfigurationForTask task: TodoTask) -> UISwipeActionsConfiguration?
    
    /// 任务对应尾部滑动菜单配置
    func todoTaskListView(_ listView: TodoTaskListView, trailingSwipeActionsConfigurationForTask task: TodoTask) -> UISwipeActionsConfiguration?
    
    /// 将开始拖动
    func todoTaskListViewWillBeginDragging(_ listView: TodoTaskListView)
    
    func  todoTaskListView(_ listView: TodoTaskListView, willBeginEditingTask task: TodoTask)
}

extension TodoTaskListViewDelegate {
    
    func todoTaskListViewWillBeginDragging(_ listView: TodoTaskListView) {}
    
    func  todoTaskListView(_ listView: TodoTaskListView, willBeginEditingTask task: TodoTask) {}
}

class TodoTaskListView: UIView,
                        TPTableViewAdapterDataSource,
                        TPTableViewAdapterDelegate,
                        TodoTaskCheckTableCellDelegate,
                        TodoGroupSelectingHeaderViewDelegate {
    
    /// 代理对象
    weak var delegate: TodoTaskListViewDelegate?
    
    var scrollsToTop: Bool {
        get {
            return tableView.scrollsToTop
        }
        
        set {
            tableView.scrollsToTop = newValue
        }
    }
    
    /// 是否是选择模式
    var isSelecting: Bool {
        return _isSelecting
    }
    
    /// 选择模式下当前选中任务
    var selectedTasks: Set<TodoTask> {
        return selection.selectedItems
    }
    
    /// 选择模式下是否可以编辑
    var canEditWhileSelecting: Bool = false

    /// 样式
    let style: UITableView.Style

    /// 任务选择器
    private var selection = TPMultipleItemSelection<TodoTask>()
    
    /// 集合视图
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: bounds, style: style)
        if #available(iOS 15.0, *) {
            tableView.isPrefetchingEnabled = false
        }

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelectionDuringEditing = true
        tableView.placeholderView = placeholderView
        tableView.shouldShowPlaceholder = { [weak self] in
            return self?.shouldShowPlaceholder() ?? false
        }
        
        return tableView
    }()
    
    /// 占位视图
    private(set) lazy var placeholderView: TPDefaultPlaceholderView = {
        let view = TPDefaultPlaceholderView()
        view.isBorderHidden = true
        return view
    }()
    
    private var _isSelecting: Bool = false
    
    private let adapter = TPTableViewAdapter()
   
    /// 布局管理器
    private let layoutManager = TodoTaskLayoutManager()
    
    var layoutConfig = TodoTaskLayoutConfig() {
        didSet {
            layoutManager.config = layoutConfig
        }
    }
    
    var detailOption: TodoTaskDetailOption {
        get {
            return layoutManager.detailOption
        }
        
        set {
            layoutManager.detailOption = newValue
        }
    }
    
    /// 隐藏头视图高度
    private let hiddenHeaderHeight = 0.0
    
    /// 显示头视图高度
    private let showHeaderHeight = 50.0
    
    /// 是否隐藏分组头
    var shouldHideGroupHeader: Bool = false
    
    /// 显示详情
    private(set) var showDetail: Bool
    
    init(frame: CGRect, style: UITableView.Style, showDetail: Bool = true) {
        self.style = style
        self.showDetail = showDetail
        super.init(frame: frame)
        self.backgroundColor = .systemGroupedBackground
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame = bounds
    }
    
    override func endEditing(_ force: Bool) -> Bool {
        tableView.setEditing(false, animated: true)
        return super.endEditing(force)
    }
    
    func setupSubviews() {
        adapter.dataSource = self
        adapter.delegate = self
        adapter.tableView = tableView
        addSubview(tableView)
    }

    /// 是否显示占位视图
    private func shouldShowPlaceholder() -> Bool {
        guard adapter.objects.count > 0 else {
            return true
        }
        
        if shouldHideGroupHeader {
            return !adapter.hasItem
        }
        
        return false
    }
    
    // MARK: - Public Methods
    func indexPathForRow(at point: CGPoint) -> IndexPath? {
        let convertedPoint = self.convert(point, toViewOrWindow: tableView)
        return tableView.indexPathForRow(at: convertedPoint)
    }
    
    func cellForRow(at indexPath: IndexPath) -> UITableViewCell? {
        return tableView.cellForRow(at: indexPath)
    }
    
    func task(at indexPath: IndexPath) -> TodoTask? {
        return adapter.item(at: indexPath) as? TodoTask
    }
    
    /// 设置是否显示详情
    func setShowDetail(_ showDetail: Bool) {
        guard self.showDetail != showDetail else {
            return
        }
        
        self.showDetail = showDetail
        tableView.reloadData()
    }

    func didDeleteTasks(_ tasks: [TodoTask]) {
        layoutManager.removeLayout(for: tasks)
    }
    
    func didUpdate(with infos: [TodoTaskChangeInfo]) {
        guard infos.count == 1 else {
            return
        }
        
        /// 处理进度改变
        let info = infos[0]
        if case .progress(let oldValue, let newValue) = info.change {
            didChangeProgress(from: oldValue, to: newValue, for: info.task)
        }
    }
    
    /// 重新加载数据
    func reloadData() {
        layoutManager.removeAllLayouts()
        adapter.reloadData()
    }
    
    func reloadCell(for task: TodoTask) {
        layoutManager.setNeedsLayout(for: [task])
        adapter.reloadCell(forItem: task, with: .none)
    }
    
    func reloadCell(for tasks: [TodoTask]) {
        layoutManager.setNeedsLayout(for: tasks)
        adapter.reloadCell(forItems: tasks, with: .none)
    }
    
    /// 更新列表
    func performUpdate() {
        adapter.performUpdate(with: .fade, completion: nil)
        updateVisibleCellsIfNeeded()
    }
    
    /*
    func updateCell(for tasks: [TodoTask]) {
        layoutManager.setNeedsLayout(for: tasks)
        guard let infos = visibleInfos(for: tasks) else {
            return
        }
        
        for info in infos {
            guard let cell = adapter.cellForRow(at: info.indexPath) as? TodoTaskBaseTableCell else {
                continue
            }

            cell.layout = layout(for: info.task)
            cell.reloadData(animated: true)
        }
    }
    
    /// 更新所有可见单元格
    func updateVisibleCells(animated: Bool = true) {
        guard let cells = adapter.visibleCells() as? [TodoTaskBaseTableCell] else {
            return
        }
        
        for cell in cells {
            if let task = cell.task {
                layoutManager.setNeedsLayout(for: task)
                cell.layout = layout(for: task)
                cell.reloadData(animated: animated)
            }
        }
    }
     */
    
    /// 更新所有可见单元格
    func updateVisibleCellsIfNeeded(animated: Bool = true) {
        guard let cells = adapter.visibleCells() as? [TodoTaskBaseTableCell] else {
            return
        }
        
        for cell in cells {
            cell.reloadDataIfNeeded(animated: animated)
        }
    }
    
    /// 更新所有可见区块的头和脚视图
    func updateHeaderFooterViews() {
        adapter.updateHeaderFooterViews()
    }
    
    /// 更新分组标识对应的区块头和脚视图
    func updateHeaderFooterViewForSection(with identifier: String) {
        if let info = groupInfo(for: identifier) {
            adapter.updateHeaderFooterView(of: info.section)
        }
    }
    
    /// 结束编辑模式
    func endEditing(animated: Bool = true) {
        tableView.setEditing(false, animated: animated)
    }
    
    /// 选中模式
    func setSelecting(_ selecting: Bool) {
        guard _isSelecting != selecting else {
            return
        }
        
        _isSelecting = selecting
        /// 取消编辑
        tableView.setEditing(false, animated: false)
        selection.reset()
        tableView.reloadData()
    }
    
    /// 选中所有任务
    @objc func selectAllTasks() {
        let allTasks = allTasks()
        guard selection.selectedItems != allTasks else {
            return
        }
    
        TPImpactFeedback.impactWithSoftStyle()
        selection.setSelectedItems(allTasks)
        didChangeSelectedTasks()
    }
    
    /// 反选所有任务
    @objc func deselectAllTasks() {
        guard selection.selectedCount > 0 else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        selection.reset()
        didChangeSelectedTasks()
    }
    
    /// 是否所有任务都被选中了
    func isAllTasksSelected() -> Bool{
        let selectedTasks = selection.selectedItems
        guard selectedTasks.count > 0 else {
            return false
        }
        
        let allTasks = allTasks()
        guard allTasks.count > 0 else {
            return false
        }
        
        let count = selectedTasks.intersection(allTasks).count
        return count == allTasks.count
    }
    
    /// 返回特定标识的区块是否存在
    func isSectionExist(with identifier: String) -> Bool {
        if groupInfo(for: identifier) != nil {
            return true
        }
        
        return false
    }
    
    // MARK: - TPTableViewAdapterDataSource
    func sectionObjects(for adapter: TPTableViewAdapter) -> [ListDiffable]? {
        return delegate?.todoGroupsForTaskListView(self)
    }
    
    func adapter(_ adapter: TPTableViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        guard let group = sectionObject as? TodoGroup, group.isExpanded else {
            return nil
        }
        
        return group.tasks
    }
    
    // MARK: - TPTableViewAdapterDelegate
    func adapter(_ adapter: TPTableViewAdapter, didSelectRowAt indexPath: IndexPath) {
        guard let task = task(at: indexPath) else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        guard isSelecting else {
            delegate?.todoTaskListView(self, didSelectTask: task)
            return
        }

        /// 选择模式
        selection.selectItem(task, autoDeselect: true)
        didChangeSelectedTask(at: indexPath)
    }
    
    func adapter(_ adapter: TPTableViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        if isSelecting {
            /// 选择模式
            return TodoTaskSelectTableCell.self
        } else {
            /// 正常模式
            return TodoTaskCheckTableCell.self
        }
    }
    
    func adapter(_ adapter: TPTableViewAdapter, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let task = task(at: indexPath) else {
            return 0.0
        }
        
        let layout = layout(for: task)
        return layout.height
    }

    func adapter(_ adapter: TPTableViewAdapter, didDequeCell cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? TodoTaskBaseTableCell, let task = task(at: indexPath) else {
            return
        }
        
        cell.delegate = self
        cell.layout = layout(for: task)
        cell.reloadData(animated: false)
    }
    
    func adapter(_ adapter: TPTableViewAdapter, shouldShowCheckmarkForRowAt indexPath: IndexPath) -> Bool {
        guard isSelecting, let task = task(at: indexPath) else {
            return false
        }
        
        return selection.isSelectedItem(task)
    }
    
    func adapter(_ adapter: TPTableViewAdapter, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if isSelecting && !canEditWhileSelecting {
            return nil
        }
        
        guard let task = task(at: indexPath) else {
            return nil
        }
        
        return delegate?.todoTaskListView(self, leadingSwipeActionsConfigurationForTask: task)
    }
    
    func adapter(_ adapter: TPTableViewAdapter, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if isSelecting && !canEditWhileSelecting {
            return nil
        }
        
        guard let task = task(at: indexPath) else {
            return nil
        }
        
        return delegate?.todoTaskListView(self, trailingSwipeActionsConfigurationForTask: task)
    }
    
    func adapter(_ adapter: TPTableViewAdapter, willBeginEditingRowAt indexPath: IndexPath) {
        guard let task = task(at: indexPath) else {
            return
        }
        
        delegate?.todoTaskListView(self, willBeginEditingTask: task)
    }
    
    // MARK: - HeaderView
    func adapter(_ adapter: TPTableViewAdapter, heightForHeaderInSection section: Int) -> CGFloat {
        guard !shouldHideGroupHeader, let group = adapter.object(at: section) as? TodoGroup else {
            return hiddenHeaderHeight
        }
        
        return group.isHeaderHidden ? hiddenHeaderHeight : showHeaderHeight
    }
    
    func adapter(_ adapter: TPTableViewAdapter, classForHeaderInSection section: Int) -> AnyClass? {
        guard !shouldHideGroupHeader, let group = adapter.object(at: section) as? TodoGroup, !group.isHeaderHidden else {
            return UITableViewHeaderFooterView.self
        }
    
        if isSelecting {
            return TodoGroupSelectingHeaderView.self
        }
   
        return TodoGroupNormalHeaderView.self
    }
    
    func adapter(_ adapter: TPTableViewAdapter, didDequeHeader headerView: UITableViewHeaderFooterView, inSection section: Int) {
        guard let headerView = headerView as? TodoGroupBaseHeaderView,
              let group = adapter.object(at: section) as? TodoGroup else {
            return
        }
        
        headerView.delegate = self
        headerView.section = section
        headerView.title = group.title
        headerView.setExpanded(group.isExpanded, animated: false)
        
        let totalTasksCount = group.tasks?.count ?? 0
        if let headerView = headerView as? TodoGroupNormalHeaderView {
            /// 正常模式
            headerView.count = totalTasksCount
        } else if let headerView = headerView as? TodoGroupSelectingHeaderView {
            /// 选择模式
            var selectedTasksCount: Int = 0
            if let tasks = group.tasks, tasks.count > 0 {
                let selectedTasks = selection.selectedItems
                selectedTasksCount = selectedTasks.intersection(Set(tasks)).count
            }
            
            headerView.countInfo = (selectedTasksCount, totalTasksCount)
        }
    }
    
    func adapter(_ adapter: TPTableViewAdapter, updateHeaderInSection section: Int) {
        guard let headerView = adapter.headerView(in: section) else {
            return
        }
        
        self.adapter(adapter, didDequeHeader: headerView, inSection: section)
    }
    
    
    // MARK: - TodoGroupSelectingHeaderViewDelegate
    func selectingHeaderViewDidClickSelectAll(_ headerView: TodoGroupSelectingHeaderView) {
        guard isSelecting, let group = adapter.object(at: headerView.section) as? TodoGroup else {
            return
        }
        
        if let tasks = group.tasks, tasks.count > 0 {
            selection.selectItems(tasks)
            didChangeSelectedTasks()
        }
    }
    
    func selectingHeaderViewDidClickDeselectAll(_ headerView: TodoGroupSelectingHeaderView) {
        guard isSelecting, let group = adapter.object(at: headerView.section) as? TodoGroup else {
            return
        }
        
        if let tasks = group.tasks, tasks.count > 0 {
            selection.deselectItems(tasks)
            didChangeSelectedTasks()
        }
    }
    
    func headerViewDidClickExpand(_ headerView: TodoGroupBaseHeaderView) {
        guard let group = adapter.object(at: headerView.section) as? TodoGroup else {
            return
        }
        
        let isExpanded = !group.isExpanded
        group.isExpanded = isExpanded
        headerView.setExpanded(isExpanded, animated: true)
        adapter.performSectionUpdate(forSectionObject: group, rowAnimation: .fade)

        /// 通知代理对象分组展开状态数据
        delegate?.todoTaskListView(self, didChangeCollapsedForGroup: group)
    }
    
    // MARK: - TodoTaskCheckTableCellDelegate
    func todoTaskCheckTableCellDidClickCheckbox(_ cell: TodoTaskCheckTableCell) {
        guard let indexPath = adapter.indexPath(for: cell), let task = task(at: indexPath) else {
            return
        }
    
        delegate?.todoTaskListView(self, didClickCheckboxForTask: task)
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.todoTaskListViewWillBeginDragging(self)
    }

    // MARK: - Helpers
    var layoutWidth: CGFloat {
        var width = bounds.width
        if tableView.style == .insetGrouped {
            width -= tableView.layoutMargins.horizontalLength
        }
        
        return width
    }
    
    private func layout(for task: TodoTask) -> TodoTaskInfoLayout {
        layoutManager.width = layoutWidth
        layoutManager.showDetail = showDetail
        layoutManager.config = layoutConfig
        return layoutManager.layout(for: task)
    }
    
    /// 获取标识对应的分组和索引信息
    private func groupInfo(for identifier: String) -> (section: Int, group: TodoGroup)? {
        guard let groups = adapter.objects as? [TodoGroup] else {
            return nil
        }

        for (section, group) in groups.enumerated() {
            if identifier == group.identifier {
                return (section, group)
            }
        }
        
        return nil
    }

    /// 获取当前列表的所有任务
    private func allTasks() -> Set<TodoTask> {
        guard let allTasks = adapter.allItems() as? [TodoTask], allTasks.count > 0 else {
            return []
        }
        
        return Set(allTasks)
    }
    
    /*
    /// 获取任务对应的可见索引
    private func visibleIndexPaths(for tasks: [TodoTask]) -> Set<IndexPath>? {
        let visibleIndexPaths = adapter.visibleIndexPaths()
        guard visibleIndexPaths.count > 0 else {
            return nil
        }
        
        var indexPaths = [IndexPath]()
        for task in tasks {
            if let indexPath = adapter.indexPath(of: task) {
                indexPaths.append(indexPath)
            }
        }
        
        return Set(visibleIndexPaths).intersection(indexPaths)
    }
    
    /// 获取任务可见索引信息
    private func visibleInfos(for tasks: [TodoTask]) -> [(task: TodoTask, indexPath: IndexPath)]? {
        let visibleIndexPaths = adapter.visibleIndexPaths()
        guard visibleIndexPaths.count > 0 else {
            return nil
        }
        
        var infos = [(TodoTask, IndexPath)]()
        for task in tasks {
            if let indexPath = adapter.indexPath(of: task), visibleIndexPaths.contains(indexPath) {
                infos.append((task, indexPath))
            }
        }
        
        if infos.count > 0 {
            return infos
        }
        
        return nil
    }
    */
    
    private func didChangeSelectedTasks() {
        adapter.updateCheckmarks(animated: true)
        adapter.updateHeaderFooterViews()
        delegate?.todoTaskListViewDidChangeSelectedTasks(self)
    }
    
    private func didChangeSelectedTask(at indexPath: IndexPath) {
        let group = adapter.object(at: indexPath.section)
        adapter.updateCheckmark(at: indexPath, animated: true)
        adapter.updateHeaderFooterView(forSectionObject: group)
        delegate?.todoTaskListViewDidChangeSelectedTasks(self)
    }
    
    private func didChangeProgress(from: TodoEditProgress?, to: TodoEditProgress?, for task: TodoTask) {
        guard let from = from, let to = to, to.currentValue != from.currentValue else {
            return
        }
        
        guard let cell = adapter.cellForItem(task) as? TodoTaskCheckTableCell else {
            return
        }
        
        let difference = to.currentValue - from.currentValue
        let message = (difference >= 0 ? "+" : "") + "\(difference)"
        TPTextPopUp.showText(message,
                             color: task.priority.titleColor,
                             font: BOLD_SMALL_SYSTEM_FONT,
                             fromView: cell.checkbox)
    }
}

/*
extension TodoTaskListView: TPTableDragInsertReorderDelegate {
 
    /// 获取区块所有任务
    func tasks(in section: Int) -> [TodoTask] {
        guard let sectionController = sectionControllers?[section] as? TodoGroupSectionController else {
            return []
        }
        
        let tasks = sectionController.items as? [TodoTask]
        return tasks ?? []
    }
    
    func task(at indexPath: IndexPath) -> TodoTask {
        let tasks = tasks(in: indexPath.section)
        return tasks[indexPath.row]
    }
    
    // MARK: - TPTableDragInsertReorderDelegate
    func tableDragReorder(_ reorder: TPTableDragReorder, canMoveRowAt indexPath: IndexPath) -> Bool {
        let listType = self.list.listType
        guard listType == .inbox || listType == .user else {
            return false
        }
        
        let isManually = self.organizer.sortType == .manually
        return isManually
    }
    
    func tableDragReorder(_ reorder: TPTableDragReorder, willBeginAt indexPath: IndexPath) {
        let task = task(at: indexPath)
        guard todo.setExpand(false, for: task) else {
            return
        }
        
//        if let cell = adapter.cellForRow(at: indexPath) as? TodoTaskTableViewCell {
////            cell.setExpanded(false, animated: false)
//        }
        
        adapter.performUpdate(with: .fade)
    }
    
    func tableDragReorderDidEnd(_ reorder: TPTableDragReorder) {
        /// 无操作
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, indentationLevelTo targetIndexPath: IndexPath, from sourceIndexPath: IndexPath, ratio: CGFloat) -> Int {
        let tasks = tasks(in: targetIndexPath.section)
        return tasks.indentationLevel(to: targetIndexPath.row, from: sourceIndexPath.row, ratio: ratio)
    }
    
    /// 聚焦索引
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, focusIndexPathTo targetIndexPath: IndexPath, from sourceIndexPath: IndexPath, depth: Int) -> IndexPath? {
        let tasks = tasks(in: targetIndexPath.section)
        guard let index = tasks.focusIndex(to: targetIndexPath.row, from: sourceIndexPath.row, depth: depth) else {
            return nil
        }
        
        return IndexPath(row: index, section: targetIndexPath.section)
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, canInsertRowTo targetIndexPath: IndexPath, from sourceIndexPath: IndexPath) -> Bool {
        guard sourceIndexPath.section == targetIndexPath.section else {
            return false
        }
        
        let tasks = tasks(in: targetIndexPath.section)
        return tasks.canInsertItem(at: sourceIndexPath.row, to: targetIndexPath.row)
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, inserRowTo targetIndexPath: IndexPath, from sourceIndexPath: IndexPath, depth: Int) -> IndexPath? {
        let task = task(at: sourceIndexPath)
        if sourceIndexPath.row == targetIndexPath.row, task.depth == depth {
            /// 行和深度都相同则不做处理
            return sourceIndexPath
        }
        
        /// 旧父清单
        let oldParentTask = task.parent
        return targetIndexPath
        
        /*
        todo.reorderLists(lists: lists,
                          fromIndex: sourceIndexPath.row,
                          toIndex: targetIndexPath.row,
                          depth: depth)
        adapter?.performUpdate()
        
        let affectedLists = TodoList.affectedItems(for: list, fromParent: oldParentList)
        adapter?.reloadCell(forItems: affectedLists, with: .none)
        
        /// 重新计算reorder的拖动索引
        var newIndexPath: IndexPath? = nil
        if let newIndex = lists.indexOf(list) {
            newIndexPath = IndexPath(row: newIndex, section: section)
        }

        reorder.changeDraggingIndexPath(newIndexPath)
        */
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, canFlashRowAt indexPath: IndexPath, from sourceIndexPath: IndexPath) -> Bool {
        let task = task(at: indexPath)
        guard !task.isExpanded && task.hasSubItem else {
            return false
        }

        /// 判断是否可以移进目标清单
        let tasks = tasks(in: indexPath.section)
        return tasks.canMoveItem(at: sourceIndexPath.row, intoItemAt: indexPath.row)
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder, didFlashRowAt indexPath: IndexPath, from sourceIndexPath: IndexPath) {
        let fromTask = task(at: sourceIndexPath)
        let touchTask = task(at: indexPath)
        guard todo.setExpand(true, for: touchTask) else {
            return
        }
        
        adapter.performUpdate()
        
        let tasks = tasks(in: sourceIndexPath.section)
        var newIndexPath: IndexPath? = nil
        if let newIndex = tasks.indexOf(fromTask) {
            newIndexPath = IndexPath(row: newIndex, section: sourceIndexPath.section)
        }
        
        reorder.changeDraggingIndexPath(newIndexPath)
    }
}
*/
