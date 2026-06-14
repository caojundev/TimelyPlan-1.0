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
    
    lazy var sectionController: TPTableItemSectionController = {
        let controller = TPTableItemSectionController()
        controller.cellItems = [infoCellItem]
        return controller
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
        setupToolView()
        sectionControllers = [sectionController]
        reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        toolView.width = view.width
        toolView.height = toolViewHeight
        toolView.bottom = view.safeLayoutFrame().maxY
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
        
        CalendarSystemManager.shared.presentEditViewController(for: ekEvent, on: self)
    }
    
    @objc private func deleteTapped() {
        print("删除按钮被点击")
    }

}
