//
//  TodoTaskBoardView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/15.
//

import Foundation
import UIKit

protocol TodoTaskBoardViewDelegate: AnyObject {

    /// 点击分组添加
    func todoTaskBoardView(_ boardView: TodoTaskBoardView, didClickAddForGroup group: TodoGroup)
        
    /// 是否显示添加
    func todoTaskBoardView(_ boardView: TodoTaskBoardView, shouldShowAddForGroup group: TodoGroup) -> Bool
    
    /// 通知列表选中任务
    func todoTaskBoardView(_ boardView: TodoTaskBoardView, didSelectTask task: TodoTask)
    
    /// 通知列表选中任务
    func todoTaskBoardView(_ boardView: TodoTaskBoardView, didClickCheckboxForTask task: TodoTask)

    /// 重新安排任务
    func todoTaskBoardView(_ boardView: TodoTaskBoardView, rescheduleTasks tasks: [TodoTask])
    
    /// 通知列表在选择模式下选中任务发生改变
    func todoTaskBoardViewDidChangeSelectedTasks(_ boardView: TodoTaskBoardView)
    
}

class TodoTaskBoardView: UIView, TPMultipleItemSelectionUpdater {

    /// 代理对象
    weak var delegate: TodoTaskBoardViewDelegate?
    
    /// 分组数组
    var groups: [TodoGroup]?
    
    /// 详情显示
    var detailOption: TodoTaskDetailOption = .allExceptList
    
    /// 是否是选择模式
    var isSelecting: Bool {
        return _isSelecting
    }
    
    /// 选中的任务
    var selectedTasks: Set<TodoTask> {
        return selection.selectedItems
    }
    
    var shouldShowPlaceholder: (() -> Bool)? {
        get {
            return collectionView.shouldShowPlaceholder
        }
        
        set {
            collectionView.shouldShowPlaceholder = newValue
        }
    }
    
    /// 提供占位视图
    var placeholderProvider: TPPlaceholderProviding? {
        didSet {
            updatePlaceholderView()
        }
    }
    
    /// 显示详情
    private(set) var showDetail: Bool
    
    /// 内容间距
    private(set) var contentInset: UIEdgeInsets?
    
    /// 任务选择器
    private var selection = TPMultipleItemSelection<TodoTask>()

    /// 选择模式私有属性
    private var _isSelecting: Bool = false
    
