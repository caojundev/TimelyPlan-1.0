//
//  GoalTaskNoteActionViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/9.
//

import Foundation
import UIKit

/// 目标任务「备注」操作内容视图控制器
class GoalTaskNoteActionViewController: TPTableSectionsViewController,
                                        GoalTaskEditInteractorObserver {
    
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
        self.wrapperView.isKeyboardAdjusterEnabled = true
        self.tableView.keyboardDismissMode = .onDrag
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.sectionControllers = [noteSectionController]
        self.adapter.reloadData()
    }
    
    // MARK: - GoalTaskEditInteractorObserver

    /// 任务改变：备注变化时刷新
    /// - Note: 正在输入时文本已同步到单元格，内容一致，不会打断编辑
    func goalTaskEditInteractor(_ interactor: GoalTaskEditInteractor,
                                didUpdateTask task: GoalTask,
                                with change: GoalTaskChange?) {
        guard task.note != noteSectionController.note else {
            return
        }

        noteSectionController.note = task.note
        noteSectionController.updateNote()
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
}
