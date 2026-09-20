//
//  CountdownEventListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/17.
//

import Foundation
import UIKit

/// 倒数日事项列表内容视图控制器
class CountdownEventListViewController: TPViewController,
                                        CountdownEventListViewDelegate {
    
    struct Config {
        /// 添加视图按钮
        static let addViewSize = CGSize(width: 50.0, height: 50.0)
        /// 添加视图边界间距
        static let addViewMargins = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 20.0)
        /// 筛选视图高度
        static let filterViewHeight: CGFloat = 40.0
    }
    
    /// 倒数日事项视图模型
    private let viewModel = CountdownEventViewModel()
    
    /// 布局类型（默认为列表）
    var layoutType: CountdownLayoutType = .list {
        didSet {
            listView.layoutType = layoutType
        }
    }
    
    /// 添加视图
    private var addView: TPAddView?
    
    /// 倒数日事项列表视图
    lazy var listView: CountdownEventListView = {
        let listView = CountdownEventListView(frame: .zero)
        listView.delegate = self
        listView.isReorderEnabled = true
        listView.placeholderProvider = viewModel.placeholderProvider
        return listView
    }()
    
    /// 筛选视图
    lazy var filterView: CountdownTypeFilterView = {
        let filterView = CountdownTypeFilterView(frame: .zero)
        filterView.didSelectFilterType = { [weak self] type in
            self?.selectFilterType(type)
        }
        
        /// 展示各筛选类型的事项数目
        filterView.countProvider = { [weak self] filterType in
            return self?.viewModel.numberOfEvents(for: filterType) ?? 0
        }
        
        return filterView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFilterView()
        setupListView()
        setupAddView()
        
        self.viewModel.eventsDidChange = { [weak self] change in
            self?.eventsChanged(change)
        }
        self.viewModel.filterTypeDidChange = { [weak self] in
            self?.reloadFilteredEvents()
        }
        self.viewModel.loadEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listView.reloadDataIfNeeded()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutAddView()
        layoutFilterView()
        layoutListView()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - 筛选视图
    private func setupFilterView() {
        view.addSubview(filterView)
    }
    
    private func layoutFilterView() {
        let layoutFrame = view.safeAreaFrame()
        filterView.frame = CGRect(x: layoutFrame.minX,
                                  y: layoutFrame.minY,
                                  width: layoutFrame.width,
                                  height: Config.filterViewHeight)
    }
    
    /// 选择筛选类型
    private func selectFilterType(_ filterType: CountdownTypeFilterType) {
        viewModel.updateFilterType(filterType)
    }
    
    /// 按筛选结果刷新倒数日事项
    private func reloadFilteredEvents() {
        /// 非“所有”状态下不允许拖拽排序，避免破坏原始顺序
        listView.isReorderEnabled = viewModel.filterType == .all
        reloadEvents()
    }
    
    // MARK: - 列表视图
    private func setupListView() {
        view.addSubview(listView)
        listView.reloadData()
    }
    
    private func layoutListView() {
        let layoutFrame = view.safeAreaFrame()
        let top = filterView.frame.maxY
        listView.frame = CGRect(x: layoutFrame.minX,
                                y: top,
                                width: layoutFrame.width,
                                height: max(0.0, layoutFrame.maxY - top))
        
        /// 底部留出添加按钮的空间
        let insetBottom = layoutFrame.maxY - (addView?.top ?? layoutFrame.maxY)
        listView.contentInset = UIEdgeInsets(top: 0.0,
                                             left: 0.0,
                                             bottom: max(insetBottom, 0.0),
                                             right: 0.0)
    }
    
    /// 加载并刷新倒数日事项
    private func reloadEvents() {
        listView.groups = viewModel.groups
        listView.performUpdate()
    }
    
    /// 处理倒数日事项变更
    private func eventsChanged(_ change: CountdownEventChange?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.reloadEvents()
            /// 事项数目随数据变化，刷新筛选视图
            self.filterView.reloadData()
            
            var revealEvent: CountdownEvent?
            if let change = change {
                switch change {
                case .create(let event), .update(let event):
                    revealEvent = event
                }
            }
            
            if let revealEvent = revealEvent {
                self.revealEvent(revealEvent)
            }
        }
    }
    
    // MARK: - Public Methods
    /// 显示特定倒数日事项
    func revealEvent(_ event: CountdownEvent) {
        listView.revealItem(event, autoScroll: true)
    }
    
    // MARK: - 添加视图
    private func setupAddView() {
        if canAddCountdown() {
            let addView = TPAddView()
            addView.normalBackgroundColor = .primary
            addView.didClickAdd = { [weak self] _ in
                self?.clickAddCountdown()
            }
            
            self.addView = addView
            self.view.insertSubview(addView, at: 999)
        }
    }
    
    private func layoutAddView() {
        let layoutFrame = view.safeAreaFrame()
        if let addView = addView {
            addView.size = Config.addViewSize
            addView.bottom = layoutFrame.maxY - Config.addViewMargins.bottom
            addView.right = layoutFrame.maxX - Config.addViewMargins.right
        }
    }
    
    /// 点击添加倒数日
    private func clickAddCountdown() {
        guard let addView = addView, let keyWindow = UIWindow.keyWindow else {
            return
        }
        
        TPImpactFeedback.impactWithLightStyle()
        
        let bubbleMenu = BubbleMenuView(
            menuItems: CountdownEventType.bubbleMenuItems,
            containerView: keyWindow,
            sourceView: addView
        )
        
        bubbleMenu.onSelectMenuItem = { menuItem in
            guard let type = CountdownEventType.type(for: menuItem) else {
                return
            }
            
            CountdownPresenter.createNewEvent(type: type)
        }
        
        bubbleMenu.show()
    }
    
    func canAddCountdown() -> Bool {
        return true
    }
    
    // MARK: - CountdownEventListViewDelegate
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        if let event = collectionView.item(at: indexPath) as? CountdownEvent {
            CountdownPresenter.showDetail(for: event)
        }
    }
    
    func countdownEventListView(_ listView: CountdownEventListView,
                                moveItemAt sourceIndexPath: IndexPath,
                                to targetIndexPath: IndexPath) -> Bool {
        return viewModel.moveEvent(at: sourceIndexPath, to: targetIndexPath)
    }
    
    func countdownEventListViewDidEndReordering(_ listView: CountdownEventListView) {
        viewModel.didEndReorderEvents(with: listView.events)
    }
    
    func countdownEventListViewHandleRefresh(_ listView: CountdownEventListView) {
        viewModel.setNeedsRefresh()
        viewModel.loadEvents()
    }
}
