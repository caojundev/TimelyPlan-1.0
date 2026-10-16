//
//  WorkspaceDashboardView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/15.
//

import Foundation
import UIKit

protocol WorkspaceDashboardViewDelegate: AnyObject {
    
}

extension WorkspaceDashboardViewDelegate {
    
}

class WorkspaceDashboardView: UIView,
                              TPCollectionViewAdapterDataSource,
                              TPCollectionViewAdapterDelegate {
    
    /// 代理对象
    weak var delegate: WorkspaceDashboardViewDelegate?
    
    var elements: [WSPluginElement]?
    
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
    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
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
    
    var reorderDelegate: TPCollectionDragInsertReorderDelegate? {
        get {
            return reorder?.delegate as? TPCollectionDragInsertReorderDelegate
        }
        
        set {
            reorder?.delegate = newValue
        }
    }
    
    private var reorder: TPCollectionDragExchangeReorder?

    /// 区块布局。小 / 中 / 大组件尺寸均由容器宽度推导
    private lazy var dashboardLayout: WorkspaceDashboardLayout = {
        return WorkspaceDashboardLayout()
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
    
    // MARK: - Elements
    /// 索引位置对应的组件
    private func element(at indexPath: IndexPath) -> WSPluginElement? {
        guard let elements = elements, indexPath.item < elements.count else {
            return nil
        }
        
        return elements[indexPath.item]
    }
    
    // MARK: - TPCollectionViewAdapterDataSource
    func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        return [String(describing: type(of: self)) as NSString]
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        return elements
    }
    
    // MARK: - TPCollectionViewAdapterDelegate
    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        /// 单元格类型由组件注册的提供者决定
        guard let element = element(at: indexPath) else {
            return WorkspacePluginCell.self
        }
        
        return WSPluginRegistry.shared.provider(for: element.type)?.cellClass ?? WorkspacePluginCell.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? WorkspacePluginCell,
              let element = element(at: indexPath),
              let provider = WSPluginRegistry.shared.provider(for: element.type) else {
            return
        }
        
        cell.configure(element: element, provider: provider)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        dashboardLayout.updateLayoutIfNeeded(containerSize: adapter.collectionViewSize())
        guard let element = element(at: indexPath) else {
            return .zero
        }
        
        return dashboardLayout.itemSize(for: element)
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