    /// 布局对象
    private let collectionViewLayout = TodoTaskBoardFlowLayout()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: collectionViewLayout)
        collectionView.decelerationRate = .fast
        collectionView.backgroundColor = .clear
        collectionView.isPrefetchingEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let adapter = TPCollectionViewAdapter()
   
    init(frame: CGRect, showDetail: Bool) {
        self.showDetail = showDetail
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        self.backgroundColor = .systemGroupedBackground
        self.collectionView.backgroundColor = .systemGroupedBackground
        selection.addUpdater(self)
        adapter.dataSource = self
        adapter.delegate = self
        adapter.collectionView = collectionView
        addSubview(collectionView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = safeLayoutFrame()
        collectionViewLayout.collectionSize = layoutFrame.size
        collectionView.frame = layoutFrame
        collectionView.setNeedsLayout()
        collectionView.layoutIfNeeded()
    }
    
    func updatePlaceholderView() {
        collectionView.placeholderView = placeholderProvider?.placeholderView()
    }
    
    func setSelecting(_ isSelecting: Bool) {
        guard _isSelecting != isSelecting else {
            return
        }
        
        _isSelecting = isSelecting
        selection.reset(with: nil) /// 重置选择管理器
        
        guard let visibleCells = adapter.visibleCells as? [TodoTaskBoardCell] else {
            return
        }
        
        for cell in visibleCells {
            cell.pageView.selection = selection
            cell.pageView.setSelecting(isSelecting)
        }
    }

    /// 设置是否显示详情
    func setShowDetail(_ showDetail: Bool) {
        guard self.showDetail != showDetail else {
            return
        }

        self.showDetail = showDetail
        forEachVisiblePageView { pageView in
            pageView.showDetail = showDetail
            pageView.reloadData()
        }
    }
    
    func setContentInset(_ contentInset: UIEdgeInsets) {
        guard self.contentInset != contentInset else {
            return
        }
        
        self.contentInset = contentInset
        forEachVisiblePageView { pageView in
            pageView.contentInset = contentInset
        }
    }
    
    func isAllTasksSelected() -> Bool {
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
    
    func selectAllTasks() {
        guard isSelecting else {
            return
        }
        
        let allTasks = allTasks()
        selection.setSelectedItems(allTasks)
        updateCheckmarksAndSupplementaryViews()
    }
    
    func deselectAllTasks() {
        guard isSelecting else {
            return
        }
        
        selection.setSelectedItems(nil)
        updateCheckmarksAndSupplementaryViews()
    }
    
    /// 结束编辑模式
    func endEditing(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.setSelecting(false)
            }
        } else {
            setSelecting(false)
        }
    }
    
    /// 设置任务完成状态
    func setCompleted(_ isCompleted: Bool, for task: TodoTask, completion: ((Bool) -> Void)?) {
        guard let cell = cellForTask(task) as? TodoTaskPageCheckCell else {
            completion?(false)
            return
        }
    
        cell.setCompleted(isCompleted, animated: true) {
            completion?(true)
        }
    }
    
    /// 设置任务进度
    func setProgress(_ progress: TodoEditProgress, for task: TodoTask, completion: ((Bool) -> Void)?) {
        guard let from = task.progress,
              progress.currentValue != from.currentValue,
              let cell = cellForTask(task) as? TodoTaskPageCheckCell else {
                  completion?(false)
            return
        }
    
        let difference = progress.currentValue - from.currentValue
        let message = (difference >= 0 ? "+" : "") + "\(difference)"
        TPTextPopUp.showText(message,
                             color: task.priority.titleColor,
                             font: BOLD_SMALL_SYSTEM_FONT,
                             fromView: cell.checkbox,
                             containerView: self)
        if progress.isCompleted {
            cell.setCompleted(true, animated: true, completion: nil)
        }
        
        cell.setProgress(progress.completionFraction, animated: true) {
            completion?(true)
        }
    }
    
    /// 返回特定标识的区块是否存在
    func isPageExist(with identifier: String) -> Bool {
        if groupInfo(for: identifier) != nil {
            return true
        }
        
        return false
    }
    
    
    // MARK: - Reload
    func reloadData() {
        updatePlaceholderView()
        adapter.reloadData()
    }
    
    /// 更新列表
    func performUpdate() {
        updatePlaceholderView()
        adapter.performUpdate {[weak self] _ in
            self?.forEachVisiblePageView { pageView in
                pageView.performUpdate()
            }
        }
    }
    
    func didUpdate(with infos: [TodoTaskChangeInfo]) {
        forEachVisiblePageView { pageView in
            pageView.didUpdate(with: infos)
        }
    }
    
    func reloadCell(for task: TodoTask) {
        reloadCell(for: [task])
    }
    
    func reloadCell(for tasks: [TodoTask]) {
        forEachVisiblePageView { pageView in
            pageView.reloadCell(for: tasks)
        }
    }
    
    /// 更新任务对应单元格内容
    func updateCellContent(for tasks: [TodoTask]) {
        forEachVisiblePageView { pageView in
            pageView.updateCellContent(for: tasks)
        }
    }

    /// 更新选择标记和头尾视图
    private func updateCheckmarksAndSupplementaryViews() {
        forEachVisiblePageView { pageView in
            pageView.updateCheckmarksAndSupplementaryViews()
        }
    }
    
    
    /// 聚焦显示任务
    func revealTask(_ task: TodoTask) {
        guard let pageIndexPath = pageIndexPath(of: task) else {
            return
        }
        
        let indexPath = IndexPath(item: pageIndexPath.page, section: 0)
        self.adapter.scrollToItem(at: indexPath,
                                  scrollPosition: .centeredHorizontally,
                                  animated: true) { [weak self] _ in
            guard let pageView = self?.pageView(of: pageIndexPath.page) else {
                return
            }
            
            pageView.revealTask(task)
        }
    }
    
    // MARK: - TPMultipleItemSelectionUpdater
    func multipleItemSelectionDidChange<T>(inserts: Set<T>?, deletes: Set<T>?) where T : Hashable {
        delegate?.todoTaskBoardViewDidChangeSelectedTasks(self)
    }
    
    // MARK: - Helpers
    /// 获取标识对应的分组和索引信息
    private func groupInfo(for identifier: String) -> (section: Int, group: TodoGroup)? {
        guard let groups = adapter.allItems() as? [TodoGroup] else {
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
        guard let groups = adapter.allItems() as? [TodoGroup], groups.count > 0 else {
            return []
        }
        
        var results = Set<TodoTask>()
        for group in groups {
            if let tasks = group.tasks, tasks.count > 0 {
                results.formUnion(tasks)
            }
        }
        
        return results
    }
    
    /// 遍历可见页面视图
    private func forEachVisiblePageView(_ body: (TodoTaskPageView) -> Void) {
        guard let visibleCells = adapter.visibleCells as? [TodoTaskBoardCell] else {
            return
        }
        
        for cell in visibleCells {
            body(cell.pageView)
        }
    }
}

