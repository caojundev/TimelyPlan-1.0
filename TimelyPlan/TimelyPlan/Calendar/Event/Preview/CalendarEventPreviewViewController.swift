//
//  CalendarEventPreviewViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/13.
//

import Foundation
import UIKit
import EventKit

class CalendarEventPreviewViewController: TPTableSectionsViewController {
    
    var toolViewHeight = 50.0
    
    var toolView: TPToolbar = TPToolbar()
    
    let event: CalendarEvent
    
    lazy var infoCellItem: CalendarEventPreviewInfoCellItem = {
        let cellItem = CalendarEventPreviewInfoCellItem()
        cellItem.selectionStyle = .none
        cellItem.event = event
        return cellItem
    }()

    lazy var repeatCellItem: TPImageInfoTableCellItem = {
        let cellItem = TPImageInfoTableCellItem()
        cellItem.imageName = "schedule_repeat_24"
        cellItem.selectionStyle = .none
        cellItem.height = 80.0
        cellItem.titleConfig.numberOfLines = 2
        cellItem.titleConfig.font = .boldSystemFont(ofSize: 13.0)
        cellItem.titleConfig.textColor = Color(light: 0x111111, dark: 0xFFFFFF, alpha: 0.9)
        cellItem.subtitleConfig.font = .systemFont(ofSize: 12.0)
        cellItem.subtitleConfig.textColor = Color(light: 0x111111, dark: 0xFFFFFF, alpha: 0.8)
        return cellItem
    }()
    
    lazy var alarmCellItem: TPImageInfoTableCellItem = {
        let cellItem = TPImageInfoTableCellItem()
        cellItem.imageName = "schedule_alarm_24"
        cellItem.selectionStyle = .none
        cellItem.height = 70.0
        cellItem.titleConfig.numberOfLines = 2
        cellItem.titleConfig.font = .boldSystemFont(ofSize: 13.0)
        cellItem.titleConfig.textColor = Color(light: 0x111111, dark: 0xFFFFFF, alpha: 0.9)
        return cellItem
    }()
    
    lazy var sectionController: TPTableItemSectionController = {
        let controller = TPTableItemSectionController()
        var cellItems: [TPBaseTableCellItem] = [infoCellItem]
        
        if let repeatInfo = event.repeatInfo {
            repeatCellItem.title = repeatInfo.ruleDescription
            repeatCellItem.subtitle = repeatInfo.endDescription
            cellItems.append(repeatCellItem)
        }
        
        if let alarmDescription = event.alarmDescription {
            alarmCellItem.title = alarmDescription
            cellItems.append(alarmCellItem)
        }
        
        controller.cellItems = cellItems
        return controller
    }()
    
    lazy var editAction: TPButtonAction = {
        let action = TPButtonAction(title:  resGetString("Edit")) {  [weak self] action in
            self?.clickEdit()
        }
        
        action.style.cornerRadius = 12.0
        return action
    }()

    lazy var deleteAction: TPButtonAction = {
        let action = TPButtonAction(title:  resGetString("Delete")) {  [weak self] action in
            self?.clickDelete()
        }
        
        action.style.cornerRadius = 12.0
        action.style.backgroundColor = .danger6
        action.style.selectedBackgroundColor = .danger6
        return action
    }()
    
    init(event: CalendarEvent) {
        self.event = event
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        switch event.source {
        case .system:
            title = resGetString("Calendar Event")
        case .todo:
            title = resGetString("Todo Task")
        case .habit:
            title = resGetString("Habit")
        case .focus:
            title = resGetString("Focus")
        }
        
        var actions = [TPButtonAction]()
        if event.isEditable {
            actions.append(editAction)
        }
        
        if event.isDeletable {
            actions.append(deleteAction)
        }
        
        if actions.count > 0 {
            setupActionsBar(actions: actions)
        }
        
        wrapperView.tableView.separatorStyle = .singleLine
        wrapperView.tableView.separatorColor = .systemGray6
        adapter.cellStyle.backgroundColor = themeBackgroundColor
        adapter.cellStyle.selectedBackgroundColor = themeBackgroundColor
        sectionControllers = [sectionController]
        reloadData()
    }
    
    @objc private func clickEdit() {
        guard let ekEvent = event.sourceItem as? EKEvent else {
            return
        }
        
        dismiss(animated: true) {
            CalendarSystemManager.shared.editEvent(ekEvent)
        }
    }
    
    @objc private func clickDelete() {
        guard let ekEvent = event.sourceItem as? EKEvent else {
            return
        }
        
        CalendarSystemManager.shared.deleteEventWithConfirmation(ekEvent) { [weak self] result in
            switch result {
            case .success:
                debugPrint("事件删除成功")
                self?.dismiss(animated: true, completion: nil)
            case .failure(let error):
                debugPrint("删除失败: \(error.localizedDescription)")
            }
        }
    }

}
