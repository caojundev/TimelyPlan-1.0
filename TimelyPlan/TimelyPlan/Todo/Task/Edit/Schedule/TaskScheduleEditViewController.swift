//
//  TaskScheduleEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/2/2.
//

import Foundation

class TaskScheduleEditViewController: TPTableSectionsViewController,
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
    
    /// 显示清除按钮
    var showClearButton: Bool {
        didSet {
            updateRightNavigationItem()
        }
    }
    
    /// 清除按钮
    private lazy var clearBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: resGetString("Clear"),
                                   style: .done,
                                   target: self,
                                   action: #selector(clickClear))
        item.tintColor = .redPrimary
        return item
    }()
    
    var schedule: TaskSchedule {
        return TaskSchedule(dateInfo: dateSectionController.dateInfo,
                            reminder: reminderSectionController.reminder,
                            repeatRule: repeatSectionController.repeatRule)
    }
    
    init(schedule: TaskSchedule?) {
        self.showClearButton = schedule != nil
        super.init(style: .grouped)
        let dateInfo = schedule?.dateInfo ?? TaskDateInfo()
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
        title = resGetString("Date")
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        preferredContentSize = .Popover.extraLarge
        view.addSubview(dateInfoView)
        updateRightNavigationItem()
        setupActionsBar(actions: [doneAction])
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
                      height: view.height - dateInfoViewHeight - actionsBarHeight)
    }

    func updateRightNavigationItem() {
        self.navigationItem.rightBarButtonItem = showClearButton ? clearBarButtonItem : nil
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }

    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override func clickDone() {
        super.clickDone()
        didEndEditing?(schedule)
    }
    
    @objc private func clickClear() {
        TPImpactFeedback.impactWithSoftStyle()
        dismiss(animated: true, completion: nil)
        didEndEditing?(nil)
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
