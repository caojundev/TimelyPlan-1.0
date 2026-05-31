//
//  TodoStepImporterPreviewViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/22.
//

import Foundation
import UIKit

class TodoStepImporterPreviewViewController: TPTableSectionsViewController {
    
    var completion: (([TodoStep]) -> Void)?
    
    var editSectionController: TodoStepEditSectionController!
    
    init(steps: [TodoStep]) {
        super.init(style: .insetGrouped)
        setupEditSectionController(steps: steps)
        
        let footerItem = self.editSectionController.footerItem
        footerItem.height = 40.0
        footerItem.title = footerTitle()
        footerItem.titleConfig.font = .systemFont(ofSize: 12.0)
        footerItem.titleConfig.textColor = .secondaryLabel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupEditSectionController(steps: [TodoStep]) {
        self.editSectionController = TodoImporterStepEditSectionController(steps: steps)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = navigationTitle()
        wrapperView.isKeyboardAdjusterEnabled = true /// 键盘自动调整开启
        tableView.keyboardDismissMode = .interactive
        setupReorder()
        setupActionsBar(actions: [doneAction])
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        sectionControllers = [editSectionController]
        reloadData()
    }

    func navigationTitle() -> String? {
        return resGetString("Steps Preview")
    }

    func footerTitle() -> String? {
        return resGetString("Tap to edit, hold and drag to reorder or change level")
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func clickDone() {
        let steps = editSectionController.steps
        for step in steps.flatten() {
            step.isExpanded = true
        }
        
        completion?(steps)
        dismiss(animated: true, completion: nil)
    }
    
    /// 排序管理器
    private var reorder: TPTableDragInsertReorder?
    
    /// 初始化排序管理器
    private func setupReorder() {
        let reorder = TPTableDragInsertReorder(tableView: adapter.tableView)
        reorder.indicatorBackColor = Color(0xFFFFFF, 0.1)
        reorder.isEnabled = true
        reorder.delegate = self.editSectionController
        self.reorder = reorder
    }
    
}
