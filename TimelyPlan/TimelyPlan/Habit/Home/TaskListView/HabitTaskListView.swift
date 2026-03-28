//
//  HabitTaskListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/5.
//

import Foundation
import UIKit

protocol HabitTaskListViewDelegate: AnyObject {

    /// 获取习惯任务分组数据
    func groupsInHabitTaskListView(_ listView: HabitTaskListView) -> [HabitTaskGroup]?
    
    /// 获取单元格类
    func habitTaskListView(_ listView: HabitTaskListView, classForCellAt indexPath: IndexPath) -> AnyClass?
    
    /// 配置出队的单元格
    func habitTaskListView(_ listView: HabitTaskListView, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath)
    
    func habitTaskListView(_ listView: HabitTaskListView, didSelectItemAt indexPath: IndexPath)
    
    /// 获取头部视图类
    func habitTaskListView(_ listView: HabitTaskListView, classForHeaderInSection section: Int) -> AnyClass?
    
    /// 获取头部视图尺寸
    func habitTaskListView(_ listView: HabitTaskListView, sizeForHeaderInSection section: Int) -> CGSize

    /// 配置出队的头部视图
    func habitTaskListView(_ listView: HabitTaskListView, didDequeHeader headerView: UICollectionReusableView, inSection section: Int)
}

// MARK: - Default Implementation
extension HabitTaskListViewDelegate {

    func groupsInHabitTaskListView(_ listView: HabitTaskListView) -> [HabitTaskGroup]? {
        return nil
    }
    
    func habitTaskListView(_ listView: HabitTaskListView, classForHeaderInSection section: Int) -> AnyClass? {
        return TPCollectionHeaderFooterView.self
    }
    
    func habitTaskListView(_ listView: HabitTaskListView, sizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }

    func habitTaskListView(_ listView: HabitTaskListView, didDequeHeader headerView: UICollectionReusableView, inSection section: Int) {
        
    }
    
    func habitTaskListView(_ listView: HabitTaskListView, didSelectItemAt indexPath: IndexPath) { }
}


