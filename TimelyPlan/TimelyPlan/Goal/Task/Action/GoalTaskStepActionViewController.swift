//
//  GoalTaskStepActionViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/9.
//

import Foundation
import UIKit

/// 目标任务「步骤」操作内容视图控制器
class GoalTaskStepActionViewController: TPTableSectionsViewController,
                                        GoalTaskEditInteractorObserver {
    
    /// 区块上方普通间距高度
    private static let normalHeaderHeight = 5.0
    
    /// 目标任务操作交互器
    private let interactor: GoalTaskEditInteractor
    
    /// 当前步骤列表（与编辑页保持一致）
    private var steps: [TodoStep]
    
    /// 步骤编辑区块
    lazy var stepSectionController: TodoStepInlineEditSectionController = { [weak self] in
        let steps = self?.steps ?? []
        let sectionController = TodoStepInlineEditSectionController(steps: steps)
        sectionController.headerItem.height = GoalTaskStepActionViewController.normalHeaderHeight
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
    
    init(interactor: GoalTaskEditInteractor) {
        self.interactor = interactor
        self.steps = interactor.task.steps ?? []
        super.init(style: .insetGrouped)
        interactor.addObserver(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        interactor.removeObserver(self)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    // MARK: - GoalTaskEditInteractorObserver

    /// 任务改变：步骤变化时刷新列表
    func goalTaskEditInteractor(_ interactor: GoalTaskEditInteractor,
                                didUpdateTask task: GoalTask,
                                with change: GoalTaskChange?) {
        let steps = task.steps ?? []

        /// 与当前步骤一致时无需刷新，避免打断正在进行的步骤编辑
        guard !GoalTaskStepActionViewController.isSameSteps(steps, self.steps) else {
            return
        }

        updateSteps(steps)
    }

    /// 用最新步骤刷新列表
    private func updateSteps(_ steps: [TodoStep]) {
        self.steps = steps
        stepSectionController.steps = steps
        adapter.reloadData()
    }

    /// 判断两组步骤是否一致（含子步骤）
    /// - Note: 步骤以 Markdown 存储，转为 Markdown 字符串比较，
    ///         既覆盖层级关系，也避免解析产生的新标识影响判断
    private static func isSameSteps(_ lhs: [TodoStep], _ rhs: [TodoStep]) -> Bool {
        let parser = TodoStepParser()
        let lhsMarkdown = parser.toMarkdown(lhs, forceExpanded: true)
        let rhsMarkdown = parser.toMarkdown(rhs, forceExpanded: true)
        return lhsMarkdown == rhsMarkdown
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
}
