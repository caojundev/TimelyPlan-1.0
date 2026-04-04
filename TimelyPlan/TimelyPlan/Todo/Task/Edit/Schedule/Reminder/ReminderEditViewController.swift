//
//  ReminderEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/14.
//

import Foundation
import UIKit

class ReminderEditViewController: TPTableSectionsViewController {

    /// 结束编辑提醒
    var didEndEditing: ((TaskReminder?) -> Void)?

    /// 提醒改变
    var reminderChanged: ((TaskReminder?) -> Void)?
    
    /// 开始提醒区块
    private var startAlarmSectionController: ReminderEditSectionController?
    
    /// 结束提醒区块
    private var endAlarmSectionController: ReminderEditSectionController?
    
    /// 任务提醒对象
    private var reminder: TaskReminder
    
    /// 任务日期
    private var dateInfo: TaskDateInfo
    
    /// 最多提醒数目
    private let maximumAlarmsCount = 5

    init(reminder: TaskReminder?, dateInfo: TaskDateInfo) {
        self.reminder = (reminder?.copy() as? TaskReminder) ?? TaskReminder()
        self.dateInfo = dateInfo
        super.init(style: .grouped)
        self.setupSectionControllers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Reminder")
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.tableView.showsVerticalScrollIndicator = false
        self.preferredContentSize = .Popover.extraLarge
        self.setupActionsBar(actions: [doneAction])
        
        tableView.separatorStyle = .none
        tableView.separatorInset = .zero
        tableView.separatorColor = Color(0xaaaaaa, 0.1)
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        adapter.reloadData()
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    private func setupStartAlarmSectionController() {
        let sectionController = sectionController(date: dateInfo.startDate,
                                                  isAllDay: dateInfo.isAllDay,
                                                  alarms: reminder.startAlarms)
        sectionController.headerTitle = resGetString("Start Reminder")
        sectionController.didClickCustom = { [weak self] in
            self?.newAlarm(for: .start)
        }
        
        sectionController.alarmsDidChange = { [weak self] alarms in
            self?.startAlarmsDidChange(alarms)
        }
        
        self.startAlarmSectionController = sectionController
    }
    
    private func setupEndAlarmSectionController() {
        let sectionController = sectionController(date: dateInfo.endDate,
                                                  isAllDay: dateInfo.isAllDay,
                                                  alarms: reminder.endAlarms)
        sectionController.headerTitle = resGetString("End Reminder")
        sectionController.didClickCustom = { [weak self] in
            self?.newAlarm(for: .end)
        }
        
        sectionController.alarmsDidChange = { [weak self] alarms in
            self?.endAlarmsDidChange(alarms)
        }
        
        self.endAlarmSectionController = sectionController
    }
    
    private func setupSectionControllers() {
        setupStartAlarmSectionController()
        setupEndAlarmSectionController()
        
        var sectionControllers = [TPTableItemSectionController]()
        if let startAlarmSectionController = startAlarmSectionController {
            sectionControllers.append(startAlarmSectionController)
        }
        
        if let endAlarmSectionController = endAlarmSectionController {
            sectionControllers.append(endAlarmSectionController)
        }
        
        self.sectionControllers = sectionControllers
    }
    
    override func clickDone() {
        dismiss(animated: true, completion: nil)
        didEndEditing?(reminder)
    }

    // MARK: - 自定义提醒
    enum ReminderAlarmType {
        case start
        case end
    }
    
    func newAlarm(for type: ReminderAlarmType) {
        if dateInfo.isAllDay {
            createAbsoluteAlarm(for: type)
        } else {
            createRelativeAlarm(for: type)
        }
    }
    
    private func createAbsoluteAlarm(for type: ReminderAlarmType) {
        let vc = AlarmAbsoluteOffsetEditViewController()
        vc.didEndEditing = { alarm in
            self.didCreateAlarm(alarm, for: type)
        }
        
        let navController = UINavigationController(rootViewController: vc)
        navController.popoverShow()
    }
    
    private func createRelativeAlarm(for type: ReminderAlarmType) {
        let vc = AlarmRelativeOffsetEditViewController()
        vc.didEndEditing = { alarm in
            self.didCreateAlarm(alarm, for: type)
        }
        
        let navController = UINavigationController(rootViewController: vc)
        navController.popoverShow()
    }
    
    private func didCreateAlarm(_ alarm: TaskAlarm, for type: ReminderAlarmType) {
        var sectionController = startAlarmSectionController
        if type == .end {
            sectionController = endAlarmSectionController
        }
        
        sectionController?.didCreateAlarm(alarm)
    }
    
    // MARK: - 提醒改变
    func startAlarmsDidChange(_ alarms: [TaskAlarm]) {
        reminder.startAlarms = alarms
        endAlarmSectionController?.updateEnabled()
        reminderChanged?(reminder)
    }
    
    func endAlarmsDidChange(_ alarms: [TaskAlarm]) {
        reminder.endAlarms = alarms
        startAlarmSectionController?.updateEnabled()
        reminderChanged?(reminder)
    }
    
    // MARK: - Helpers
    private func sectionController(date: Date, isAllDay: Bool, alarms: [TaskAlarm]?) -> ReminderEditSectionController {
        let sectionController = ReminderEditSectionController(date: date,
                                                      isAllDay: isAllDay,
                                                      alarms: alarms)
        sectionController.canAddAlarm = { [weak self] in
            return self?.canAddNewAlarm() ?? false
        }
        
        return sectionController
    }
    
    /// 是否可以添加新提醒
    private func canAddNewAlarm() -> Bool {
        let startAlarmsCount = startAlarmSectionController?.alarmsCount ?? 0
        let endAlarmsCount = endAlarmSectionController?.alarmsCount ?? 0
        let count = startAlarmsCount + endAlarmsCount
        return count < maximumAlarmsCount
    }
    
}
