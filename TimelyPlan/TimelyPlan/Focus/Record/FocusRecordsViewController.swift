//
//  FocusRecordsViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/6.
//

import Foundation

class FocusRecordsViewController: StatsMainViewController {

    /// 任务
    var task: TaskRepresentable?
    
    /// 计时器
    var timer: FocusTimer?

    /// 记录排列顺序
    lazy var sortOrder: FocusRecordSortOrder = {
        let value: FocusRecordSortOrder? = SettingAgent.shared.value(forKey: kFocusSettingRecordsSortOrder)
        return value ?? .ascending
    }()
    
    /// 排序按钮
    lazy var orderBarButtonItem: FocusRecordSortOrderBarButtonItem = {
        let buttonItem = FocusRecordSortOrderBarButtonItem()
        buttonItem.sortOrder = self.sortOrder
        buttonItem.didSelectType = {[weak self] sortOrder in
            self?.didSelectSortOrder(sortOrder)
        }
        
        return buttonItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.navigationItem.rightBarButtonItems = [addBarButtonItem, orderBarButtonItem]
    }
    
    init(task: TaskRepresentable? = nil,
         timer: FocusTimer? = nil,
         type: StatsType = .week,
         date: Date = .now) {
        self.task = task
        self.timer = timer
        super.init(type: type, allowTypes: [.day, .week, .month], date: date)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func dailyStatsViewController() -> UIViewController! {
        let vc = FocusRecordListViewController(type: .day, date: self.date)
        vc.sortOrder = sortOrder
        vc.timer = timer
        vc.task = task
        return vc
    }
    
    override func weeklyStatsViewController() -> UIViewController! {
        let firstWeekday: Weekday = Weekday.firstWeekday
        let vc = FocusRecordListViewController(type: .week, date: self.date, firstWeekday: firstWeekday)
        vc.sortOrder = sortOrder
        vc.timer = timer
        vc.task = task
        return vc
    }
    
    override func monthlyStatsViewController() -> UIViewController! {
        let vc = FocusRecordListViewController(type: .month, date: self.date)
        vc.sortOrder = sortOrder
        vc.timer = timer
        vc.task = task
        return vc
    }
    
    override func clickAdd() {
        TPImpactFeedback.impactWithSoftStyle()
         
        let timerController = FocusUserTimerController()
        timerController.addRecordManually(forTimer: timer)
    }
    
    private func didSelectSortOrder(_ sortOrder: FocusRecordSortOrder) {
        guard self.sortOrder != sortOrder else {
            return
        }
        
        self.sortOrder = sortOrder
        /// 保存到本地设置项
        SettingAgent.shared.setValue(sortOrder,
                                     forKey: kFocusSettingRecordsSortOrder)
        
        /// 重新加载列表数据
        let vc = self.contentViewController as? FocusRecordListViewController
        vc?.sortOrder = sortOrder
        vc?.reloadData()
    }
    
}
