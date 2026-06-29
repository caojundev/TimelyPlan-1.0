//
//  FocusTimerManager.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/6.
//

import Foundation

protocol FocusTrackerUpdater: AnyObject {
    
    /// 上一次更新的计时器信息
    var previousTimerInfo: FocusTimerInfo? { get set}
    
    /// 计时器更新通知
    func timerDidUpdate(timerInfo: FocusTimerInfo)
}

protocol FocusTrackerDelegate: AnyObject {
    /// 通知状态发生改变
    func focusTrackerStateDidChange(fromState: FocusTrackerState?, toState: FocusTrackerState)
}

/// 状态
enum FocusTrackerState: Int {
    case waiting /// 等待事件
    case running /// 运行中
    case ended   /// 结束
}

class FocusTracker: NSObject {
    
    /// 单例对象
    static let shared = FocusTracker()

    /// 事项改变回调
//    var onEventChanged: (() -> Void)?
    
    /// 外部为事项注册通知
    var scheduleNotificationHandler: (() -> Void)?
    
    /// 当前状态
    var state: FocusTrackerState {
        guard let event = event else {
            /// 等待
            return .waiting
        }
        
        if event.state == .finished {
            return .ended
        }
        
        /// 运行中
        return .running
    }
    
    /// 计时器是否运行中
    var isTimerRunning: Bool {
        guard let event = event else {
            return false
        }
    
        let state = event.state
        if state == .focusing || state == .breaking {
            return true
        }
        
        return false
    }
    
    var eventTimerConfig: FocusTimerConfig {
        return event?.timerConfig ?? FocusTimerConfig.defaultConfig
    }
    
    var eventTimerType: FocusTimerType {
        return event?.timerConfig?.timerType ?? .defaultType
    }
    
    var eventTimerFeature: TimerFeature? {
        return event?.timerFeature
    }
    
    var eventTaskFeature: TaskFeature? {
        return event?.taskFeature
    }
    
    /// 当前步骤开始结束日期范围
    var currentStepDateRange: DateRange? {
        return event?.currentStepDateRange
    }
    
    /// 当前步骤提醒日期
    var currentStepAlarmDate: Date? {
        return event?.currentStepAlarmDate
    }
    
    /// 结束数据条目
    var endDataItem: FocusEndDataItem {
        guard state == .ended else {
            return .emptyDataItem
        }
        
        let minimumRecordDuration = FocusSetting.shared.validatedMinimumRecordDuration
        return event?.endDataItem(with: minimumRecordDuration) ?? .emptyDataItem
    }
    
    /// 当前追踪的专注事件
    private(set) var event: FocusEvent?
    
    /// 定时器
    private var timer: Timer?

    /// 更新器
    private let updaters = NSHashTable<AnyObject>.weakObjects()

    /// 已呈现的追踪视图控制器
    private let presentedTrackingViewControllers = NSHashTable<FocusTrackingViewController>.weakObjects()
    
    /// 当前专注事件键值
    private let kFocusingEventKey = "focusingEvent"
    
    /// 通知授权状态
    var isNotiAuthorized: Bool?
    
    deinit {
        removeNotification()
    }
    
    private override init() {
        super.init()
        addNotification()
    }
    
    /// 清除事件
    func clearEvent() {
        event = nil
        stopTimerIfNeeded()
        checkStateAndNotifyDelegatesIfNeeded()
        previousState = nil
        
        /// 删除保存的事件数据
        SettingAgent.shared.setValue(nil, forKey: kFocusingEventKey)
        
        scheduleNotificationHandler?()
    }

    /// 保存事件数据
    private func saveEvent() {
        /// 保存到本地
        SettingAgent.shared.setValue(self.event, forKey: kFocusingEventKey)
    }
    
    // MARK: - 开始专注
    func startFocus(with timer: FocusTimerRepresentable,
                    for task: TaskFeature?,
                    forceAutoStart: Bool = false) {
        if self.event == nil || self.event?.state == .notStarted {
            /// 当前无绑定事件，或绑定事件未开始，则可以绑定新的计时器事件
            track(timer: timer, task: task, forceAutoStart: forceAutoStart)
        }
    
        showTrackingViewControllerIfNeeded()
    }
    
