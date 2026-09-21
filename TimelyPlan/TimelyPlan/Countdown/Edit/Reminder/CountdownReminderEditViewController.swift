//
//  CountdownReminderEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/20.
//

import Foundation
import UIKit

class CountdownReminderEditViewController: TPTableSectionsViewController {

    /// 结束编辑提醒
    var didEndEditing: ((CountdownReminder?) -> Void)?

    /// 提醒改变
    var reminderChanged: ((CountdownReminder?) -> Void)?
    
    /// 提醒区块
    private lazy var alarmSectionController: TaskReminderEditSectionController = {
        let sectionController = TaskReminderEditSectionController(date: self.targetDate,
                                                                  isAllDay: true,
                                                                  alarms: self.reminder.startAlarms)
        sectionController.canAddAlarm = { [weak self] in
            return self?.canAddNewAlarm() ?? false
        }
        
        sectionController.didClickCustom = { [weak self] in
            self?.createAbsoluteAlarm()
        }
        
        sectionController.alarmsDidChange = { [weak self] alarms in
            self?.startAlarmsDidChange(alarms)
        }
        
        return sectionController
    }()
    
    /// 里程碑区块
    private lazy var milestoneSectionController: CountdownMilestoneEditSectionController = {
        let sectionController = CountdownMilestoneEditSectionController(milestones: self.reminder.milestones)
        sectionController.headerTitle = resGetString("Milestones")
        sectionController.canAddMilestone = { [weak self] in
            return self?.canAddNewMilestone() ?? false
        }
        
        sectionController.didClickCustom = { [weak self] in
            self?.createCustomMilestone()
        }
        
        sectionController.milestonesDidChange = { [weak self] milestones in
            self?.milestonesDidChange(milestones)
        }
        
        return sectionController
    }()
    
    /// 提醒对象
    private(set) var reminder: CountdownReminder
    
    /// 最多提醒数目
    private let maximumAlarmsCount = 5
    
    /// 最多里程碑数目
    private let maximumMilestonesCount = 5

    let targetDate: Date
    
    init(reminder: CountdownReminder?,
         targetDate: Date) {
        self.reminder = (reminder?.copy() as? CountdownReminder) ?? CountdownReminder()
        self.targetDate = targetDate
        super.init(style: .grouped)
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
        
        sectionControllers = [alarmSectionController, milestoneSectionController]
        adapter.reloadData()
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    override func clickDone() {
        dismiss(animated: true, completion: nil)
        didEndEditing?(reminder)
    }

    // MARK: - 自定义提醒
    private func createAbsoluteAlarm() {
        let vc = AlarmAbsoluteOffsetEditViewController()
        vc.didEndEditing = { alarm in
            self.alarmSectionController.didCreateAlarm(alarm)
        }
        
        let navController = UINavigationController(rootViewController: vc)
        navController.popoverShow()
    }
    
    // MARK: - 自定义里程碑
    private func createCustomMilestone() {
        let vc = CountdownMilestonePickerViewController(milestone: CountdownMilestone(interval: 1, unit: .week))
        vc.didPickMilestone = { [weak self] milestone in
            self?.milestoneSectionController.didCreateMilestone(milestone)
        }
        
        let navController = UINavigationController(rootViewController: vc)
        navController.popoverShow()
    }
    
    // MARK: - 提醒改变
    func startAlarmsDidChange(_ alarms: [TaskAlarm]) {
        reminder.startAlarms = alarms
        reminderChanged?(reminder)
    }
    
    /// 是否可以添加新提醒
    private func canAddNewAlarm() -> Bool {
        return alarmSectionController.alarmsCount < maximumAlarmsCount
    }
    
    // MARK: - 里程碑改变
    func milestonesDidChange(_ milestones: [CountdownMilestone]) {
        reminder.milestones = milestones
        reminderChanged?(reminder)
    }
    
    /// 是否可以添加新里程碑
    private func canAddNewMilestone() -> Bool {
        return milestoneSectionController.milestonesCount < maximumMilestonesCount
    }
    
}
