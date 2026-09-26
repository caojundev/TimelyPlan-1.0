//
//  CountdownStepViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/26.
//

import Foundation
import UIKit

/// 倒数日事项「步骤」内容视图控制器
class CountdownStepViewController: TPTableSectionsViewController {
    
    /// 区块上方普通间距高度
    private static let normalHeaderHeight = 5.0
    
    /// 倒数日事项交互器
    private let interactor: CountdownEventInteractor
    
    /// 当前步骤列表（与详情页保持一致）
    private var steps: [TodoStep]
    
    /// 步骤编辑区块
    lazy var stepSectionController: TodoStepInlineEditSectionController = { [weak self] in
        let steps = self?.steps ?? []
        let sectionController = TodoStepInlineEditSectionController(steps: steps)
        sectionController.headerItem.height = CountdownStepViewController.normalHeaderHeight
        sectionController.footerItem.height = 0.0
        sectionController.onStepsChanged = { [weak self] steps in
            guard let self = self else { return }
            self.steps = steps
            self.interactor.setSteps(steps)
        }
        
        return sectionController
    }()
    
    /// 排序管理器
    private var reorder: TPTableDragInsertReorder?
    
    init(interactor: CountdownEventInteractor) {
        self.interactor = interactor
        self.steps = interactor.event.steps ?? []
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Step")
        wrapperView.isKeyboardAdjusterEnabled = true
        tableView.keyboardDismissMode = .onDrag
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        sectionControllers = [stepSectionController]
        adapter.reloadData()
        setupReorder()
    }
    
    /// 初始化排序管理器
    private func setupReorder() {
        let reorder = TPTableDragInsertReorder(tableView: adapter.tableView)
        reorder.indicatorBackColor = Color(0xFFFFFF, 0.1)
        reorder.isEnabled = true
        reorder.delegate = stepSectionController
        self.reorder = reorder
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
}
