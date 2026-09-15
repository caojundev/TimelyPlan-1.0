//
//  CountdownMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/13.
//

import Foundation
import UIKit

class CountdownMainViewController: TPViewController,
                                    TPSidebarContent,
                                    CountdownEventListViewDelegate {
    
    struct Config {
        /// 添加视图按钮
        static let addViewSize = CGSize(width: 50.0, height: 50.0)
        /// 添加视图边界间距
        static let addViewMargins = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 20.0)
    }
    
    /// 侧边栏控制器
    var sidebarController: SidebarController?
    
    /// 倒数日事项视图模型
    private let viewModel = CountdownEventViewModel()
    
    /// 更多菜单按钮
    private lazy var moreBarButtonItem: CountdownMoreBarButtonItem = {
        let item = CountdownMoreBarButtonItem()
        item.didSelectType = { [weak self] type in
            self?.performMoreMenuAction(type)
        }
        
        return item
    }()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Countdown")
        navigationItem.leftBarButtonItem = sidebarController?.newMenuButtonItem()
        navigationItem.rightBarButtonItems = [moreBarButtonItem]
        setupListView()
        setupAddView()
        
        self.viewModel.eventsDidChange = { [weak self] change in
            self?.eventsChanged(change)
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
        layoutListView()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    // MARK: - 列表视图
    private func setupListView() {
        view.addSubview(listView)
        listView.reloadData()
    }
    
    private func layoutListView() {
        let layoutFrame = view.safeAreaFrame()
        listView.frame = CGRect(x: layoutFrame.minX,
                                y: layoutFrame.minY,
                                width: layoutFrame.width,
                                height: layoutFrame.height)
        
        /// 底部留出添加按钮的空间
        let insetBottom = layoutFrame.maxY - (addView?.top ?? layoutFrame.maxY)
        listView.contentInset = UIEdgeInsets(top: 0.0,
                                             left: 0.0,
                                             bottom: max(insetBottom, 0.0),
                                             right: 0.0)
    }
    
    /// 加载并刷新倒数日事项
    private func reloadEvents() {
        let group = CountdownEventGroup(identifier: "CountdownEventGroup")
        group.events = viewModel.events
        listView.groups = [group]
        listView.performUpdate()
    }
    
    /// 处理倒数日事项变更
    private func eventsChanged(_ change: CountdownEventChange?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.reloadEvents()
            
            var revealEvent: CountdownEvent?
            if let change = change {
                switch change {
                case .create(let event), .update(let event):
                    revealEvent = event
                }
            }
            
            if let revealEvent = revealEvent {
                self.listView.revealItem(revealEvent, autoScroll: true)
            }
        }
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
        guard let addView = addView else {
            return
        }
        
        TPImpactFeedback.impactWithLightStyle()
        
        // 创建气泡菜单视图（frame 传主视图的 bounds，triggerButtonFrame 传加号按钮的 frame）
        let bubbleMenu = BubbleMenuView(
            frame: view.bounds,
            triggerButtonFrame: addView.frame,
            menuItems: CountdownEventType.bubbleMenuItems
        )
        
        bubbleMenu.onSelectMenuItem = { menuItem in
            guard let type = CountdownEventType.type(for: menuItem) else {
                return
            }
            
            CountdownPresenter.createNewEvent(type: type)
        }
        
        // 添加到主视图并展示
        bubbleMenu.show(in: self.view)
    }
    
    func canAddCountdown() -> Bool {
        return true
    }
    
    // MARK: - Event Response
    /// 执行更多菜单操作
    func performMoreMenuAction(_ type: CountdownMoreMenuType) {
        switch type {
        case .archived:
            CountdownPresenter.showArchived()
            break
        }
    }
    
    // MARK: - CountdownEventListViewDelegate
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        if let event = collectionView.item(at: indexPath) as? CountdownEvent {
            CountdownPresenter.editEvent(event)
        }
    }
    
    func countdownEventListView(_ listView: CountdownEventListView,
                                moveItemAt sourceIndexPath: IndexPath,
                                to targetIndexPath: IndexPath) {
        guard let events = listView.items(for: targetIndexPath.section) as? [CountdownEvent] else {
            return
        }
        
        CountdownRepository.reorderEvent(in: events,
                                         fromIndex: sourceIndexPath.item,
                                         toIndex: targetIndexPath.item)
    }
    
    func countdownEventListViewHandleRefresh(_ listView: CountdownEventListView) {
        self.viewModel.setNeedsRefresh()
        self.viewModel.loadEvents()
    }
}
