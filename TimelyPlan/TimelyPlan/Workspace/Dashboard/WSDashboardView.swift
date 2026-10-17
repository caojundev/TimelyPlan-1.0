//
//  WSDashboardView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/15.
//

import Foundation
import UIKit

protocol WSDashboardViewDelegate: AnyObject {
    
    /// 排序模式发生变化
    func dashboardView(_ dashboardView: WSDashboardView, didChangeReordering isReordering: Bool)
    
    /// 选中组件的菜单动作
    func dashboardView(_ dashboardView: WSDashboardView,
                       didSelectMenuAction action: WSPluginCell.MenuActionType,
                       for plugin: WSPlugin)
}

extension WSDashboardViewDelegate {
    
    func dashboardView(_ dashboardView: WSDashboardView, didChangeReordering isReordering: Bool) {
        
    }
    
    func dashboardView(_ dashboardView: WSDashboardView,
                       didSelectMenuAction action: WSPluginCell.MenuActionType,
                       for plugin: WSPlugin) {
        
    }
}

class WSDashboardView: UIView,
                              TPCollectionViewAdapterDataSource,
                              TPCollectionViewAdapterDelegate {
    
    /// 代理对象
    weak var delegate: WSDashboardViewDelegate?
    
    var plugins: [WSPlugin]?
    
    /// 内容间距
    var contentInset: UIEdgeInsets? {
        didSet {
            collectionView.contentInset = contentInset ?? .zero
        }
    }
    
    /// 占位视图提供者
    var placeholderProvider: TPPlaceholderProviding? {
        didSet {
            updatePlaceholderView()
        }
    }
    
    /// 获取区块头视图对应的分区
    var scrollView: UIScrollView {
        return collectionView
    }

    /// 适配器
    private let adapter = TPCollectionViewAdapter()
    
    /// 下拉刷新控件
    private(set) var refreshControl: UIRefreshControl?
    
    /// 布局对象
    private lazy var collectionViewLayout:
    UICollectionViewLeftAlignedLayout = {
        let layout = UICollectionViewLeftAlignedLayout()
        layout.scrollDirection = .vertical
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .clear
        collectionView.isPrefetchingEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.shouldShowPlaceholder = { [weak self] in
            return self?.shouldShowPlaceholder() ?? false
        }
        
        return collectionView
    }()
    
    /// 是否处于排序模式。进入后组件抖动并支持拖动排序，同时关闭长按菜单避免冲突。
    private(set) var isReordering: Bool = false
    
    /// 拖动排序器
    private var reorder: TPCollectionDragExchangeReorder?

    /// 区块布局。小 / 中 / 大组件尺寸均由容器宽度推导
    private lazy var dashboardLayout: WSDashboardLayout = {
        return WSDashboardLayout()
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemGroupedBackground
        self.setupSubviews()
        self.setupReorder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        adapter.dataSource = self
        adapter.delegate = self
        adapter.collectionView = collectionView
        addSubview(collectionView)
    }
    
    private func setupReorder() {
        let reorder = TPCollectionDragExchangeReorder(collectionView: collectionView)
        reorder.delegate = self
        /// 默认关闭，进入排序模式后再开启
        reorder.isEnabled = false
        self.reorder = reorder
    }
    
    /// 添加下拉刷新控件
    func addRefreshControl() {
        guard refreshControl == nil else {
            return
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self,
                                 action: #selector(handleRefresh(_:)),
                                 for: .valueChanged)
        collectionView.refreshControl = refreshControl
        self.refreshControl = refreshControl
    }
    
    /// 结束刷新
    func endRefreshing() {
        refreshControl?.endRefreshing()
    }
    
    @objc private func handleRefresh(_ sender: UIRefreshControl) {
        handleRefresh()
    }
    
    /// 处理下拉刷新
    func handleRefresh() {

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }
    
    // MARK: - Public Methods
    /// 是否显示占位视图
    func shouldShowPlaceholder() -> Bool {
        guard adapter.objects.count > 0 else {
            return true
        }
        
        return false
    }
    
    /// 更新占位视图
    func updatePlaceholderView() {
        collectionView.placeholderView = placeholderProvider?.placeholderView()
    }
    
    /// 重新加载数据
    func reloadData() {
        updatePlaceholderView()
        adapter.reloadData()
    }
    
    func reloadDataIfNeeded() {
        if adapter.needsReload {
            reloadData()
        }
    }
    
    /// 更新列表
    func performUpdate(animated: Bool = false) {
        updatePlaceholderView()
        adapter.performUpdate()
    }
    
    // MARK: - 排序模式
    /// 进入排序模式。组件抖动并支持长按拖动排序，同时关闭长按菜单避免与拖动冲突。
    func beginReordering() {
        setReordering(true)
    }
    
    /// 退出排序模式
    func endReordering() {
        setReordering(false)
    }
    
    private func setReordering(_ isReordering: Bool) {
        guard self.isReordering != isReordering else {
            return
        }
        
        self.isReordering = isReordering
        /// 仅在排序模式下开启拖动排序
        reorder?.isEnabled = isReordering
        collectionView.visibleCells.forEach { updateCellForReordering($0) }
        delegate?.dashboardView(self, didChangeReordering: isReordering)
    }
    
    /// 应用排序模式到单元格
    private func updateCellForReordering(_ cell: UICollectionViewCell) {
        guard let cell = cell as? WSPluginCell else {
            return
        }
        
        cell.isContextMenuEnabled = !isReordering
        cell.setJiggling(isReordering)
    }
    
    // MARK: - Plugins
    /// 索引位置对应的组件
    private func plugin(at indexPath: IndexPath) -> WSPlugin? {
        guard let plugins = plugins, indexPath.item < plugins.count else {
            return nil
        }
        
        return plugins[indexPath.item]
    }
    
    // MARK: - TPCollectionViewAdapterDataSource
    func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        return [String(describing: type(of: self)) as NSString]
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        return plugins
    }
    
    // MARK: - TPCollectionViewAdapterDelegate
    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        /// 排序模式下不响应选中，避免误触
        guard !isReordering else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        /// 单元格类型由组件注册的提供者决定
        guard let plugin = self.plugin(at: indexPath) else {
            return WSPluginCell.self
        }
        
        return WSPluginRegistry.shared.provider(for: plugin.type)?.cellClass ?? WSPluginCell.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? WSPluginCell,
              let plugin = self.plugin(at: indexPath),
              let provider = WSPluginRegistry.shared.provider(for: plugin.type) else {
            return
        }
        
        cell.configure(plugin: plugin, provider: provider)
        cell.menuActionHandler = { [weak self] cell, actionType in
            guard let self = self, let plugin = cell.plugin else {
                return
            }
            
            self.delegate?.dashboardView(self,
                                         didSelectMenuAction: actionType,
                                         for: plugin)
        }
        updateCellForReordering(cell)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        dashboardLayout.updateLayoutIfNeeded(containerSize: adapter.collectionViewSize())
        guard let plugin = self.plugin(at: indexPath) else {
            return .zero
        }
        
        return dashboardLayout.itemSize(for: plugin)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, insetForSectionAt section: Int) -> UIEdgeInsets {
        /// 内边距会先于条目尺寸被查询，先同步容器尺寸以保证本趟布局拿到正确的内边距
        dashboardLayout.updateLayoutIfNeeded(containerSize: adapter.collectionViewSize())
        return dashboardLayout.sectionInset
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, lineSpacingForSectionAt section: Int) -> CGFloat {
        return dashboardLayout.lineSpacing
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, interitemSpacingForSectionAt section: Int) -> CGFloat {
        return dashboardLayout.interitemSpacing
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}

