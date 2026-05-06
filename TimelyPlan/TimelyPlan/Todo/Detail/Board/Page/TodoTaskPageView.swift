//
//  TodoTaskPageView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/14.
//

import Foundation
import UIKit

protocol TodoTaskPageViewDelegate: AnyObject {

    /// 是否显示添加
    func shouldShowAddForTaskPageView(_ pageView: TodoTaskPageView) -> Bool
    
    /// 点击添加
    func taskPageViewDidClickAdd(_ pageView: TodoTaskPageView)
    
    /// 通知列表选中任务
    func taskPageView(_ pageView: TodoTaskPageView, didSelectTask task: TodoTask)
    
    /// 通知列表选中任务
    func taskPageView(_ pageView: TodoTaskPageView, didClickCheckboxForTask task: TodoTask)
    
    /// 重新安排任务
    func taskPageView(_ pageView: TodoTaskPageView, rescheduleTasks tasks: [TodoTask])
    
}

class TodoTaskPageView: UIView,
                        TPCollectionViewAdapterDataSource,
                        TPCollectionViewAdapterDelegate,
                        TodoTaskPageHeaderViewDelegate,
                        TodoTaskPageSelectingHeaderViewDelegate,
                        TodoTaskPageCheckCellDelegate {
    
    var group: TodoGroup?
    
    /// 代理对象
    weak var delegate: TodoTaskPageViewDelegate?
    
    /// 当前索引
    var indexPath: IndexPath?
    
    /// 任务选择器
    var selection = TPMultipleItemSelection<TodoTask>()
    
    /// 是否是选择模式
    var isSelecting: Bool {
        return _isSelecting
    }

    /// 布局配置
    var layoutConfig = TodoTaskLayoutConfig()
    
    /// 是否显示详情
    var showDetail: Bool {
        get {
            return layoutManager.showDetail
        }
        
        set {
            layoutManager.showDetail = newValue
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
    
    /// 行间距
    var lineSpacing: CGFloat = 8.0
    
    /// 区块内间距
    var sectionInset = UIEdgeInsets(top: 8.0, left: 4.0, bottom: 4.0, right: 4.0)
    
    /// 是否选择模式
    private var _isSelecting: Bool = false
    
    /// 适配器
    private let adapter = TPCollectionViewAdapter()
   
    /// 布局管理器
    private let layoutManager = TodoTaskLayoutManager()
    
    /// 布局对象
    private var collectionViewLayout: UICollectionViewFlowLayout

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .clear
        collectionView.isPrefetchingEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.shouldShowPlaceholder = { [weak self] in
            return self?.shouldShowPlaceholder() ?? false
        }
        
        return collectionView
    }()
    
    /// 头视图
    private let headerViewHeight = 50.0
    private lazy var headerView: TodoTaskPageHeaderView = {
        let view = TodoTaskPageHeaderView(frame: .zero)
        view.padding = UIEdgeInsets(left: sectionInset.left,
                                    right: sectionInset.right)
        view.delegate = self
        return view
    }()
    
    /// 添加视图
    private let addViewHeight: CGFloat = 65.0
    private lazy var addView: TodoTaskPageAddView = {
        let view = TodoTaskPageAddView(frame: .zero)
        view.didClickAdd = { [weak self] in
            self?.clickAdd()
        }
        
        return view
    }()
    
    // MARK: - 插入指示器
    /// 指示视图颜色
    private let indicatorLineColor: UIColor = Color(0x046BDE)
    
    /// 插入指示器背景色
    private let indicatorBackColor: UIColor = Color(0xFFFFFF, 0.8)
    
    /// 指示视图高度
    private let indicatorHeight = 6.0

    /// 插入指示视图
    private var insertIndicatorView: TPDragInsertIndicatorView?
    
    override init(frame: CGRect) {
        self.collectionViewLayout = UICollectionViewFlowLayout()
        super.init(frame: frame)
        self.setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        adapter.dataSource = self
        adapter.delegate = self
        adapter.collectionView = collectionView
        addSubview(collectionView)
        addSubview(headerView)
        addSubview(addView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        var headerViewTop = 0.0
        var collectionTop = headerViewHeight
        if headerView.isHidden {
            headerViewTop = -headerViewHeight
            collectionTop = 0.0
        }
        
        headerView.frame = CGRect(x: 0.0, y: headerViewTop, width: bounds.width, height: headerViewHeight)
        
        collectionViewLayout.invalidateLayout()
        collectionView.frame = CGRect(x: 0.0,
                                      y: collectionTop,
                                      width: bounds.width,
                                      height: bounds.height - collectionTop)
        collectionView.layoutIfNeeded()
        updateContentInset()
        updateAddView()
        updateHeaderViewSeparator()
    }
    
    func updateHeaderView() {
        headerView.title = group?.title ?? resGetString("Untitled Section")
        
        var showRescheduleButton = false
        if let group = group, group.isOverdue, group.hasUncompletedTask {
            showRescheduleButton = true
        }
        
        headerView.showRescheduleButton = showRescheduleButton
        updateHeaderViewSeparator()
        if headerView.isHidden != isSelecting {
            headerView.isHidden = isSelecting
            setNeedsLayout()
        }
   }

    var contentInset: UIEdgeInsets? {
        didSet {
            updateContentInset()
        }
    }
    
    private func updateContentInset() {
        let contentInset = self.contentInset ?? .zero
        collectionView.contentInset = contentInset
    }
    
    /// 更新头视图分割线
    private func updateHeaderViewSeparator() {
        headerView.isSeparatorHidden = collectionView.contentOffset.y <= 0.0
    }

    /// 是否隐藏添加按钮
    private var shouldShowAdd: Bool {
        return delegate?.shouldShowAddForTaskPageView(self) ?? false
    }
    
    private func updateAddView(animated: Bool) {
        guard animated else {
            updateAddView()
            return
        }
        
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: [.beginFromCurrentState, .curveEaseInOut],
                       animations: {
            self.updateAddView()
        })
    }

    private func updateAddView() {
        collectionView.layoutIfNeeded()
        addView.isHidden = !shouldShowAdd || isSelecting
        
        let bottomPoint = CGPoint(x: 0.0, y: collectionView.contentSize.height - sectionInset.bottom)
        let toolbarY = collectionView.convert(bottomPoint, toViewOrWindow: self).y
        let maxY = bounds.height - addViewHeight - safeAreaInsets.bottom
        if toolbarY <= maxY {
            addView.frame = CGRect(x: 0,
                                   y: toolbarY,
                                   width: collectionView.frame.width,
                                   height: addViewHeight)
            addView.isFixed = false
        } else {
            addView.frame = CGRect(x: 0,
                                   y: maxY,
                                   width: collectionView.frame.width,
                                   height: addViewHeight)
            addView.isFixed = true
        }
    }
    
    /// 是否显示占位视图
    private func shouldShowPlaceholder() -> Bool {
        guard adapter.objects.count > 0 else {
            return true
        }
        
        return false
    }
    
    private func clickAdd() {
        delegate?.taskPageViewDidClickAdd(self)
    }
    
    // MARK: - Public Methods
    /// 重新加载数据
    func reloadData() {
        layoutManager.removeAllLayouts()
        adapter.reloadData()
        updateHeaderView()
        updateAddView()
        setNeedsLayout()
    }
    
    func reloadData(isSelecting: Bool) {
        /// 直接设置属性
        _isSelecting = isSelecting
        reloadData()
    }
    
    func reloadCell(for task: TodoTask) {
        layoutManager.setNeedsLayout(for: [task])
        adapter.reloadCell(forItem: task)
        updateAddView(animated: true)
    }
    
    func reloadCell(for tasks: [TodoTask]) {
        layoutManager.setNeedsLayout(for: tasks)
        adapter.reloadCell(forItems: tasks)
        updateAddView(animated: true)
    }
    
    /// 更新列表
    func performUpdate() {
        layoutManager.removeAllLayouts()
        adapter.performUpdate()
        updateHeaderView()
        updateAddView(animated: true)
        setNeedsLayout()
    }
    
    func didUpdate(with infos: [TodoTaskChangeInfo]) {
        updateCellContent(for: infos.tasks)
        
        /// 处理进度改变
        guard infos.count == 1 else {
            return
        }
        
        let info = infos[0]
        if case .progress(let oldValue, let newValue) = info.change {
            didChangeProgress(from: oldValue, to: newValue, for: info.task)
        }
    }
    
    func updateCellContent(for tasks: [TodoTask]) {
        layoutManager.setNeedsLayout(for: tasks)
        guard let infos = visibleInfos(for: tasks) else {
            return
        }
        
        for info in infos {
            guard let cell = adapter.cellForItem(at: info.indexPath) as? TodoTaskPageBaseCell else {
                continue
            }

            cell.layout = layout(for: info.task)
            cell.reloadData(animated: true)
        }
    }
    
    /// 更新所有可见区块的头和脚视图
    func updateHeaderFooterViews() {
        adapter.updateHeaderFooterViews()
        updateAddView(animated: true)
    }
    
    /// 更新分组标识对应的区块头和脚视图
    func updateHeaderFooterViewForSection(with identifier: String) {
        if let info = groupInfo(for: identifier) {
            adapter.updateHeaderFooterView(of: info.section)
        }
    }
    
    /// 返回特定标识的区块是否存在
    func isSectionExist(with identifier: String) -> Bool {
        if groupInfo(for: identifier) != nil {
            return true
        }
        
        return false
    }
    
    /// 更新选中标记和头尾视图
    func updateCheckmarksAndSupplementaryViews(animated: Bool = true) {
        adapter.updateCheckmarks(animated: animated)
        adapter.updateHeaderFooterViews()
    }
    
    /// 选中模式
    func setSelecting(_ selecting: Bool) {
        guard _isSelecting != selecting else {
            return
        }
        
        _isSelecting = selecting
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        collectionView.isEditing = false /// 取消编辑
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        CATransaction.commit()
        
        updateHeaderView()
        updateAddView(animated: true)
    }
    
    /// 聚焦显示任务
    func revealTask(_ task: TodoTask,
                    at scrollPosition: UICollectionView.ScrollPosition = .top,
                    autoScroll: Bool = true) {
        adapter.revealItem(task, at: scrollPosition, autoScroll: autoScroll)
    }
    
    // MARK: - TPCollectionViewAdapterDataSource
    func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        guard let group = group else {
            return nil
        }
        
        return [group]
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        return group?.tasks
    }
    
    // MARK: - TPCollectionViewAdapterDelegate
    func adapter(_ adapter: TPCollectionViewAdapter, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInset
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, lineSpacingForSectionAt section: Int) -> CGFloat {
        return lineSpacing
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        guard let task = task(at: indexPath) else {
            return
        }
        
        guard isSelecting else {
            delegate?.taskPageView(self, didSelectTask: task)
            return
        }

        /// 选择模式
        selection.selectItem(task, autoDeselect: true)
        didChangeSelectedTask(at: indexPath)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        if isSelecting {
            /// 选择模式
            return TodoTaskPageSelectCell.self
        } else {
            /// 正常模式
            return TodoTaskPageCheckCell.self
        }
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let task = task(at: indexPath) else {
            return .zero
        }
        
        let layout = layout(for: task)
        return layout.size
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? TodoTaskPageBaseCell, let task = task(at: indexPath) else {
            return
        }
        
        cell.delegate = self
        cell.layout = layout(for: task)
        cell.reloadData(animated: false)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldShowCheckmarkForItemAt indexPath: IndexPath) -> Bool {
        guard isSelecting, let task = task(at: indexPath) else {
            return false
        }
        
        return selection.isSelectedItem(task)
    }
    
    // MARK: - HeaderView
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForHeaderInSection section: Int) -> CGSize {
        guard shouldShowSectionHeader() else {
            return .zero
        }
        
        return CGSize(width: .greatestFiniteMagnitude, height: headerViewHeight)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, classForHeaderInSection section: Int) -> AnyClass? {
        guard shouldShowSectionHeader() else {
            return UICollectionReusableView.self
        }
    
        if isSelecting {
            return TodoTaskPageSelectingHeaderView.self
        } else {
            return TodoTaskPageSectionHeaderView.self
        }
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeHeader headerView: UICollectionReusableView, inSection section: Int) {
        guard let headerView = headerView as? TodoTaskPageSectionHeaderView,
              let group = adapter.object(at: section) as? TodoGroup else {
            return
        }
        
        headerView.padding = UIEdgeInsets(left: sectionInset.left,
                                          right: sectionInset.right)
        headerView.delegate = self
        headerView.section = section
        headerView.title = group.title
        let totalTasksCount = group.tasks?.count ?? 0
        guard isSelecting else {
            /// 正常模式
            headerView.count = totalTasksCount
            return
        }
        
        /// 选择模式
        if let headerView = headerView as? TodoTaskPageSelectingHeaderView {
           var selectedTasksCount: Int = 0
           if let tasks = group.tasks, tasks.count > 0 {
               let selectedTasks = selection.selectedItems
               selectedTasksCount = selectedTasks.intersection(Set(tasks)).count
           }
           
           headerView.countInfo = (selectedTasksCount, totalTasksCount)
       }
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, updateHeaderInSection section: Int) {
        guard let headerView = adapter.headerView(in: section) else {
            return
        }
        
        self.adapter(adapter, didDequeHeader: headerView, inSection: section)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForFooterInSection section: Int) -> CGSize {
        .zero
    }
    
    // MARK: - TodoTaskPageHeaderViewDelegate
    func taskHeaderViewDidClickMore(_ headerView: TodoTaskPageHeaderView) {
        
    }
    
    func taskHeaderViewDidClickReschedule(_ headerView: TodoTaskPageHeaderView) {
        if let group = group, group.isOverdue, let tasks = group.uncompletedTasks {
            delegate?.taskPageView(self, rescheduleTasks: tasks)
        }
    }
    
    // MARK: - TodoTaskPageSelectingHeaderViewDelegate
    func taskPageSelectHeaderViewDidClickSelectAll(_ headerView: TodoTaskPageSelectingHeaderView) {
        guard isSelecting, let group = adapter.object(at: headerView.section) as? TodoGroup else {
            return
        }
        
        if let tasks = group.tasks, tasks.count > 0 {
            selection.selectItems(tasks)
            didChangeSelectedTasks()
        }
    }
    
    func taskPageSelectHeaderViewDidClickDeselectAll(_ headerView: TodoTaskPageSelectingHeaderView) {
        guard isSelecting, let group = adapter.object(at: headerView.section) as? TodoGroup else {
            return
        }
        
        if let tasks = group.tasks, tasks.count > 0 {
            selection.deselectItems(tasks)
            didChangeSelectedTasks()
        }
    }
    
    // MARK: - TodoTaskPageCheckCellDelegate
    func todoTaskPageCheckCellDidClickCheckbox(_ cell: TodoTaskPageCheckCell) {
        guard let indexPath = adapter.indexPath(for: cell), let task = task(at: indexPath) else {
            return
        }
    
        delegate?.taskPageView(self, didClickCheckboxForTask: task)
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderViewSeparator()
        updateAddView()
    }

    // MARK: - Helpers
    
    /// 是否显示分组对应的区块头视图
    private func shouldShowSectionHeader() -> Bool {
        return isSelecting
    }
    
    private func layout(for task: TodoTask) -> TodoTaskInfoLayout {
        layoutManager.width = collectionView.frame.width - sectionInset.horizontalLength
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
    
    /// 获取索引处的任务
    private func task(at indexPath: IndexPath) -> TodoTask? {
        guard let groups = adapter.objects as? [TodoGroup] else {
            return nil
        }

        let section = indexPath.section
        guard section < groups.count else {
            return nil
        }
        
        let group = groups[section]
        return group.task(at: indexPath.row)
    }

    /// 获取当前列表的所有任务
    private func allTasks() -> Set<TodoTask> {
        guard let groups = adapter.objects as? [TodoGroup], groups.count > 0 else {
            return []
        }

        var result = Set<TodoTask>()
        for group in groups {
            if let tasks = group.tasks, tasks.count > 0 {
                result = result.union(tasks)
            }
        }
        
        return result
    }
    
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

    private func didChangeSelectedTasks() {
        updateCheckmarksAndSupplementaryViews()
    }
    
    private func didChangeSelectedTask(at indexPath: IndexPath) {
        let group = adapter.object(at: indexPath.section)
        adapter.updateCheckmark(at: indexPath, animated: true)
        adapter.updateHeaderFooterView(forSectionObject: group)
    }
    
    private func didChangeProgress(from: TodoEditProgress?, to: TodoEditProgress?, for task: TodoTask) {
        guard let from = from, let to = to, to.currentValue != from.currentValue else {
            return
        }
        
        guard let cell = adapter.cellForItem(task) as? TodoTaskPageCheckCell else {
            return
        }
        
        let difference = to.currentValue - from.currentValue
        let message = (difference >= 0 ? "+" : "") + "\(difference)"
        let containerView = self.parentViewController?.view
        TPTextPopUp.showText(message,
                             color: task.priority.titleColor,
                             font: BOLD_SMALL_SYSTEM_FONT,
                             fromView: cell.checkbox,
                             containerView: containerView)
    }
}

