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
        cellItem.event = event
        return cellItem
    }()

    lazy var repeatCellItem: TPImageInfoTableCellItem = {
        let cellItem = TPImageInfoTableCellItem()
        cellItem.height = 70.0
        cellItem.titleConfig.font = .systemFont(ofSize: 14.0)
        cellItem.titleConfig.textColor = .secondaryLabel
        cellItem.subtitleConfig.font = .systemFont(ofSize: 13.0)
        cellItem.subtitleConfig.textColor = .tertiaryLabel
        cellItem.imageName = "schedule_repeat_24"
        return cellItem
    }()
    
    lazy var alarmCellItem: TPImageInfoTableCellItem = {
        let cellItem = TPImageInfoTableCellItem()
        cellItem.titleConfig.numberOfLines = 2
        cellItem.titleConfig.font = .systemFont(ofSize: 14.0)
        cellItem.titleConfig.textColor = .secondaryLabel
        cellItem.imageName = "schedule_alarm_24"
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
            self?.editTapped()
        }
        
        action.style.cornerRadius = .greatestFiniteMagnitude
        return action
    }()

    lazy var deleteAction: TPButtonAction = {
        let action = TPButtonAction(title:  resGetString("Delete")) {  [weak self] action in
            self?.deleteTapped()
        }
        
        action.style.cornerRadius = .greatestFiniteMagnitude
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
//        setupToolView()
        wrapperView.tableView.separatorStyle = .singleLine
        wrapperView.tableView.separatorColor = .systemGray6
        adapter.cellStyle.backgroundColor = themeBackgroundColor
        adapter.cellStyle.selectedBackgroundColor  = themeBackgroundColor
        sectionControllers = [sectionController]
        reloadData()
        
        
        setupActionsBar(actions: [editAction, deleteAction])
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
//        toolView.width = view.width
//        toolView.height = toolViewHeight
//        toolView.bottom = view.safeLayoutFrame().maxY
    }
    
    func setupToolView() {
        let editImage = resGetImage("edit_24")
        let editItem = TPBarButtonItem(image: editImage) {[weak self] _ in
            self?.editTapped()
        }
         
        let deleteImage = resGetImage("trash_24")
        let deleteItem = TPBarButtonItem(image: deleteImage) {[weak self] _ in
            self?.deleteTapped()
        }
        
        deleteItem.color = .danger6
        toolView.buttonItems = [editItem, .flexibleSpaceButtonItem, deleteItem]
        toolView.addSeparator(position: .top)
        view.addSubview(toolView)
    }
    
    @objc private func editTapped() {
        guard let ekEvent = event.sourceItem as? EKEvent else {
            return
        }
        
        dismiss(animated: true) {
            CalendarSystemManager.shared.editEvent(ekEvent)
        }
    }
    
    @objc private func deleteTapped() {
        print("删除按钮被点击")
    }

}
