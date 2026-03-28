//
//  FocusTimerListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/23.
//

import Foundation
import UIKit

protocol FocusTimerListViewDelegate: AnyObject {

    /// 异步获取习惯任务分组数据
    func focusTimerListView(_ listView: FocusTimerListView,
                            fetchTimerGroups completion: @escaping ([FocusTimerGroup]?) -> Void)
    
    /// 获取单元格类
    func focusTimerListView(_ listView: FocusTimerListView, classForCellAt indexPath: IndexPath) -> AnyClass?
    
    /// 配置出队的单元格
    func focusTimerListView(_ listView: FocusTimerListView, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath)
    
    func focusTimerListView(_ listView: FocusTimerListView, didSelectItemAt indexPath: IndexPath)
    
    /// 获取头部视图类
    func focusTimerListView(_ listView: FocusTimerListView, classForHeaderInSection section: Int) -> AnyClass?
    
    /// 获取头部视图尺寸
    func focusTimerListView(_ listView: FocusTimerListView, sizeForHeaderInSection section: Int) -> CGSize

    /// 配置出队的头部视图
    func focusTimerListView(_ listView: FocusTimerListView, didDequeHeader headerView: UICollectionReusableView, inSection section: Int)
}

// MARK: - Default Implementation
extension FocusTimerListViewDelegate {
    
    func focusTimerListView(_ listView: FocusTimerListView, classForHeaderInSection section: Int) -> AnyClass? {
        return TPCollectionHeaderFooterView.self
    }
    
    func focusTimerListView(_ listView: FocusTimerListView, sizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }

    func focusTimerListView(_ listView: FocusTimerListView, didDequeHeader headerView: UICollectionReusableView, inSection section: Int) {
        
    }
    
    func focusTimerListView(_ listView: FocusTimerListView, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return UICollectionViewCell.self
    }
    
    func focusTimerListView(_ listView: FocusTimerListView, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        
    }
    
    func focusTimerListView(_ listView: FocusTimerListView, didSelectItemAt indexPath: IndexPath) {
        
    }
}