extension TodoTaskPageView {
    
    var scrollView: UIScrollView {
        return collectionView
    }
    
    /// 是否有任务
    var hasTask: Bool {
        return adapter.hasItem()
    }
    
    // MARK: - Indicator
    func setupInsertIndicator() {
        if insertIndicatorView == nil {
            let view = TPDragInsertIndicatorView()
            view.lineColor = indicatorLineColor
            view.backColor = indicatorBackColor
            insertIndicatorView = view
        }
        
        if let insertIndicatorView = insertIndicatorView, insertIndicatorView.superview == nil {
            collectionView.addSubview(insertIndicatorView)
        }
    }
    
    func showInsertIndicator(at indexPath: IndexPath, atEnd: Bool) {
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            hideInsertIndicator()
            return
        }
        
        setupInsertIndicator()
        var centerY: CGFloat
        if atEnd {
            centerY = cell.frame.maxY + lineSpacing / 2.0
        } else {
            centerY = cell.frame.minY - lineSpacing / 2.0
        }
        
        centerY = max(indicatorHeight / 2.0, min(collectionView.contentSize.height - indicatorHeight / 2.0, centerY))
        let offsetY = centerY - indicatorHeight / 2.0
        showInsertIndicator(offsetY: offsetY)
    }
    
    func showInsertIndicatorAtTop() {
        setupInsertIndicator()
        showInsertIndicator(offsetY: indicatorHeight / 2.0)
    }
    
    private func showInsertIndicator(offsetY: CGFloat) {
        let indicatorWidth = bounds.width - sectionInset.horizontalLength
        insertIndicatorView?.frame = CGRect(x: sectionInset.left,
                                            y: offsetY,
                                            width: indicatorWidth,
                                            height: indicatorHeight)
        insertIndicatorView?.isHidden = false
    }
    
    func hideInsertIndicator() {
        insertIndicatorView?.removeFromSuperview()
        insertIndicatorView = nil
    }
    
    // MARK: - IndexPath
    func indexPathForItem(at point: CGPoint) -> IndexPath? {
        let convertedPoint = self.convert(point, toViewOrWindow: collectionView)
        return collectionView.indexPathForItem(at: convertedPoint)
    }
    
    func insertIndexPathForItem(at point: CGPoint) -> IndexPath? {
        if let indexPath = indexPathForItem(at: point) {
            return indexPath
        }
        
        let lineSpacing = collectionViewLayout.minimumLineSpacing
        let topPoint = CGPoint(x: point.x, y: point.y - lineSpacing * 0.5)
        if let indexPath = indexPathForItem(at: topPoint) {
            return indexPath
        }
        
        let bottomPoint = CGPoint(x: point.x, y: point.y + lineSpacing * 0.5)
        let indexPath = indexPathForItem(at: bottomPoint)
        return indexPath
    }
    
    // MARK: - Cell
    func cellForItem(at indexPath: IndexPath) -> UICollectionViewCell? {
        return collectionView.cellForItem(at: indexPath)
    }
    
    // MARK: - Task Status Update
    /// 更新任务完成状态
    func updateTaskCompletionStatus(_ task: TodoTask, isCompleted: Bool) {
        guard let indexPath = adapter.indexPath(of: task),
              let cell = cellForItem(at: indexPath) as? TodoTaskPageCheckCell else {
            return
        }
        
        cell.checkbox.isChecked = isCompleted
        cell.setNeedsLayout()
    }
    
    /// 更新任务进度
    func updateTaskProgress(_ task: TodoTask, progress: Double) {
        guard let indexPath = adapter.indexPath(of: task),
              let cell = cellForItem(at: indexPath) as? TodoTaskPageCheckCell else {
            return
        }
        
        cell.infoView.setProgress(progress)
        cell.setNeedsLayout()
    }
}
