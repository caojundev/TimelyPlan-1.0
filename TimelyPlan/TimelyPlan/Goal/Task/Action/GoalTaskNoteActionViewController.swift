//
//  GoalTaskNoteActionViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/9.
//

import Foundation
import UIKit

/// 目标任务「备注」操作内容视图控制器
class GoalTaskNoteActionViewController: TPTableSectionsViewController {
    
    /// 目标任务操作交互器
    private let interactor: GoalTaskEditInteractor
    
    /// 备注编辑区块
    lazy var noteSectionController: TPNoteTableSectionController = { [weak self] in
        let sectionController = TPNoteTableSectionController()
        sectionController.headerItem.title = nil
        sectionController.headerItem.height = 5.0
        sectionController.note = self?.interactor.task.note
        sectionController.noteEditingChanged = { [weak self] note in
            guard let self = self else { return }
            self.interactor.setNote(note)
        }
        
        return sectionController
    }()
    
    init(interactor: GoalTaskEditInteractor) {
        self.interactor = interactor
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
        self.sectionControllers = [noteSectionController]
        self.adapter.reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
}
