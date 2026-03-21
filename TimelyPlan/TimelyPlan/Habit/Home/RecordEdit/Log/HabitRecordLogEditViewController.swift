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

    private let task: HabitTask
    
    private var record: HabitRecord?
    
    private let date: Date
    
    private var logInfo: HabitRecordLogInfo
    
    lazy var infoCellItem: HabitLogTaskInfoTableCellItem = {
        let cellItem = HabitLogTaskInfoTableCellItem()
        cellItem.updater = { [weak self] in
            guard let self = self else { return }
            self.infoCellItem.task = self.task
            self.infoCellItem.record = self.record
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
            self?.updateClearButton()
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
    
    init(task: HabitTask, record: HabitRecord?, date: Date) {
        self.task = task
        self.record = record
        self.date = date
        
        if let logInfo = record?.logInfo {
            self.logInfo = logInfo
        } else {
            let status = task.status(with: record)
            self.logInfo = .logInfo(with: status)
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
        self.updateClearButton()
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
        if self.record?.logInfo != self.logInfo {
            self.didEndEditing?(logInfo)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    private func updateClearButton() {
        if let log = record?.log, log.count > 0 {
            self.navigationItem.rightBarButtonItem = clearButtonItem
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    // MARK: - Event Response
    @objc private func clickClear(_ buttonItem: UIBarButtonItem) {
        TPImpactFeedback.impactWithSoftStyle()
        self.logInfo.log = nil
        self.noteSectionController.updateNote()
    }
}
