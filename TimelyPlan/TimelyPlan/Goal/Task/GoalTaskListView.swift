//
//  GoalTaskListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/2.
//

import Foundation
import UIKit

protocol GoalTaskListViewDelegate: AnyObject {
    
    /// 通知列表选中目标任务
    func goalTaskListView(_ listView: GoalTaskListView, didSelectGoalTask goalTask: GoalTask)
    
    /// 点击目标任务的更多按钮
    func goalTaskListView(_ listView: GoalTaskListView, didClickMoreForGoalTask goalTask: GoalTask)
    
    /// 处理下拉刷新
    func goalTaskListViewHandleRefresh(_ listView: GoalTaskListView)
}

extension GoalTaskListViewDelegate {
    
    func goalTaskListView(_ listView: GoalTaskListView, didClickMoreForGoalTask goalTask: GoalTask) {}
}

class GoalTaskListView: UIView,
                        TPCollectionViewAdapterDataSource,
                        TPCollectionViewAdapterDelegate,
                        GoalTaskListCellDelegate {
    
    struct Config {
        /// 区块头高度
        static let headerHeight = 36.0
        /// 区块内间距
        static let sectionInset = UIEdgeInsets(top: 4.0, left: 15.0, bottom: 12.0, right: 15.0)
        /// 行间距
        static let lineSpacing = 8.0
    }
    
    /// 代理对象
    weak var delegate: GoalTaskListViewDelegate?
    
    /// 目标任务分组数组
    var groups: [GoalTaskGroup]?
    
    /// 内容间距
    var contentInset: UIEdgeInsets? {
        didSet {
            collectionView.contentInset = contentInset ?? .zero
        }
    }
    
    /// 是否显示占位视图
    var shouldShowPlaceholder: (() -> Bool)? {
        get {
            return collectionView.shouldShowPlaceholder
        }
        
        set {
            collectionView.shouldShowPlaceholder = newValue
        }
    }
    
    /// 占位视图提供者
    var placeholderProvider: TPPlaceholderProviding? {
        didSet {
            updatePlaceholderView()
        }
    }
    
    /// 单元格样式
    private let cellStyle = GoalTaskCellStyle()
    
    /// 适配器
    private let adapter = TPCollectionViewAdapter()
    
    /// 下拉刷新控件
    private(set) var refreshControl: UIRefreshControl?
    
    /// 布局对象
    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = Config.lineSpacing
        layout.sectionInset = Config.sectionInset
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .clear
        collectionView.isPrefetchingEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        adapter.dataSource = self
        adapter.delegate = self
        adapter.cellStyle = cellStyle
        adapter.collectionView = collectionView
        addSubview(collectionView)
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
        delegate?.goalTaskListViewHandleRefresh(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }
    
    // MARK: - Public Methods
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
    func performUpdate() {
        updatePlaceholderView()
        adapter.performUpdate()
    }
    
    /// 获取指定索引处的目标任务
    func goalTask(at indexPath: IndexPath) -> GoalTask? {
        return adapter.item(at: indexPath) as? GoalTask
    }
    
    /// 获取指定区块的分组
    func group(in section: Int) -> GoalTaskGroup? {
        return adapter.object(at: section) as? GoalTaskGroup
    }
    
    /// 聚焦显示目标任务
    func revealGoalTask(_ goalTask: GoalTask,
                        at scrollPosition: UICollectionView.ScrollPosition = .top,
                        autoScroll: Bool = true) {
        adapter.revealItem(goalTask, at: scrollPosition, autoScroll: autoScroll)
    }
    
    // MARK: - TPCollectionViewAdapterDataSource
    func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        return groups
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        guard let group = sectionObject as? GoalTaskGroup else {
            return nil
        }
        
        return group.goalTasks
    }
    
    // MARK: - TPCollectionViewAdapterDelegate
    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        guard let goalTask = goalTask(at: indexPath) else {
            return
        }
        
        delegate?.goalTaskListView(self, didSelectGoalTask: goalTask)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return GoalTaskListCell.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? GoalTaskListCell else {
            return
        }
        
        cell.delegate = self
        cell.cellStyle = cellStyle
        cell.goalTask = goalTask(at: indexPath)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionSize = adapter.collectionViewSize()
        let sectionInset = self.adapter(adapter, insetForSectionAt: indexPath.section)
        let width = min(GoalConfig.goalPlanListContentMaxWidth,
                        collectionSize.width - sectionInset.horizontalLength)
        return CGSize(width: width, height: 70.0)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, insetForSectionAt section: Int) -> UIEdgeInsets {
        return Config.sectionInset
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, lineSpacingForSectionAt section: Int) -> CGFloat {
        return Config.lineSpacing
    }
    
    // MARK: - Header Footer
    func adapter(_ adapter: TPCollectionViewAdapter, classForHeaderInSection section: Int) -> AnyClass? {
        return GoalTaskListHeaderView.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForHeaderInSection section: Int) -> CGSize {
        let collectionSize = adapter.collectionViewSize()
        return CGSize(width: collectionSize.width, height: Config.headerHeight)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeHeader headerView: UICollectionReusableView, inSection section: Int) {
        guard let headerView = headerView as? GoalTaskListHeaderView,
              let group = self.group(in: section) else {
            return
        }
        
        headerView.title = group.title
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
    
    // MARK: - GoalTaskListCellDelegate
    func goalTaskListCellDidClickMore(_ cell: GoalTaskListCell) {
        guard let goalTask = cell.goalTask else {
            return
        }
        
        delegate?.goalTaskListView(self, didClickMoreForGoalTask: goalTask)
    }
}
