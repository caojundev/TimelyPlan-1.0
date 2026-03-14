//
//  HabitRecordLogEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/10.
//

import Foundation
import UIKit

class HabitRecordLogEditViewController: TPTableSectionsViewController {
    
    /// 结束编辑回调
    var didEndEditing: ((HabitRecordLogInfo?) -> Void)?

    /// 编辑类型
    private var editType: EditType

    private let task: HabitTask
    
    private let status: HabitTaskStatus
    
    private let date: Date
    
    private var logInfo: HabitRecordLogInfo
    
    lazy var infoCellItem: HabitLogTaskInfoTableCellItem = {
        let cellItem = HabitLogTaskInfoTableCellItem()
        cellItem.updater = { [weak self] in
            guard let self = self else { return }
            self.infoCellItem.task = self.task
            self.infoCellItem.status = self.status
        }
        
        return cellItem
    }()
    
    lazy var infoSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 5.0
        sectionController.cellItems = [self.infoCellItem]
        return sectionController
    }()
    
    /// 备注
    lazy var noteSectionController: TPNoteTableSectionController = { [weak self] in
        let sectionController = TPNoteTableSectionController()
        sectionController.headerItem.height = 15.0
        sectionController.headerItem.title = nil
        sectionController.headerItem.padding = .zero
        sectionController.placeholder = resGetString("Record your feelings or thoughts today...")
        sectionController.noteCellItem.updater = {
            self?.noteSectionController.note = self?.logInfo.log
        }

        sectionController.noteEditingChanged = { note in
            self?.logInfo.log = note
        }

        return sectionController
    }()
    
    /// 评分
    lazy var scoreSectionController: FocusRecordEditScoreSectionController = {
        let sectionController = FocusRecordEditScoreSectionController()
        sectionController.headerItem.height = 15.0
        sectionController.headerItem.title = nil
        sectionController.headerItem.padding = .zero
        sectionController.score = self.logInfo.score
        sectionController.didSelectScore = { [weak self] score in
            self?.logInfo.score = score
        }

        return sectionController
    }()
    
    /// 清除按钮
    private lazy var clearButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: resGetString("Clear"),
                                   style: .done,
                                   target: self,
                                   action: #selector(clickClear(_:)))
        item.tintColor = .danger6
        return item
    }()
    
    init(task: HabitTask, status: HabitTaskStatus, logInfo: HabitRecordLogInfo, date: Date) {
        self.task = task
        self.status = status
        self.logInfo = logInfo
        self.date = date
        if let log = logInfo.log, log.count > 0 {
            self.editType = .modify
        } else {
            self.editType = .create
        }
        
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.date.monthDayShortWeekdaySymbolString
        self.navigationItem.leftBarButtonItem = self.chevronDownCancelButtonItem
        if editType == .modify {
            /// 显示清除按钮
            self.navigationItem.rightBarButtonItem = clearButtonItem
        }
        
        self.wrapperView.isKeyboardAdjusterEnabled = true /// 键盘自动调整开启
        self.tableView.keyboardDismissMode = .interactive
        self.setupActionsBar(actions: [doneAction])
        self.sectionControllers = [infoSectionController,
                                   noteSectionController,
                                   scoreSectionController]
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.reloadData()
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func handleFirstAppearance() {
        noteSectionController.beginEditing()
    }
    
    override func clickDone() {
        didEndEditing?(logInfo)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Event Response
    @objc private func clickClear(_ buttonItem: UIBarButtonItem) {
        TPImpactFeedback.impactWithMediumStyle()
        didEndEditing?(nil)
        dismiss(animated: true, completion: nil)
    }
}
