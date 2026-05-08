//
//  QuadrantDetailViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/14.
//

import Foundation

class QuadrantDetailViewController: TodoBaseTaskListViewController {
    
    /// 标题视图
    private lazy var titleView: TPInfoView = {
        let view = TPInfoView()
        view.padding = .zero
        view.titleConfig.font = BOLD_SYSTEM_FONT
        view.titleConfig.textAlignment = .center
        view.subtitleConfig.textAlignment = .center
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = titleView
        self.updateTitle()
        self.updateBarButtonItems()
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarTintColor: UIColor? {
        return resGetColor(.title)
    }
    
    /// 更新标题
    private func updateTitle() {
        titleView.title = navigationTitle
        titleView.sizeToFit()
    }
    
    /// 更新副标题
    private func updateSubtitle() {
        titleView.subtitle = navigationSubtitle
        titleView.sizeToFit()
    }

    /// 更新导航栏按钮
    func updateBarButtonItems() {
        navigationItem.leftBarButtonItems = navigationLeftBarButtonItems
        navigationItem.rightBarButtonItems = navigationRightBarButtonItems
    }
    
    override func setSelecting(_ isSelecting: Bool) {
        super.setSelecting(isSelecting)
        updateBarButtonItems()
        updateSubtitle()
    }
    
    override func didChangeSelectedTasks() {
        super.didChangeSelectedTasks()
        self.updateSubtitle()
        self.updateBarButtonItems()
    }
    
    override func performEditOption() {
        guard let configuration = interactor.configuration as? QuadrantListConfiguration else {
            return
        }
        
        /// 编辑象限
        let quadrant = configuration.quadrant
        let rule = configuration.filterRule
        let vc = QuadrantFilterRuleEditViewController(quadrant: quadrant, rule: rule)
        vc.didEndEditing = { newRule in
            self.changeEditingRule(newRule, for: quadrant)
        }
        
        vc.showAsNavigationRoot()
    }
    
    private func changeEditingRule(_ rule: TodoFilterRule, for quadrant: Quadrant) {
        guard rule.isValid,
              let interactor = self.interactor as? QuadrantDetailListInteractor,
              interactor.filterRule != rule else {
            return
        }
        
        /// 保存到设置
        QuadrantSetting.shared.setFilterRule(rule, for: quadrant)
        
        /// 更新过滤规则，重新加载分组
        interactor.updateFilterRule(rule)
        interactor.setNeedsRefresh()
        interactor.loadGroups()
    }
}