class FocusTimerListView: TPCollectionWrapperView,
                            TPCollectionViewAdapterDataSource,
                            TPCollectionViewAdapterDelegate,
                            TPCollectionHeaderFooterViewDelegate {
    
    // MARK: - Properties
    weak var delegate: FocusTimerListViewDelegate?
    
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

    let cellStyle = FocusUserTimerCellStyle()
    
    /// 区块布局
    private(set) lazy var sectionLayout: TPCollectionSectionLayout = {
        let layout = TPCollectionSectionLayout()
        layout.edgeMargins = UIEdgeInsets(horizontal: 15.0, vertical: 10.0)
        layout.minimumItemsCountPerRow = 1
        layout.maximumItemsCountPerRow = 1
        layout.lineSpacing = 10.0
        layout.interitemSpacing = 10.0
        layout.preferredItemHeight = 70.0
        layout.preferredItemWidth = kFocusTimerListContentMaxWidth
        return layout
    }()
    
    // MARK: - Properties
    private var groups: [FocusTimerGroup]?
    
    private let requestManager = TPRequestManager()
    
    private var refreshControl = UIRefreshControl()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        self.setupRefreshControl()
        self.collectionView.showsVerticalScrollIndicator = false
        self.setupPlaceholderViewProvider()
        self.adapter.footerSize = .zero
        self.adapter.cellStyle.cornerRadius = 20.0
        self.adapter.dataSource = self
        self.adapter.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupRefreshControl() {
        self.refreshControl.addTarget(self,
                                      action: #selector(handleRefresh),
                                      for: .valueChanged)
        self.collectionView.refreshControl = self.refreshControl
    }
    
    private func setupPlaceholderViewProvider() {
        self.placeholderViewProvider = { [weak self] in
            guard let self = self else { return nil }
            let placeholderView = self.createPlaceholderView()
            /// 外部配置占位图
            self.placeholderConfiguration?(placeholderView)
            return placeholderView
        }
    }
    
    private func createPlaceholderView() -> TPDefaultPlaceholderView {
        let view = TPDefaultPlaceholderView()
        view.isBorderHidden = true
        view.image = resGetImage("focus_placeholder_noTimer_80")
        view.title = resGetString("No Timer")
        view.titleColor = .lightGray
        return view
    }
    
    // MARK: - 下拉刷新
    @objc private func handleRefresh() {
        self.asyncPerformUpdate()
    }
    
    // MARK: - 异步重新加载数据
    func asyncReloadData() {
        self.asyncLoadGroups { isSuccess in
            if isSuccess {
                self.adapter.reloadData()
            }
        }
    }
    
    /// 异步执行更新
    /// - Parameter completion: 完成回调，参数为是否成功
    func asyncPerformUpdate(completion: ((Bool) -> Void)? = nil) {
        self.asyncLoadGroups { [weak self] isSuccess in
            if isSuccess {
                self?.adapter.performUpdate()
            }
            
            completion?(isSuccess)
        }
    }
    
    // MARK: - 数据加载
    private func asyncLoadGroups(completion: @escaping (Bool) -> Void) {
        let requestID = requestManager.executeRequest()
        guard let delegate = self.delegate else {
            self.refreshControl.endRefreshing()
            completion(true)
            return
        }
            
        delegate.focusTimerListView(self) { [weak self] groups in
            self?.refreshControl.endRefreshing()
            guard let self = self else {
                completion(false)
                return
            }
            
            guard self.requestManager.shouldProceed(with: requestID) else {
                completion(false)
                return
            }

            self.groups = groups
            completion(true)
        }
    }

    // MARK: - 获取数据
    /// 获取指定区块的对象
    func sectionObject(at section: Int) -> ListDiffable {
        return adapter.object(at: section)
    }

    /// 获取指定索引路径的项
    func item(at indexPath: IndexPath) -> ListDiffable {
        return adapter.item(at: indexPath)
    }

    /// 所有条目
    func allItems() -> [ListDiffable] {
        return adapter.allItems()
    }
    
    /// 获取指定区块的所有项
    func items(for section: Int) -> [ListDiffable] {
        let sectionObject = adapter.object(at: section)
        return adapter.items(for: sectionObject)
    }
    
    func cell(for item: ListDiffable) -> UICollectionViewCell? {
        return adapter.cellForItem(item)
    }
    
    /// 聚焦显示计时器
    func revealTimer(_ timer: FocusTimer, autoScroll: Bool = true) {
        guard autoScroll else {
            self.adapter.commitFocusAnimation(for: timer)
            return
        }
        
        self.adapter.scrollToItem(timer, at: .centeredVertically, animated: true) { _ in
            self.adapter.commitFocusAnimation(for: timer)
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
        return groups
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        guard let group = sectionObject as? FocusTimerGroup else {
            return nil
        }
        
        return group.timers
    }
    
    // MARK: - TPCollectionViewAdapterDelegate
    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        if let delegate = delegate {
            return delegate.focusTimerListView(self, classForCellAt: indexPath)
        }
        
        return TPCollectionCell.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        if let cell = cell as? TPCollectionCell {
            cell.cellStyle = cellStyle
        }
        
        delegate?.focusTimerListView(self, didDequeCell: cell, at: indexPath)
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
        delegate?.focusTimerListView(self, didSelectItemAt: indexPath)
    }
    
    // MARK: - Header Methods
    func adapter(_ adapter: TPCollectionViewAdapter, classForHeaderInSection section: Int) -> AnyClass? {
        if let delegate = delegate {
            return delegate.focusTimerListView(self, classForHeaderInSection: section)
        }
        
        return UICollectionReusableView.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForHeaderInSection section: Int) -> CGSize {
        if let delegate = delegate {
            return delegate.focusTimerListView(self, sizeForHeaderInSection: section)
        }
        
        return .zero
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeHeader headerView: UICollectionReusableView, inSection section: Int) {
        if let delegate = delegate {
            delegate.focusTimerListView(self, didDequeHeader: headerView, inSection: section)
        }
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, updateHeaderInSection section: Int) {
        guard let headerView = adapter.headerView(in: section) else {
            return
        }
        
        if let delegate = delegate {
            delegate.focusTimerListView(self, didDequeHeader: headerView, inSection: section)
        }
    }
    
    // MARK: - TPCollectionHeaderFooterViewDelegate
    func layoutMarginsForHeaderFooterView(_ view: TPCollectionHeaderFooterView) -> UIEdgeInsets {
        return UIEdgeInsets(left: sectionLayout.sectionInset.left,
                            right: sectionLayout.sectionInset.right)
    }
}
