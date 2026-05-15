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

    /// 信息视图
    private let infoViewEdgeMargins = UIEdgeInsets(value: 10.0)
    private let infoViewHeight = 64.0
    private var infoView: FocusStatsInfoView?
    
    /// 更多菜单按钮
    private lazy var moreBarButtonItem: FocusRecordMoreBarButtonItem = {
        let item = FocusRecordMoreBarButtonItem()
        item.didSelectType = { [weak self] type in
            self?.performMoreMenuAction(with: type)
        }
        
        return item
    }()

    init(task: TaskRepresentable? = nil,
         timer: FocusTimer? = nil,
         type: StatsType = .week,
         date: Date = .now) {
        self.task = task
        self.timer = timer
        super.init(type: type, allowTypes: [.day, .week, .month], date: date)
        self.setupInfoView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.navigationItem.rightBarButtonItem = moreBarButtonItem
        self.contentInset = UIEdgeInsets(bottom: 80.0)
    }
    
    private func setupInfoView() {
        var infoView: FocusStatsInfoView?
        let mode: FocusStatsMode = .mode(timer: timer, task: task)
        if mode == .specificTimer, let timer = self.timer {
            infoView = FocusStatsSpecificTimerInfoView(timer: timer, showDuration: false)
        } else if mode == .specificTask, let task = self.task {
            infoView = FocusStatsSpecificTaskInfoView(task: task, showDuration: false)
        }
        
        self.infoView = infoView
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let infoView = infoView {
            self.layoutInfoView(infoView)
            self.contentInset = UIEdgeInsets(bottom: infoView.height + infoViewEdgeMargins.verticalLength)
        }
    }

    override func handleFirstAppearance() {
        guard let infoView = infoView else {
            return
        }

        self.view.addSubview(infoView)
        self.layoutInfoView(infoView, isHidden: true) /// 隐藏infoView
        UIView.animate(withDuration: 0.6,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut,
                       animations: {
            self.layoutInfoView(infoView)
        }, completion: nil)
    }

    /// 布局任务信息视图
    private func layoutInfoView(_ infoView: UIView, isHidden: Bool = false){
        let layoutFrame = view.safeLayoutFrame().inset(by: infoViewEdgeMargins)
        let cornerRadius = 16.0
        infoView.width = min(640.0, layoutFrame.width)
        infoView.height = infoViewHeight
        if isHidden {
            infoView.top = view.height
        } else {
            infoView.bottom = layoutFrame.maxY
        }
        
        infoView.centerX = layoutFrame.midX
        infoView.layer.cornerRadius = cornerRadius
        infoView.layer.setLayerShadow(color: Color(0x000000, 0.1),
                                      offset: CGSize(width: 0.0, height: -2.0),
                                      radius: cornerRadius)
        infoView.layoutIfNeeded()
    }

    // MARK: - ContentViewController
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
        vc.timer = timer
        vc.task = task
        if self.infoView != nil {
            /// 调整返回视图的间距不被信息视图遮挡
            vc.backViewMargins = UIEdgeInsets(top: 10.0, left: 16.0, bottom: 90.0, right: 16.0)
        }
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
        let newMode: FocusRecordListMode
        switch moreBarButtonItem.mode {
        case .detail:
            newMode = .basic
        case .basic:
            newMode = .detail
        }
        
        self.moreBarButtonItem.mode = newMode
        
        /// 保存到本地
        FocusState.shared.recordListMode = newMode
    }
    
    private func selectSortOrder(_ sortOrder: TPSortOrder) {
        guard self.moreBarButtonItem.sortOrder != sortOrder else {
            return
        }
        
        self.moreBarButtonItem.sortOrder = sortOrder
        FocusState.shared.recordListOrder = sortOrder
    }
}