    /// 恢复专注
    func restoreFocus() {
        guard self.event == nil else {
            return
        }
        
        let event: FocusEvent? = SettingAgent.shared.value(forKey: kFocusingEventKey)
        if let event = event {
            track(event: event)
            updateFloatingBubbleTimer() /// 更新浮动计时器
        }
    }
    
    private func track(timer: FocusTimerRepresentable,
                       task: TaskFeature? = nil,
                       forceAutoStart: Bool) {
        let timerConfig = timer.timerConfig ?? FocusTimerConfig.defaultConfig
        let event = timerConfig.event()
        event.timerFeature = timer.feature
        event.taskFeature = task
        if forceAutoStart {
            event.start()
        } else {
            /// 根据配置确定是否自动开始
            event.startIfAutoStart()
        }
        
        track(event: event)
    }
    
    private func track(event: FocusEvent) {
        self.event = event
        saveEvent()
        scheduleNotificationHandler?()
    }

    // MARK: - 追踪视图控制器
    /// 显示计时视图控制器
    func showTrackingViewControllerIfNeeded() {
        if event == nil || isTrackingViewControllerPresented() {
            /// 计时器追踪视图控制器已弹出
            return
        }

        let trackingVC = FocusTrackingViewController()
        trackingVC.modalPresentationStyle = .fullScreen
        trackingVC.show()
    }
    
    func didPresentedTrackingViewController(_ vc: FocusTrackingViewController) {
        if !presentedTrackingViewControllers.contains(vc) {
            presentedTrackingViewControllers.add(vc)
        }
        
        updateFloatingBubbleTimer()
    }
    
    func didDismissTrackingViewController(_ vc: FocusTrackingViewController) {
        if presentedTrackingViewControllers.contains(vc) {
            presentedTrackingViewControllers.remove(vc)
        }
        
        updateFloatingBubbleTimer()
    }
    
    /// 追踪视图控制器是否显示中
    private func isTrackingViewControllerPresented() -> Bool {
        return presentedTrackingViewControllers.count > 0
    }

    // MARK: - 浮动窗管理
    /// 更新浮窗计时器
    func updateFloatingBubbleTimer() {
        let shouldShow = shouldShowFloatingBubbleTimer()
        if shouldShow {
            FocusFloatingTimerManager.shared.showBubbleTimerView()
        } else {
            FocusFloatingTimerManager.shared.hideBubbleTimerView()
        }
    }
    
    /// 是否显示浮窗计时器
    private func shouldShowFloatingBubbleTimer() -> Bool {
        if isTrackingViewControllerPresented() {
            /// 追踪视图控制器已呈现，不显示浮窗
            return false
        }
        
        return event != nil
    }
    
    // MARK: - 更新计时器
    
    /// 上一次更新计时器时的追踪状态
    private var previousState: FocusTrackerState?
    
    @objc private func updateTimer() {
        self.stopTimerIfNeeded()
        guard let timerInfo = event?.timerInfo() else {
            return
        }
        
        for updater in updaters.allObjects {
            guard let updater = updater as? FocusTrackerUpdater else {
                return
            }
            
            updater.timerDidUpdate(timerInfo: timerInfo)
            updater.previousTimerInfo = timerInfo
        }
        
        checkStateAndNotifyDelegatesIfNeeded()
    }
    
    /// 检查当前状态，如果状态改变则通知所有代理对象
    private func checkStateAndNotifyDelegatesIfNeeded() {
        let currentState = self.state
        let previousState = self.previousState
        if currentState != previousState {
            if currentState != .running {
                /// 当前状态为结束
                stopTimer()
            }
            
            DispatchQueue.main.async {
                self.notifyDelegates { (delegate: FocusTrackerDelegate) in
                    delegate.focusTrackerStateDidChange(fromState: previousState, toState: currentState)
                }
            }
        }
    
        self.previousState = currentState
    }
    
