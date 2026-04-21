//
//  TodoSingleScheduleEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/2/2.
//

import Foundation
import UIKit

class TodoSingleScheduleEditViewController: TPTableSectionsViewController,
                                               TPCalendarSingleDateSelectionDelegate {
    
    /// 结束计划编辑
    var didEndEditing: ((TaskSchedule?) -> Void)?
    
    /// 日期信息视图
    private let dateInfoViewHeight = 40.0
    private lazy var dateInfoView: TaskScheduleEditInfoView = {
        let view = TaskScheduleEditInfoView(frame: .zero)
        view.didClickDate = { [weak self] in
            self?.dateSectionController.setStartDateVisible()
        }
        
        return view
    }()
    
    
    /// 日期区块
    private lazy var dateSectionController: TaskScheduleEditDateSectionController = {
        let sectionController = TaskScheduleEditDateSectionController()
        sectionController.didChangeDateInfo = { [weak self] dateInfo in
            self?.dateInfoChanged(dateInfo)
        }
        
        return sectionController
    }()
    
    /// 提醒区块
    private lazy var reminderSectionController: TaskScheduleEditReminderSectionController = {
        let sectionController = TaskScheduleEditReminderSectionController()
        sectionController.didChangeReminder = { [weak self] reminder in
            self?.reminderChanged(reminder)
        }
        
        return sectionController
    }()
    
    /// 重复区块
    private lazy var repeatSectionController: TaskScheduleEditRepeatSectionController = {
        let sectionController = TaskScheduleEditRepeatSectionController()
        sectionController.didChangeRepeatRule = { [weak self] repeatRule in
            self?.repeatRuleChanged(repeatRule)
        }
        
        return sectionController
    }()
    
    var schedule: TaskSchedule {
        return TaskSchedule(dateInfo: dateSectionController.dateInfo,
                            reminder: reminderSectionController.reminder,
                            repeatRule: repeatSectionController.repeatRule)
    }
    
    init(schedule: TaskSchedule?) {
        super.init(style: .grouped)
        
        var dateInfo: TaskDateInfo
        if let info = schedule?.dateInfo, info.style == .singleDay {
            dateInfo = info
        } else {
            dateInfo = TaskDateInfo(style: .singleDay)
        }
        
        dateSectionController.dateInfo = dateInfo
        dateSectionController.repeatRule = schedule?.repeatRule
        
        reminderSectionController.dateInfo = dateInfo
        reminderSectionController.reminder = schedule?.reminder
        
        repeatSectionController.dateInfo = dateInfo
        repeatSectionController.repeatRule = schedule?.repeatRule
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(dateInfoView)
        tableView.showsVerticalScrollIndicator = false
        adapter.cellStyle.backgroundColor = .systemBackground
        sectionControllers = [dateSectionController,
                              reminderSectionController,
                              repeatSectionController]
        reloadData()
        updateDateInfoView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        dateInfoView.width = view.width
        dateInfoView.height = dateInfoViewHeight
    }
    
    override func tableViewFrame() -> CGRect {
        return CGRect(x: 0.0,
                      y: dateInfoViewHeight,
                      width: view.width,
                      height: view.height - dateInfoViewHeight)
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }

    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    private func updateDateInfoView() {
        dateInfoView.schedule = schedule
    }
    
    // MARK: - 编辑内容改变
    private func dateInfoChanged(_ dateInfo: TaskDateInfo) {
        reminderSectionController.dateInfo = dateInfo
        reminderSectionController.reloadReminder()
        
        repeatSectionController.dateInfo = dateInfo
        repeatSectionController.reloadRepeat()
        
        updateDateInfoView()
    }
    
    private func reminderChanged(_ reminder: TaskReminder?) {
        updateDateInfoView()
    }
    
    private func repeatRuleChanged(_ repeatRule: RepeatRule?) {
        dateSectionController.repeatRule = repeatRule
        dateSectionController.updateCalendarSpanningIndicator()
        updateDateInfoView()
    }
}

