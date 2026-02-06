//
//  FocusRecordEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/27.
//

import Foundation
import UIKit

class FocusRecordEditViewController: TPTableSectionsViewController {
    
    /// 记录
    var record: FocusRecord
    
    /// 结束编辑回调
    var didEndEditing: ((FocusRecord) -> Void)?
    
    /// 编辑类型
    private var editType: EditType
    
    /// 绑定计时器和任务
    lazy var bindSectionController: FocusRecordEditBindSectionController = {
        let sectionController = FocusRecordEditBindSectionController()
        sectionController.timer = record.timer
        sectionController.didSelectTimer = { [weak self] timer in
            self?.record.timer = timer
        }
        
        sectionController.didSelectTask = { [weak self] task in
            self?.record.task = task
        }
        
        return sectionController
    }()

    /// 时间线
    lazy var timelineSectionController: FocusRecordEditTimelineSectionController = {
        let sectionController = FocusRecordEditTimelineSectionController(timeline: self.record.timeline)
        sectionController.didChangeTimeline = { [weak self] timeline in
            self?.record.timeline = timeline
        }
        
        return sectionController
    }()
    
    /// 评分
    lazy var scoreSectionController: FocusRecordEditScoreSectionController = {
        let sectionController = FocusRecordEditScoreSectionController()
        sectionController.score = self.record.score
        sectionController.didSelectScore = { [weak self] score in
            self?.record.score = score
        }

        return sectionController
    }()

    /// 备注
    lazy var noteSectionController: TPNoteTableSectionController = { [weak self] in
        let sectionController = TPNoteTableSectionController()
        sectionController.noteCellItem.updater = {
            self?.noteSectionController.note = self?.record.note
        }

        sectionController.noteEditingChanged = { note in
            self?.record.note = note
        }

        return sectionController
    }()
    
    init(record: FocusRecord? = nil, editType: EditType = .create) {
        self.record = record ?? FocusRecord()
        self.editType = editType
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if editType == .create {
            self.title = resGetString("Add Focus Record")
        } else {
            self.title = resGetString("Edit Focus Record")
        }
        
        navigationItem.leftBarButtonItem = self.chevronDownCancelButtonItem
        navigationItem.rightBarButtonItem = self.saveButtonItem
        wrapperView.isKeyboardAdjusterEnabled = true /// 键盘自动调整开启
        tableView.keyboardDismissMode = .interactive
        sectionControllers = [bindSectionController,
                              timelineSectionController,
                              scoreSectionController,
                              noteSectionController
        ]
        
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    
    override func didClickSave() {
        didEndEditing?(record)
        dismiss(animated: true, completion: nil)
    }
}