extension TodoTaskBoardView: TPCollectionViewAdapterDataSource,
                             TPCollectionViewAdapterDelegate,
                             TodoTaskPageViewDelegate {
    
    // MARK: - TPCollectionViewAdapterDataSource
    func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        return [String(describing: type(of: self)) as NSString]
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        return groups
    }
    
    // MARK: - TPCollectionViewAdapterDelegate
    func adapter(_ adapter: TPCollectionViewAdapter, insetForSectionAt section: Int) -> UIEdgeInsets {
        return collectionViewLayout.sectionInset
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, lineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionViewLayout.minimumLineSpacing
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, interitemSpacingForSectionAt section: Int) -> CGFloat {
        return collectionViewLayout.minimumInteritemSpacing
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionViewLayout.itemSize
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return TodoTaskBoardCell.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? TodoTaskBoardCell,
              let group = adapter.item(at: indexPath) as? TodoGroup else {
            return
        }

        let pageView = cell.pageView
        pageView.indexPath = indexPath
        pageView.selection = selection
        pageView.delegate = self
        pageView.detailOption = detailOption
        pageView.showDetail = showDetail
        pageView.group = group
        pageView.contentInset = contentInset
        pageView.reloadData(isSelecting: isSelecting)
    }

    // MARK: - TodoTaskPageViewDelegate

    func taskPageViewDidClickAdd(_ pageView: TodoTaskPageView) {
        if let group = pageView.group {
            delegate?.todoTaskBoardView(self, didClickAddForGroup: group)
        }
    }
    
    func shouldShowAddForTaskPageView(_ pageView: TodoTaskPageView) -> Bool {
        guard let group = pageView.group else {
            return false
        }
        
        return delegate?.todoTaskBoardView(self, shouldShowAddForGroup: group) ?? false
    }

    func taskPageView(_ pageView: TodoTaskPageView, didSelectTask task: TodoTask) {
        delegate?.todoTaskBoardView(self, didSelectTask: task)
    }
    
    func taskPageView(_ pageView: TodoTaskPageView, didClickCheckboxForTask task: TodoTask) {
        delegate?.todoTaskBoardView(self, didClickCheckboxForTask: task)
    }
    
    func taskPageView(_ pageView: TodoTaskPageView, rescheduleTasks tasks: [TodoTask]) {
        delegate?.todoTaskBoardView(self, rescheduleTasks: tasks)
    }
    
}

// MARK: - Getters
extension TodoTaskBoardView {
    
    var scrollView: UIScrollView {
        return collectionView
    }
    
    /// 获取对应索引处的页面
    func pageView(of page: Int) -> TodoTaskPageView? {
        let indexPath = IndexPath(item: page, section: 0)
        guard let cell = adapter.cellForItem(at: indexPath) as? TodoTaskBoardCell else {
            return nil
        }
        
        return cell.pageView
    }
    
    func pageView(at point: CGPoint) -> TodoTaskPageView? {
        let convertedPoint = self.convert(point, toViewOrWindow: collectionView)
        guard let pageIndexPath = collectionView.indexPathForItem(at: convertedPoint) else {
            return nil
        }
     
        if let cell = collectionView.cellForItem(at: pageIndexPath) as? TodoTaskBoardCell {
            return cell.pageView
        }
    
        return nil
    }
    
    func touchIndexPath(at point: CGPoint) -> PageIndexPath? {
        return indexPath(at: point, isInsert: false)
    }
    
    func insertIndexPath(at point: CGPoint) -> PageIndexPath? {
        return indexPath(at: point, isInsert: true)
    }
    
    private func indexPath(at point: CGPoint, isInsert: Bool = false) -> PageIndexPath? {
        let convertedPoint = self.convert(point, toViewOrWindow: collectionView)
        guard let boardIndexPath = collectionView.indexPathForItem(at: convertedPoint),
              let boardCell = collectionView.cellForItem(at: boardIndexPath) as? TodoTaskBoardCell else {
            return nil
        }
        
        let page = boardIndexPath.item
        let pageView = boardCell.pageView
        let pagePoint = self.convert(point, toViewOrWindow: pageView)
        var indexPath: IndexPath?
        if isInsert {
            indexPath = pageView.insertIndexPathForItem(at: pagePoint)
        } else {
            indexPath = pageView.indexPathForItem(at: pagePoint)
        }
        
        guard let indexPath = indexPath else {
            return nil
        }
        
        return PageIndexPath(page: page, section: indexPath.section, row: indexPath.item)
    }
    
    /// 看板条目信息对应的单元格
    func cellForItem(at indexPath: PageIndexPath) -> UICollectionViewCell? {
        let boardIndexPath = IndexPath(item: indexPath.page, section: 0)
        guard let boardCell = collectionView.cellForItem(at: boardIndexPath) as? TodoTaskBoardCell else {
            return nil
        }

        let pageView = boardCell.pageView
        return pageView.cellForItem(at: indexPath.taskIndexPath)
    }
    
    func cellForTask(_ task: TodoTask) -> UICollectionViewCell? {
        guard let pageIndexPath = pageIndexPath(of: task) else {
            return nil
        }
        
        return cellForItem(at: pageIndexPath)
    }
    
    func pageIndexPath(of task: TodoTask) -> PageIndexPath? {
        guard let groups = self.groups else {
            return nil
        }
    
        for (page, group) in groups.enumerated() {
            if let row = group.tasks?.indexOf(task) {
                return PageIndexPath(page: page, section: 0, row: row)
            }
        }

        return nil
    }
            
    
}
