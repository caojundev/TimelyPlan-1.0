//
//  TodoSectionManageViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/3.
//

import Foundation

class TodoSectionManageViewController: TPTableSectionsViewController {
    
    lazy var addSectionAction: TPButtonAction = {
        let action = TPButtonAction(title:  resGetString("Add Section")) {  [weak self] action in
            self?.clickAddSection()
        }
        
        return action
    }()

    /// 排序管理器
    private var reorder: TPTableDragInsertReorder?
   
    private let sectionController: TodoSectionManageSectionController
    
    private let viewModel: TodoSectionViewModel
    
    init(list: TodoList?) {
        let viewModel = TodoSectionViewModel(list: list)
        self.viewModel = viewModel
        self.sectionController = TodoSectionManageSectionController(viewModel: viewModel)
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        title = resGetString("Manage Section")
        wrapperView.placeholderProvider = viewModel.placeholderProvider
        setupReorder()
        setupActionsBar(actions: [addSectionAction])
        sectionControllers = [sectionController]
        reloadData()
        viewModel.onSectionsChanged = { [weak self] change in
            self?.sectionsChanged(with: change)
        }
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    private func sectionsChanged(with change: TodoSectionChange?) {
        DispatchQueue.main.async {
            self.sectionController.sections = self.viewModel.sections
            self.wrapperView.performUpdate(with: .top)
            
            guard let change = change else {
                return
            }

            var animateSection: TodoSection?
            switch change {
            case .create(let section), .update(let section):
                animateSection = section
            }
            
            if let animateSection = animateSection {
                self.wrapperView.revealItem(animateSection, at: .middle, autoScroll: true)
            }
        }
    }
    
    /// 初始化排序管理器
    private func setupReorder() {
        let reorder = TPTableDragInsertReorder(tableView: adapter.tableView)
        reorder.indicatorBackColor = Color(0xFFFFFF, 0.1)
        reorder.isEnabled = true
        reorder.delegate = sectionController
        self.reorder = reorder
    }
    
    // MARK: - 添加 / 编辑板块
    private func clickAddSection() {
        sectionController.createNewSection()
    }
}