// MARK: - TPCollectionDragExchangeReorderDelegate
extension WSDashboardView: TPCollectionDragExchangeReorderDelegate {
    
    func collectionDragReorder(_ reorder: TPCollectionDragReorder, canMoveItemAt indexPath: IndexPath) -> Bool {
        return isReordering
    }
    
    func collectionDragReorder(_ reorder: TPCollectionDragReorder, willBeginAt indexPath: IndexPath) {
        /// 拖动期间暂停被拖动项的抖动，避免拖拽快照带上旋转
        (collectionView.cellForItem(at: indexPath) as? WSPluginCell)?.setJiggling(false)
    }
    
    func collectionDragReorderDidEnd(_ reorder: TPCollectionDragReorder) {
        /// 拖动结束后恢复抖动
        collectionView.visibleCells.forEach { updateCellForReordering($0) }
    }
    
    func collectionDragExchangeReorder(_ reorder: TPCollectionDragExchangeReorder,
                                       canMoveItemFrom fromIndexPath: IndexPath,
                                       to toIndexPath: IndexPath) -> Bool {
        return isReordering && fromIndexPath.section == toIndexPath.section
    }
    
    func collectionDragExchangeReorder(_ reorder: TPCollectionDragExchangeReorder,
                                       moveItemFrom fromIndexPath: IndexPath,
                                       to toIndexPath: IndexPath) -> Bool {
        guard var newPlugins = plugins else {
            return false
        }
        
        guard newPlugins.moveObject(fromIndex: fromIndexPath.item, toIndex: toIndexPath.item) else {
            return false
        }
        
        self.plugins = newPlugins
        adapter.moveItem(at: fromIndexPath, to: toIndexPath)
        return true
    }
}
