//
//  TodoTaskBoardView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/15.
//

import Foundation
import UIKit


protocol TodoTaskBoardViewDelegate: AnyObject {
    
    /// 列表待办分组数组
    func todoGroupsForTaskBoardView(_ boardView: TodoTaskBoardView) -> [TodoGroup]?
    
    /// 点击分组添加
    func todoTaskBoardView(_ boardView: TodoTaskBoardView, didClickAddForGroup group: TodoGroup?)
        
    /// 通知列表选中任务
    func todoTaskBoardView(_ boardView: TodoTaskBoardView, didSelectTask task: TodoTask)
    
    /// 通知列表选中任务
    func todoTaskBoardView(_ boardView: TodoTaskBoardView, didClickCheckboxForTask task: TodoTask)
    
    /// 通知列表在选择模式下选中任务发生改变
    func todoTaskBoardViewDidChangeSelectedTasks(_ boardView: TodoTaskBoardView)
}

class TodoTaskBoardView: UIView, TPMultipleItemSelectionUpdater {

    /// 代理对象
    weak var delegate: TodoTaskBoardViewDelegate?
    
    /// 是否是选择模式
    var isSelecting: Bool {
        return _isSelecting
    }
    
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
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    func setupSubviews() {
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
    
    func isAllTaskSelected() -> Bool {
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
    
    func selectedTasks() -> Set<TodoTask> {
        return selection.selectedItems
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
        adapter.reloadData()
    }
    
    /// 更新列表
    func performUpdate() {
        adapter.performUpdate {[weak self] _ in
            self?.forEachVisibleCell { cell in
                cell.pageView.performUpdate()
            }
        }
    }
    
    func didUpdate(with infos: [TodoTaskChangeInfo]) {
        forEachVisibleCell { cell in
            cell.pageView.didUpdate(with: infos)
        }
    }
    
    func reloadCell(for task: TodoTask) {
        reloadCell(for: [task])
    }
    
    func reloadCell(for tasks: [TodoTask]) {
        forEachVisibleCell { cell in
            cell.pageView.reloadCell(for: tasks)
        }
    }
    
    /// 更新任务对应单元格内容
    func updateCellContent(for tasks: [TodoTask]) {
        forEachVisibleCell { cell in
            cell.pageView.updateCellContent(for: tasks)
        }
    }
    
    /// 根据特定标识对应的页面头视图
    func updateTopView(for identifer: String) {
        guard let groupInfo = groupInfo(for: identifer),
              let cell = adapter.cellForItem(groupInfo.group) as? TodoTaskBoardCell else {
            return
        }
        
        cell.pageView.updateTopView()
    }

    /// 更新选择标记和头尾视图
    private func updateCheckmarksAndSupplementaryViews() {
        forEachVisibleCell { cell in
            cell.pageView.updateCheckmarksAndSupplementaryViews()
        }
    }
    
    // MARK: - TPMultipleItemSelectionUpdater
    func multipleItemSelectionDidChange<T>(inserts: Set<T>?, deletes: Set<T>?) where T : Hashable {
        delegate?.todoTaskBoardViewDidChangeSelectedTasks(self)
    }
    
    // MARK: - Helpers
    
    private func group(for cardView: TodoTaskPageView) -> TodoGroup? {
        guard let indexPath = cardView.indexPath,
              let group = adapter.item(at: indexPath) as? TodoGroup else {
            return nil
        }
        
        return group
    }
    
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
    
    /// 遍历可见单元格
    private func forEachVisibleCell(_ cellHandler: (TodoTaskBoardCell) -> Void) {
        guard let visibleCells = adapter.visibleCells as? [TodoTaskBoardCell] else {
            return
        }
        
        for cell in visibleCells {
            cellHandler(cell)
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
        return delegate?.todoGroupsForTaskBoardView(self)
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
        guard let cell = cell as? TodoTaskBoardCell else {
            return
        }
        
        cell.pageView.indexPath = indexPath
        cell.pageView.selection = selection
        cell.pageView.delegate = self
        cell.pageView.reloadData(isSelecting: isSelecting)
    }

    // MARK: - TodoTaskPageViewDelegate

    func taskCardViewDidClickAdd(_ cardView: TodoTaskPageView) {
        let group = group(for: cardView)
        delegate?.todoTaskBoardView(self, didClickAddForGroup: group)
    }
    
    func headerTitleForTaskCardView(_ cardView: TodoTaskPageView) -> String? {
        var title: String?
        if let group = group(for: cardView) {
            title = group.title
        }
        
        return title ?? resGetString("Untitled Section")
    }
    
    func groupsForTaskCardView(_ cardView: TodoTaskPageView) -> [TodoGroup]? {
        guard let group = group(for: cardView) else {
            return nil
        }
        
        return [group]
    }
    
    func taskCardView(_ cardView: TodoTaskPageView, didSelectTask task: TodoTask) {
        delegate?.todoTaskBoardView(self, didSelectTask: task)
    }
    
    func taskCardView(_ cardView: TodoTaskPageView, didClickCheckboxForTask task: TodoTask) {
        delegate?.todoTaskBoardView(self, didClickCheckboxForTask: task)
    }
    
    func taskCardView(_ cardView: TodoTaskPageView, didChangeCollapsedForGroup group: TodoGroup) {
        
    }
}

// MARK: - Getters
extension TodoTaskBoardView {
    
    var scrollView: UIScrollView {
        return collectionView
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
        
}