class HabitTaskListView: TPCollectionWrapperView,
                                TPCollectionViewAdapterDataSource,
                                TPCollectionViewAdapterDelegate,
                                TPCollectionHeaderFooterViewDelegate {
    
    // MARK: - Properties
    weak var delegate: HabitTaskListViewDelegate?
    
    /// 处理下拉刷新
    var refreshHandler: (() -> Void)?
    
    /// 首选 item 高度
    var preferredItemHeight: CGFloat {
        get {
            return sectionLayout.preferredItemHeight
        }
        
        set {
            sectionLayout.preferredItemHeight = newValue
        }
    }
    
    var placeholderView: TPDefaultPlaceholderView? {
        return collectionView.placeholderView as? TPDefaultPlaceholderView
    }
    
    /// 提供占位视图
    var placeholderConfiguration: ((TPDefaultPlaceholderView) -> Void)? {
        didSet {
            if let placeholderView = placeholderView {
                placeholderConfiguration?(placeholderView)
            }
        }
    }

    /// 区块布局
    private(set) lazy var sectionLayout: TPCollectionSectionLayout = {
        let layout = TPCollectionSectionLayout()
        layout.edgeMargins = UIEdgeInsets(horizontal: 15.0, vertical: 10.0)
        layout.minimumItemsCountPerRow = 1
        layout.maximumItemsCountPerRow = 1
        layout.lineSpacing = 10.0
        layout.interitemSpacing = 10.0
        layout.preferredItemHeight = 80.0
        layout.preferredItemWidth = kHabitTaskListContentMaxWidth
        return layout
    }()
    
    private(set) lazy var refreshControl: UIRefreshControl = {
        return UIRefreshControl()
    }()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        self.collectionView.showsVerticalScrollIndicator = false
        
        /// 新建并配置占位视图
        self.placeholderViewProvider = { [weak self] in
            guard let self = self else { return nil }
            let placeholderView = self.createPlaceholderView()
            self.placeholderConfiguration?(placeholderView)
            return placeholderView
        }
        
        self.adapter.footerSize = .zero
        self.adapter.cellStyle.cornerRadius = 20.0
        self.adapter.dataSource = self
        self.adapter.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupRefreshControl() {
        self.refreshControl.addTarget(self,
                                      action: #selector(handleRefresh),
                                      for: .valueChanged)
        self.collectionView.refreshControl = self.refreshControl
    }

    // MARK: - 下拉刷新
    @objc func handleRefresh() {
        self.refreshHandler?()
    }
    
    private func createPlaceholderView() -> TPDefaultPlaceholderView {
        let view = TPDefaultPlaceholderView()
        view.isBorderHidden = true
        view.titleColor = .lightGray
        view.image = resGetImage("habit_plceholder_task_80")
        view.title = resGetString("Tap + to create a new habit")
        return view
    }
    
    // MARK: - Public Methods
    
    /// 获取指定区块的对象
    func sectionObject(at section: Int) -> ListDiffable {
        return adapter.object(at: section)
    }

    /// 获取指定区块的所有项
    func items(for section: Int) -> [ListDiffable] {
        let sectionObject = adapter.object(at: section)
        return adapter.items(for: sectionObject)
    }
    
    /// 获取指定索引路径的项
    func item(at indexPath: IndexPath) -> ListDiffable {
        return adapter.item(at: indexPath)
    }
    
    func cell(for item: ListDiffable) -> UICollectionViewCell? {
        return adapter.cellForItem(item)
    }

    /// 执行更新操作
    func performUpdate(with completion: ((Bool) -> Void)? = nil) {
        self.adapter.performUpdate(with: completion)
    }
    
    /// 聚焦显示
    func revealItem(_ item: ListDiffable, autoScroll: Bool = true) {
        guard autoScroll else {
            self.adapter.commitFocusAnimation(for: item)
            return
        }
        
        self.adapter.scrollToItem(item, at: .centeredVertically, animated: true) { _ in
            self.adapter.commitFocusAnimation(for: item)
        }
    }

    /// 移动项的位置
    /// - Parameters:
    ///   - fromIndexPath: 源索引路径
    ///   - toIndexPath: 目标索引路径
    func moveItem(at fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        self.adapter.moveItem(at: fromIndexPath, to: toIndexPath)
    }
    
    // MARK: - TPCollectionViewAdapterDataSource
    func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        return delegate?.groupsInHabitTaskListView(self)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        guard let group = sectionObject as? HabitTaskGroup else {
            return nil
        }
        return group.tasks
    }
    
    // MARK: - TPCollectionViewAdapterDelegate
    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        if let delegate = delegate {
            return delegate.habitTaskListView(self, classForCellAt: indexPath)
        }
        
        return HabitTaskListBaseCell.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        delegate?.habitTaskListView(self, didDequeCell: cell, at: indexPath)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        sectionLayout.collectionViewSize = adapter.collectionViewSize()
        return sectionLayout.constraintCellSize ?? .zero
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionLayout.sectionInset
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, interitemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionLayout.interitemSpacing
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, lineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionLayout.lineSpacing
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        delegate?.habitTaskListView(self, didSelectItemAt: indexPath)
    }
    
    // MARK: - Header Methods
    func adapter(_ adapter: TPCollectionViewAdapter, classForHeaderInSection section: Int) -> AnyClass? {
        if let delegate = delegate {
            return delegate.habitTaskListView(self, classForHeaderInSection: section)
        }
        
        return UICollectionReusableView.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForHeaderInSection section: Int) -> CGSize {
        if let delegate = delegate {
            return delegate.habitTaskListView(self, sizeForHeaderInSection: section)
        }
        
        return .zero
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeHeader headerView: UICollectionReusableView, inSection section: Int) {
        if let delegate = delegate {
            delegate.habitTaskListView(self, didDequeHeader: headerView, inSection: section)
        }
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, updateHeaderInSection section: Int) {
        guard let headerView = adapter.headerView(in: section) else {
            return
        }
        
        if let delegate = delegate {
            delegate.habitTaskListView(self, didDequeHeader: headerView, inSection: section)
        }
    }
    
    // MARK: - TPCollectionHeaderFooterViewDelegate
    func layoutMarginsForHeaderFooterView(_ view: TPCollectionHeaderFooterView) -> UIEdgeInsets {
        return UIEdgeInsets(left: sectionLayout.sectionInset.left,
                            right: sectionLayout.sectionInset.right)
    }
}
