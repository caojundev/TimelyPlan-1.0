//
//  GoalTaskStepActionViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/9.
//

import Foundation
import UIKit

/// 目标任务「步骤」操作内容视图控制器
class GoalTaskStepActionViewController: TPTableSectionsViewController {
    
    /// 区块上方普通间距高度
    private static let normalHeaderHeight = 5.0
    
    /// 目标任务操作交互器
    private let interactor: GoalTaskEditInteractor
    
    /// 当前步骤列表（与编辑页保持一致）
    private var steps: [TodoStep]
    
    /// 步骤编辑区块
    lazy var stepSectionController: GoalStepEditSectionController = { [weak self] in
        let steps = self?.steps ?? []
        let sectionController = GoalStepEditSectionController(steps: steps)
        sectionController.headerItem.height = GoalTaskStepActionViewController.normalHeaderHeight
        sectionController.footerItem.height = 0.0
        sectionController.onStepsChanged = { [weak self] steps in
            guard let self = self else { return }
            self.steps = steps
            self.interactor.setSteps(steps)
        }
        
        return sectionController
    }()
    
    init(interactor: GoalTaskEditInteractor) {
        self.interactor = interactor
        self.steps = interactor.task.steps ?? []
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.wrapperView.isKeyboardAdjusterEnabled = true
        self.tableView.keyboardDismissMode = .onDrag
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.sectionControllers = [stepSectionController]
        self.adapter.reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
}