    // MARK: - 事件操作
    func performAction(_ actionType: FocusEventActionType) {
        guard let event = event else {
            return
        }

        switch actionType {
        case .start:
            event.start()
        case .pause:
            event.pause()
        case .resume:
            event.resume()
        case .next:
            event.next()
        }
        
        saveEvent()
        /// 执行操作后手动调用一次
        updateTimer()
        
        /// 重新计划通知
        scheduleNotificationHandler?()
    }
    
    /// 结束当前事件
    func stop() {
        guard let event = event, event.state != .finished  else {
            return
        }
        
        event.completeAllStep()
        saveEvent()
        updateTimer()
        scheduleNotificationHandler?()
    }
    
    /// 调整当前步骤时长
    func extendDuration() {
        guard let event = event else {
            return
        }
        
        let stepDuration = FocusSetting.shared.validatedAdjustStepDuration
        event.adjustDuration(by: TimeInterval(stepDuration))
        saveEvent()
        updateTimer()
        scheduleNotificationHandler?()
    }
    
    func reduceDuration() {
        guard let event = event else {
            return
        }
        
        let stepDuration = FocusSetting.shared.validatedAdjustStepDuration
        event.adjustDuration(by: -TimeInterval(20))
        saveEvent()
        updateTimer()
        scheduleNotificationHandler?()
    }
    
    func canIncrease(remainDuration: TimeInterval) -> Bool {
        return true
        
        let stepDuration = FocusSetting.shared.validatedAdjustStepDuration
        let maximumDuration = 10 * SECONDS_PER_MINUTE
        return remainDuration < TimeInterval(maximumDuration - stepDuration)
    }
    
    func canDecrease(remainDuration: TimeInterval) -> Bool {
        return true
        
        let stepDuration = FocusSetting.shared.validatedAdjustStepDuration
        let minimumDuration = SECONDS_PER_MINUTE
        return remainDuration > TimeInterval(minimumDuration + stepDuration)
    }
    
    /// 绑定任务
    func bindTask(_ task: TaskRepresentable?) {
        guard let event = event else {
            return
        }
        
        event.taskFeature = task?.feature
        saveEvent()
    }
    
    // MARK: - 添加/删除更新对象
    func addUpdater(_ updater: FocusTrackerUpdater) {
        if !updaters.contains(updater) {
            updaters.add(updater)
        }
        
        startTimer() /// 开始计时
    }
    
    func removeUpdater(_ updater: FocusTrackerUpdater) {
        updaters.remove(updater)
        stopTimerIfNeeded()
    }
    
    
    // MARK: - 定时器
    #warning("优化计时器触发时间间隔")
    private func startTimer() {
        timer?.invalidate()
        timer = Timer(timeInterval: 0.5,
                      target: self,
                      selector: #selector(updateTimer),
                      userInfo: nil,
                      repeats: true)
        RunLoop.current.add(timer!, forMode: .common)
        timer?.fire()
    }
       
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func stopAndUpdateTimer() {
        stopTimer()
        updateTimer() /// 手动调用一次
    }
    
    /// 当无updater时结束计时器
    private func stopTimerIfNeeded() {
        if event == nil || updaters.count == 0 {
            stopTimer()
        }
    }
}

extension FocusTracker {
    
    func addNotification() {
        // 监听通知授权成功
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNotificationAuthorizationGranted),
            name: .notificationAuthorizationGranted,
            object: nil
        )
        
        /// 监听进入前台
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: .notificationWillEnterForeground,
            object: nil
        )
    }
    
    func removeNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func willEnterForeground() {
        TPNotificationService.isAuthorized{ authorized in
            guard authorized else {
                return
            }
            
            if let isNotiAuthorized = self.isNotiAuthorized, !isNotiAuthorized {
                self.scheduleNotificationHandler?()
            }
        }
    }
    
    @objc private func handleNotificationAuthorizationGranted() {
        scheduleNotificationHandler?()
    }
}
