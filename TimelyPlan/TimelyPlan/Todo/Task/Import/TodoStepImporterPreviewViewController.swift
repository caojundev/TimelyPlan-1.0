//
//  TodoStepImporterPreviewViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/22.
//

import Foundation
import UIKit

class TodoStepImporterPreviewViewController: TPTableSectionsViewController {
    
    let editSectionController: TodoStepEditSectionController
    
    init(steps: [TodoStep]) {
        self.editSectionController = TodoStepEditSectionController(steps: steps)
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Steps Preview")
        self.wrapperView.isKeyboardAdjusterEnabled = true /// 键盘自动调整开启
        self.tableView.keyboardDismissMode = .interactive
        self.setupReorder()
        self.setupActionsBar(actions: [doneAction])
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.sectionControllers = [editSectionController]
        self.reloadData()
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func clickDone() {
        self.dismiss(animated: true, completion: nil)
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
