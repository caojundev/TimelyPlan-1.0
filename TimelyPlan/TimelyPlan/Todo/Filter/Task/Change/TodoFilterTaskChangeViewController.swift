//
//  TodoFilterTaskChangeViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/17.
//

import Foundation

class TodoFilterTaskChangeViewController: TPTableSectionsViewController,
                                            TPTableSectionControllerDelegate {
    
    /// 移动任务
    private(set) var task: TodoTask
    
    /// 任务改变
    private(set) var changes: [TodoTaskChange]
    
    /// 已选中改变
    private var selectedChanges = Set<TodoTaskChange>()
    
    /// 标题视图
    private lazy var titleView: TPInfoView = {
        let view = TPInfoView()
        view.title = resGetString("Changes")
        view.padding = .zero
        view.titleConfig.font = BOLD_BODY_FONT
        view.titleConfig.textAlignment = .center
        view.subtitleConfig.textAlignment = .center
        return view
    }()
    
    init(task: TodoTask, changes: [TodoTaskChange]) {
        self.task = task
        self.changes = changes
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = titleView
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        setupActionsBar(actions: [doneAction])
        setupSectionControllers()
        reloadData()
        selectedItemsDidChange()
    }
    
    func selectedItemsDidChange() {
        let count = selectedChanges.count
        let format = resGetString("%ld selected")
        titleView.subtitle = String(format: format, count)
        titleView.sizeToFit()
        
        doneAction.isEnabled = count > 0
    }
    
    // MARK: - Update
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    private func setupSectionControllers() {
        var sectionControllers = [TPTableBaseSectionController]()
        for change in changes {
            if let sectionController = TodoFilterTaskChangeSectionController(change: change) {
                sectionController.delegate = self
                sectionControllers.append(sectionController)
                selectedChanges.insert(change)
            }
        }
        
        self.sectionControllers = sectionControllers
    }
    
    override func clickDone() {
        super.clickDone()
        todo.updateTask(task, withChanges: Array(selectedChanges))
    }
    
    // MARK: - TPTableSectionControllerDelegate
    func tableSectionController(_ sectionController: TPTableBaseSectionController, shouldShowCheckmarkForRowAt index: Int) -> Bool {
        guard let sectionController = sectionController as? TodoFilterTaskChangeSectionController else {
            return false
        }
        
        let change = sectionController.change
        return selectedChanges.contains(change)
    }
    
    func tableSectionController(_ sectionController: TPTableBaseSectionController, didSelectRowAt index: Int) {
        guard let sectionController = sectionController as? TodoFilterTaskChangeSectionController else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        
        let change = sectionController.change
        if selectedChanges.contains(change) {
            selectedChanges.remove(change)
        } else {
            selectedChanges.insert(change)
        }
        
        adapter.updateCheckmarks(animated: true)
        selectedItemsDidChange()
    }
}
