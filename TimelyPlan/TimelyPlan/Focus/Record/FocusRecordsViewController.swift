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
    private lazy var sortOrder: FocusRecordSortOrder = {
        let value: FocusRecordSortOrder? = SettingAgent.shared.value(forKey: kFocusSettingRecordSortOrder)
        return value ?? .ascending
    }()
    
    /// 显示详情
    private lazy var showDetail: Bool = {
        let value: Bool? = SettingAgent.shared.value(forKey: kFocusSettingRecordShowDetail)
        return value ?? kFocusSettingRecordDefaultShowDetail
    }()
    
    /// 更多菜单按钮
    private lazy var moreBarButtonItem: FocusRecordMoreBarButtonItem = {
        let item = FocusRecordMoreBarButtonItem()
        item.sortOrder = sortOrder
        item.showDetail = showDetail
        item.didSelectType = { [weak self] type in
            self?.performMoreMenuAction(with: type)
        }
        
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.navigationItem.rightBarButtonItem = moreBarButtonItem
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
        let firstWeekday = focus.setting.getFirstWeekday()
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
    
    private func performMoreMenuAction(with actionType: FocusRecordMoreMenuType) {
        switch actionType {
        case .addRecord:
            addRecordManually()
        case .showDetail:
            toggleShowDetail()
        case .orderAscending:
            selectSortOrder(.ascending)
        case .orderDescending:
            selectSortOrder(.descending)
        }
    }
    
    private func addRecordManually() {
        let timerController = FocusUserTimerController()
        timerController.addRecordManually(forTimer: timer)
    }
   
    private func toggleShowDetail() {
        // 切换显示模式
        if let vc = self.contentViewController as? FocusRecordListViewController {
            self.showDetail = !showDetail
            vc.mode = self.showDetail ? .detail : .basic
            vc.reloadData()
            
            /// 保存到本地设置项
            SettingAgent.shared.setValue(self.showDetail, forKey: kFocusSettingRecordShowDetail)
        }
    }
    
    private func selectSortOrder(_ sortOrder: FocusRecordSortOrder) {
        guard self.sortOrder != sortOrder else {
            return
        }
        
        self.sortOrder = sortOrder
        self.moreBarButtonItem.sortOrder = sortOrder
        
        /// 重新加载列表数据
        if let vc = self.contentViewController as? FocusRecordListViewController {
            vc.sortOrder = sortOrder
            vc.reloadData()
        }
        
        /// 保存到本地设置项
        SettingAgent.shared.setValue(sortOrder, forKey: kFocusSettingRecordSortOrder)
    }
    
}
