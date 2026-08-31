//
//  GoalHomeViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/30.
//

import Foundation
import UIKit

class GoalHomeViewController: TPViewController,
                              TPSidebarContent,
                              GoalPlanListViewDelegate {
    
    struct Config {
        /// 添加视图按钮
        static let addViewSize = CGSize(width: 50.0, height: 50.0)
        /// 添加视图边界间距
        static let addViewMargins = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 20.0)
    }
    
    /// 侧边栏控制器
    var sidebarController: SidebarController?
    
    /// 详情协调器
    private let detailCoordinator: GoalDetailCoordinator?
    
    /// 目标计划视图模型
    private let viewModel = GoalPlanViewModel()
    
    /// 更多菜单按钮
    private lazy var moreBarButtonItem: GoalMoreBarButtonItem = {
        let item = GoalMoreBarButtonItem()
        item.didSelectType = { [weak self] type in
            self?.performMoreMenuAction(type)
        }
        
        return item
    }()
    
    /// 添加视图
    private var addView: TPAddView?
    
    /// 目标计划列表视图
    lazy var listView: GoalPlanListView = {
        let listView = GoalPlanListView(frame: .zero)
        listView.delegate = self
        listView.isReorderEnabled = true
        listView.placeholderProvider = viewModel.placeholderProvider
        return listView
    }()
    
    init(detailCoordinator: GoalDetailCoordinator? = nil) {
        self.detailCoordinator = detailCoordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.detailCoordinator = nil
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Goal")
        navigationItem.leftBarButtonItem = sidebarController?.newMenuButtonItem()
        navigationItem.rightBarButtonItems = [moreBarButtonItem]
        setupListView()
        setupAddView()
        
        self.viewModel.goalPlansDidChange = { [weak self] change in
            self?.goalPlansChanged(change)
        }
        self.viewModel.loadGoalPlans()
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
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    // MARK: - 添加视图
    private func setupAddView() {
        if canAddGoal() {
            let addView = TPAddView()
            addView.normalBackgroundColor = .primary
            addView.didClickAdd = { [weak self] _ in
                self?.clickAddGoal()
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
    
    // MARK: - 列表视图
    private func setupListView() {
        view.addSubview(listView)
        listView.reloadData()
    }
    
    private func layoutListView() {
        let layoutFrame = view.safeAreaFrame()
        listView.frame = view.bounds
        let insetBottom = layoutFrame.maxY - (addView?.top ?? layoutFrame.maxY)
        listView.contentInset = UIEdgeInsets(top: 0.0,
                                             left: 0.0,
                                             bottom: max(insetBottom, 0.0),
                                             right: 0.0)
    }
    
    /// 加载并刷新目标计划
    private func reloadGoalPlans() {
        let group = GoalPlanGroup(identifier: "GoalPlanGroup")
        group.goalPlans = viewModel.goalPlans
        listView.groups = [group]
        listView.performUpdate()
    }
    
    /// 处理目标计划变更
    private func goalPlansChanged(_ change: GoalPlanChange?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.reloadGoalPlans()
            
            var revealGoalPlan: GoalPlan?
            if let change = change {
                switch change {
                case .create(let goalPlan), .update(let goalPlan):
                    revealGoalPlan = goalPlan
                default:
                    break
                }
            }
            
            if let revealGoalPlan = revealGoalPlan {
                self.listView.revealItem(revealGoalPlan, autoScroll: true)
            }
        }
    }
    
    // MARK: - Event Response
    /// 执行更多菜单操作
    func performMoreMenuAction(_ type: GoalMoreMenuType) {
        switch type {
        case .archived:
            GoalPresenter.showArchived()
            break
        case .settings:
            GoalPresenter.showSetting()
            break
        }
    }
    
    /// 点击添加目标
    private func clickAddGoal() {
        TPImpactFeedback.impactWithLightStyle()
        GoalPresenter.createNewGoalPlan()
    }
    
    func canAddGoal() -> Bool {
        return true
    }
    
    // MARK: - GoalPlanListViewDelegate
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        if let goalPlan = collectionView.item(at: indexPath) as? GoalPlan {
            detailCoordinator?.showDetail(for: goalPlan)
        }
    }
    
    func goalPlanListView(_ listView: GoalPlanListView, moveItemAt sourceIndexPath: IndexPath, to targetIndexPath: IndexPath) {
        guard let goalPlans = listView.items(for: targetIndexPath.section) as? [GoalPlan] else {
            return
        }
        
        GoalRepository.reorderGoalPlan(in: goalPlans,
                                       fromIndex: sourceIndexPath.item,
                                       toIndex: targetIndexPath.item)
    }
    
    func goalPlanListViewHandleRefresh(_ listView: GoalPlanListView) {
        self.viewModel.setNeedsRefresh()
        self.viewModel.loadGoalPlans()
    }
}
