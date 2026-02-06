//
//  FocusTimerViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/27.
//

import Foundation

class FocusRunningViewController: TPViewController,
                                  FocusTimerProgressInfoViewDelegate,
                                  FocusTrackerUpdater,
                                  FocusTrackerDelegate {
    
    /// 顶部工具栏
    private lazy var topbar: FocusRunningTopbar = { [weak self] in
        let bar = FocusRunningTopbar()
        bar.didClickMinimal = {
            self?.clickMinimal()
        }
        
        bar.didClickFlipClock = {
            self?.clickFlipClock()
        }
        
        return bar
    }()
    
    /// 进度视图
    let progressInfoView: FocusTimerProgressInfoView
    
    /// 计时器绑定视图
    let timerNameView = FocusRunningTimerNameView()

    /// 计时器操作视图
    lazy var actionView: FocusRunningActionView = {
        let view = FocusRunningActionView()
        view.didSelectActionType = { [weak self] actionType in
            self?.didSelectActionType(actionType)
        }
        
        return view
    }()
    
    /// 长按结束视图
    lazy var holdToStopView: TPHoldActionView = {
        let view = TPHoldActionView()
        view.handler = { [weak self] in
            self?.handleHoldToStop()
        }
        
        return view
    }()
    
    /// 事件控制器
    let tracker: FocusTracker
    
    init() {
        self.tracker = FocusTracker.shared
        let timerConfig = tracker.eventTimerConfig
        let timerType = timerConfig.timerType ?? .defaultType
        switch timerType {
        case .pomodoro:
            let view = FocusPomodoroProgressInfoView()
            let pomodoroConfig = timerConfig.pomodoroConfig ?? FocusPomodoroConfig()
            view.progressView.config = pomodoroConfig
            progressInfoView = view
        case .countdown:
            progressInfoView = CountdownProgressInfoView()
        case .stopwatch:
            progressInfoView = StopwatchProgressInfoView()
        case .stepped:
            progressInfoView = StepProgressInfoView()
        }
        
        super.init(nibName: nil, bundle: nil)
        progressInfoView.delegate = self
    }
     
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(timerNameView)
        view.addSubview(topbar)
        view.addSubview(progressInfoView)
        view.addSubview(actionView)
        view.addSubview(holdToStopView)
        updateTimerName()
        setupSwipeDownGesture()
        tracker.addDelegate(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tracker.addUpdater(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tracker.removeUpdater(self)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
            
        let layoutFrame = view.safeLayoutFrame()
        topbar.width = view.width
        topbar.height = 60.0
        topbar.top = layoutFrame.minY

        holdToStopView.width = 200.0
        holdToStopView.height = 40.0
        holdToStopView.bottom = layoutFrame.maxY - 20.0
        holdToStopView.alignHorizontalCenter()
        
        actionView.left = layoutFrame.minX
        actionView.width = layoutFrame.width
        actionView.height = 80.0
        actionView.bottom = holdToStopView.top - 20.0
        
        progressInfoView.size = CGSize(width: 320.0, height: 320.0)
        progressInfoView.centerY = topbar.bottom + (actionView.top - topbar.bottom) / 2.0
        progressInfoView.alignHorizontalCenter()
        
        let timerNameViewSize = CGSize(width: 260.0, height: 40.0)
        timerNameView.size = timerNameViewSize
        timerNameView.centerY = topbar.bottom + (progressInfoView.top - topbar.bottom) / 2.0
        timerNameView.alignHorizontalCenter()
    }
    
    // MARK: - Setup
    func setupSwipeDownGesture() {
        /// 创建向下滑动手势识别器
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown(_:)))
        swipeDownGesture.direction = .down
        view.addGestureRecognizer(swipeDownGesture)
    }

    // MARK: - Event Response
    func clickMinimal() {
        self.dismiss(animated: true, completion: nil)
    }

    func clickFlipClock() {
        let vc = FocusFlipClockViewController(tracker: tracker)
        vc.modalPresentationStyle = .fullScreen
        vc.show()
    }

    // 处理向下滑动的手势
    @objc func handleSwipeDown(_ gesture: UISwipeGestureRecognizer) {
        clickMinimal()
    }
    
    // MARK: - FocusTrackerDelegate
    func focusTrackerStateDidChange(fromState: FocusTrackerState?, toState: FocusTrackerState) {
        if toState == .ended {
            /// 结束长按计数
            holdToStopView.stopCounting()
        }
    }
    
    // MARK: - FocusTimerProgressInfoViewDelegate
    func progressInfoViewDidTap(_ view: FocusTimerProgressInfoView) {
        guard tracker.eventTimerType != .stopwatch else {
            /// 正计时直接返回
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        if view.isTimeAdjustViewHidden {
            view.showTimeAdjustView()
            view.dateRange = tracker.currentStepDateRange
        } else {
            view.hideTimeAdjustView()
        }
    }
     
    func progressInfoViewDidClickDecrease(_ view: FocusTimerProgressInfoView) {
        tracker.reduceDuration()
        view.dateRange = tracker.currentStepDateRange
        progressInfoView.alarmDate = tracker.currentStepAlarmDate
    }
    
    func progressInfoViewDidClickIncrease(_ view: FocusTimerProgressInfoView) {
        tracker.extendDuration()
        view.dateRange = tracker.currentStepDateRange
        progressInfoView.alarmDate = tracker.currentStepAlarmDate
    }

    func progressInfoView(_ view: FocusTimerProgressInfoView, canIncrease remainDuration: TimeInterval) -> Bool {
        return tracker.canIncrease(remainDuration: remainDuration)
    }
    
    func progressInfoView(_ view: FocusTimerProgressInfoView, canDecrease remainDuration: TimeInterval) -> Bool {
        return tracker.canDecrease(remainDuration: remainDuration)
    }
    
    
    // MARK: - FocusTimerUpdater
    var previousTimerInfo: FocusTimerInfo?
    func timerDidUpdate(timerInfo: FocusTimerInfo) {
        updateProgress(withInfo: timerInfo)
        
        let state = timerInfo.state
        var bShouldUpdateActions = false
        if state != previousTimerInfo?.state {
            bShouldUpdateActions = true
            
            /// 更新进度信息
            progressInfoView.isPaused = timerInfo.isPaused
            progressInfoView.alarmDate = tracker.currentStepAlarmDate
        }
        
        /// 更新操作按钮
        if bShouldUpdateActions || timerInfo.stepIndex != previousTimerInfo?.stepIndex {
            actionView.actionTypes = timerInfo.eventActionTypes()
        }
    }
    
    
    // MARK: - 操作
    /// 选中操作类型
    func didSelectActionType(_ actionType: FocusEventActionType) {
        tracker.performAction(actionType)
    }
    
    /// 处理长按结束
    func handleHoldToStop() {
        tracker.stop()
    }
    
    // MARK: - 更新界面
    private func updateTimerName() {
        timerNameView.name = tracker.eventTimerFeature?.shotName
    }
    
    /// 更新进度信息
    private func updateProgress(withInfo info: FocusTimerInfo?) {
        progressInfoView.timerInfo = info
    }
}
