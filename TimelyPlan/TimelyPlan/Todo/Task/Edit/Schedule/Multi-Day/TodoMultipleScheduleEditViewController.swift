//
//  TodoMultipleScheduleEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/21.
//

import Foundation
import UIKit

class TodoMultipleScheduleEditViewController: TPTableSectionsViewController,
                                               TPCalendarSingleDateSelectionDelegate {
    
    /// 结束计划编辑
    var didEndEditing: ((TaskSchedule?) -> Void)?
    
    /// 日期范围视图高度
    private let dateRangeViewHeight = 110.0
    lazy var dateRangeView: TodoMultiDayScheduleDateRangeView = {
        let view = TodoMultiDayScheduleDateRangeView()
        view.didSelectEditType = { [weak self] editType in
            self?.selectDateEditType(editType)
        }

        return view
    }()
    
    /// 日期区块
    lazy var dateSectionController: TodoMultiDayScheduleEditSectionController = {
        let sectionController = TodoMultiDayScheduleEditSectionController()
        sectionController.didChangeDateInfo = { [weak self] dateInfo in
            self?.dateInfoChanged(dateInfo)
        }
        
        return sectionController
    }()
    
    /// 提醒区块
    private lazy var reminderSectionController: TaskScheduleEditReminderSectionController = {
        let sectionController = TaskScheduleEditReminderSectionController()
        sectionController.footerItem = TPDefaultInfoTableHeaderFooterItem()
        sectionController.footerItem.height = 0.0
        sectionController.didChangeReminder = { [weak self] reminder in
            self?.reminderChanged(reminder)
        }
        
        return sectionController
    }()
    
    var schedule: TaskSchedule {
        return TaskSchedule(dateInfo: dateSectionController.dateInfo,
                            reminder: reminderSectionController.reminder,
                            repeatRule: nil)
    }
    
    init(schedule: TaskSchedule?) {
        super.init(style: .grouped)
        var dateInfo: TaskDateInfo
        if let info = schedule?.dateInfo, info.style == .multiDay {
            dateInfo = info
        } else {
            dateInfo = TaskDateInfo(style: .multiDay)
        }
        
        dateSectionController.dateInfo = dateInfo
        reminderSectionController.dateInfo = dateInfo
        reminderSectionController.reminder = schedule?.reminder
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(dateRangeView)
        self.tableView.showsVerticalScrollIndicator = false
        self.adapter.cellStyle.backgroundColor = .systemBackground
        self.sectionControllers = [dateSectionController,
                                   reminderSectionController]
        self.reloadData()
    }
    
    override func reloadData() {
        super.reloadData()
        self.reloadDateRangeView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        dateRangeView.width = view.width
        dateRangeView.height = dateRangeViewHeight
        dateRangeView.origin = .zero
    }
    
    override func tableViewFrame() -> CGRect {
        return CGRect(x: 0.0,
                      y: dateRangeViewHeight,
                      width: view.bounds.width,
                      height: view.bounds.height - dateRangeViewHeight)
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }

    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }

    private func selectDateEditType(_ editType: DateRangeEditType) {
        dateSectionController.selectEditType(editType)
    }
    
    /// 更新日期范围视图
    private func reloadDateRangeView() {
        dateRangeView.editType = dateSectionController.editType
        dateRangeView.dateInfo = dateSectionController.dateInfo
    }
    
    
    func dateInfoChanged(_ dateInfo: TaskDateInfo) {
        dateSectionController.dateInfo = dateInfo
        reminderSectionController.dateInfo = dateInfo
        reminderSectionController.reloadReminder()
        reloadDateRangeView()
    }
    
    private func reminderChanged(_ reminder: TaskReminder?) {
        
    }
    
}

