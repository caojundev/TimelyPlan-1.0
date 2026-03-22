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
    private var sortOrder = FocusState.shared.recordListOrder
    
    /// 列表模式
    private var mode = FocusState.shared.recordListMode
    
    /// 更多菜单按钮
    private lazy var moreBarButtonItem: FocusRecordMoreBarButtonItem = {
        let item = FocusRecordMoreBarButtonItem()
        item.sortOrder = sortOrder
        item.mode = mode
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
        setupListViewController(vc)
        return vc
    }
    
    override func weeklyStatsViewController() -> UIViewController! {
        let firstWeekday = FocusSetting.shared.firstWeekday
        let vc = FocusRecordListViewController(type: .week, date: self.date, firstWeekday: firstWeekday)
        setupListViewController(vc)
        return vc
    }
    
    override func monthlyStatsViewController() -> UIViewController! {
        let vc = FocusRecordListViewController(type: .month, date: self.date)
        setupListViewController(vc)
        return vc
    }
    
    private func setupListViewController(_ vc: FocusRecordListViewController) {
        vc.sortOrder = sortOrder
        vc.mode = mode
        vc.timer = timer
        vc.task = task
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
        guard let vc = self.contentViewController as? FocusRecordListViewController else {
            return
        }
        
        let newMode: FocusRecordListMode
        switch mode {
        case .detail:
            newMode = .basic
        case .basic:
            newMode = .detail
        }
        
        self.mode = newMode
        self.moreBarButtonItem.mode = newMode
        vc.mode = newMode
        vc.reloadData()
        
        /// 保存到本地
        FocusState.shared.recordListMode = newMode
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
        FocusState.shared.recordListOrder = sortOrder
    }
    
}
