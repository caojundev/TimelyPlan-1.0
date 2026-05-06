//
//  QuadrantFilterRuleEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/21.
//

import Foundation

class QuadrantFilterRuleEditViewController: TodoFilterRuleEditViewController {
    
    /// 标题视图
    private lazy var titleView: TPImageInfoView = {
        let view = TPImageInfoView()
        view.padding = .zero
        view.titleConfig.font = BOLD_SYSTEM_FONT
        view.titleConfig.textAlignment = .center
        return view
    }()
    
    private(set) var quadrant: Quadrant
    
    init(quadrant: Quadrant, rule: TodoFilterRule?) {
        self.quadrant = quadrant
        super.init(rule: rule)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = titleView
        titleView.imageName = quadrant.iconName
        titleView.imageConfig.color = quadrant.color
        titleView.title = quadrant.title
        titleView.sizeToFit()
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        setupActionsBar(actions: [doneAction])
    }
    
    override func setupSectionControllers() {
        super.setupSectionControllers()
        /// 优先级禁用删除按钮
        prioritySectionController.isDeleteButtonEnabled = false
        if let index = sectionControllers?.firstIndex(of: prioritySectionController) {
            sectionControllers?.moveObject(fromIndex: index, toIndex: 0)
        }
    }
}
