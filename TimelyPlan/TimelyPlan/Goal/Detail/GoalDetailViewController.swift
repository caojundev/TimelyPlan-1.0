//
//  GoalDetailViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/30.
//

import Foundation
import UIKit

class GoalDetailViewController: TPMultiColumnDetailViewController {
    
    struct Config {
        /// 添加视图按钮
        static let addViewSize = CGSize(width: 50.0, height: 50.0)
        /// 添加视图边界间距
        static let addViewMargins = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 20.0)
    }

    /// 添加视图
    private var addView: TPAddView?
    
    /// 标题视图
    private lazy var titleView: TPImageTitleView = {
        let view = TPImageTitleView()
        view.padding = .zero
        view.titleConfig.font = BOLD_SYSTEM_FONT
        view.titleConfig.textAlignment = .center
        return view
    }()
    
    /// 更多按钮
    private lazy var moreBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(customView: moreButton)
    }()
    
    private lazy var moreButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.padding = UIEdgeInsets(horizontal: 5.0)
        button.image = resGetImage("ellipsis_24")
        button.imageConfig.color = resGetColor(.title)
        button.addTarget(self, action: #selector(clickMore(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    
    let interactor: GoalPlanInteractor
    
    init(configuration: GoalPlanConfiguration) {
        self.interactor = GoalPlanInteractor(configuration: configuration)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = titleView
        navigationItem.rightBarButtonItem = moreBarButtonItem
        updateTitle()
        setupAddView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutAddView()
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
    
    // MARK: - Update
    /// 更新标题
    private func updateTitle() {
        titleView.title = interactor.title()
        titleView.sizeToFit()
    }
    
    // MARK: - Event Response
    /// 点击更多
    @objc func clickMore(_ button: UIButton) {
        guard let config = self.interactor.planOptionConfig() else {
            return
        }

        let optionMenuController = GoalPlanOptionMenuController(config: config)
        optionMenuController.didSelectPlanOption = { [weak self] option in
//            self?.selectListOption(option)
        }
        
        optionMenuController.didSelectGroupType = { [weak self] groupType in
//            self?.selectGroupType(groupType)
        }
        
        optionMenuController.didSelectSortType = { [weak self] sortType in
//            self?.selectSortType(sortType)
        }
        
        optionMenuController.didSelectSortOrder = { [weak self] sortOrder in
//            self?.selectSortOrder(sortOrder)
        }
        
        let menuItems = optionMenuController.menuItems()
        let menuController = TPLevelMenuViewController(menuItems: menuItems)
        let sourceRect = CGRect(x: moreButton.bounds.maxX,
                                y: moreButton.bounds.maxY,
                                size: .zero)
        menuController.show(from: moreButton, sourceRect: sourceRect, isCovered: false)
    }
    
    /// 点击添加目标
    private func clickAddGoal() {
        TPImpactFeedback.impactWithLightStyle()
        GoalPresenter.createNewGoalPlan()
    }
    
    func canAddGoal() -> Bool {
        return true
    }
}
