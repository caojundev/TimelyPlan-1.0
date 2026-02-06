//
//  FocusStartViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/6/19.
//

import UIKit

class FocusStartViewController: TPViewController,
                                    TPAnimatedContainerViewDelegate,
                                    FocusTrackerDelegate {
    
    var timerType: FocusTimerType = .defaultType
    
    var pomodoroTimer = FocusSystemPomodoroTimer()
    
    var countdownTimer = FocusSystemCountdownTimer()
    
    var stopwatchTimer = FocusSystemStopwatchTimer()

    lazy var timerTypeMenuView: TPSegmentedMenuView = {
        let view = TPSegmentedMenuView()
        view.normalBackgroundColor = .clear
        view.buttonNormalBackgroundColor = Color(0x888888, 0.1)
        view.buttonHighlightedBackgroundColor = Color(0x888888, 0.2)
        view.imagePosition = .top
        view.imageConfig.size = .default
        view.didSelectMenuItem = { [weak self] menuItem in
            if let type = FocusTimerType(rawValue: menuItem.tag) {
                self?.didSelectTimerType(type)
            }
        }
        
        view.menuItems = FocusTimerType.defaultTypes.segmentedMenuItems()
        view.sizeToFit()
        return view
    }()

    /// 计时器视图
    var editContainerView: TPAnimatedContainerView = TPAnimatedContainerView()

    /// 动作视图
    private lazy var actionView: FocusStartActionView = { [weak self] in
        let view = FocusStartActionView()
        view.didClickStart = {
            self?.didClickStart()
        }
        
        view.didClickFocusing = {
            self?.didClickFocusing()
        }
        
        return view
    }()
    
    let defaultPadding = UIEdgeInsets(horizontal: 10.0)
    var editContainerHeight = 400.0
    
    let timerTypeMenuPadding = UIEdgeInsets(value: 6.0)
    let timerTypeMenuCornerRadius = 18.0
    let timerTypeMenuItemMargin = 15.0
    let timerTypeMenuWidth = 360.0
    let timerTypeMenuHeight = 90.0
    let timerTypeMenuTop = 10.0
    
    var bottomBarHeight: CGFloat = 60.0
    
    
    let actionViewBottomMargin = 10.0
    let preferredActionViewSize = CGSize(width:360.0, height: 64.0)
    let preferredTaskPickerSize = CGSize(width: 280.0, height: 40.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.padding = defaultPadding
        editContainerView.delegate = self
        view.addSubview(editContainerView)
        view.addSubview(timerTypeMenuView)
        view.addSubview(actionView)
        timerTypeMenuView.selectMenu(withTag: timerType.tag)
        updateContent(with: timerType, animateStyle: .none)
        updateActionView()
        FocusTracker.shared.addDelegate(self)
    }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addAppLifeCycleNotification()
        actionView.isDisplaying = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeAppLifeCycleNotification()
        actionView.isDisplaying = false
    }
    
    override func appDidBecomeActive() {
        actionView.isDisplaying = true
    }
    
    override func appDidEnterBackground() {
        actionView.isDisplaying = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.layoutFrame()
        timerTypeMenuView.padding = timerTypeMenuPadding
        timerTypeMenuView.cornerRadius = timerTypeMenuCornerRadius
        timerTypeMenuView.margin = timerTypeMenuItemMargin
        timerTypeMenuView.width = min(timerTypeMenuWidth, layoutFrame.width)
        timerTypeMenuView.height = timerTypeMenuHeight
        timerTypeMenuView.top = timerTypeMenuTop
        timerTypeMenuView.alignHorizontalCenter()

        actionView.size = preferredActionViewSize.fitSize(with: layoutFrame)
        actionView.bottom = view.safeLayoutFrame().maxY - actionViewBottomMargin
        actionView.alignHorizontalCenter()

        let margin = (actionView.top - timerTypeMenuView.bottom - editContainerHeight - preferredTaskPickerSize.height) / 3.0
        editContainerView.width = view.width
        editContainerView.height = editContainerHeight
        editContainerView.top = timerTypeMenuView.bottom + margin
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    private func updateContent(with timerType: FocusTimerType, animateStyle: SlideStyle) {
        let editView: UIView
        switch timerType {
        case .pomodoro:
            let view = PomodoroTimerEditView()
            view.setConfig(pomodoroTimer.config, animated: true)
            view.configDidChange = { [weak self] config in
                self?.pomodoroTimer.config = config
            }
            
            editView = view
        case .countdown:
            let view = CountdownTimerEditView()
            let duration = countdownTimer.config.duration ?? FocusCountdownConfig.defaultDuration
            view.setDurationWithAnimationFromZero(duration)
            view.didEndEditing = { [weak self] duration in
                self?.countdownTimer.config = FocusCountdownConfig(duration: duration)
            }
            
            editView = view
        case .stopwatch, .stepped:
            let view = StopwatchProgressInfoView()
            view.infoView.subtitleLabel.text = resGetString("Counting from zero")
            view.progressView.commitStrokeAnimation()
            editView = view
        }
        
        editContainerView.setContentView(editView,
                                         animateStyle: .none,
                                         complection: nil)
    }
    
    private func updateActionView(with state: FocusTrackerState? = nil) {
        let state = state ?? FocusTracker.shared.state
        if state == .waiting {
            actionView.mode = .waiting
            return
        }
        
        /// 非waiting状态，检查当前计时器是否
        var mode = FocusStartActionView.Mode.waiting
        if let focusingTimerID = FocusTracker.shared.eventTimerFeature?.identifier,
           let currentSystemTimer = currentSytemTimer(),
           currentSystemTimer.identifier == focusingTimerID {
            /// 当前计时器正在计时中
            mode = .focusing
        }
        
        actionView.mode = mode
    }
    
    private func didSelectTimerType(_ type: FocusTimerType) {
        if timerType == type {
            return
        }
    
        let fromValue = timerType.index ?? 0
        let toValue = type.index ?? 0
        timerType = type
        
        /// 切换动画样式
        let style = SlideStyle.horizontalStyle(fromValue: fromValue, toValue: toValue)
        updateContent(with: type, animateStyle: style)
        
        /// 更新操作视图
        updateActionView()
    }
    
    /// 当前选中的系统计时器
    private func currentSytemTimer() -> FocusSystemTimer? {
        var timer: FocusSystemTimer?
        switch timerType {
        case .pomodoro:
            timer = pomodoroTimer
        case .countdown:
            timer = countdownTimer
        case .stopwatch:
            timer = stopwatchTimer
        case .stepped:
            break
        }

        return timer
    }
    
    private func didClickStart() {
        if let timer = currentSytemTimer() {
            FocusPresenter.startFocus(with: timer)
        }
    }
    
    private func didClickFocusing() {
        FocusPresenter.showTrackingViewControllerIfNeeded()
    }
    
    // MARK: - ContainerViewDelegate
    func animatedContainerView(_ containerView: TPAnimatedContainerView, frameForContentView contentView: UIView) -> CGRect {
        let width = min(containerView.width - 20.0, 340.0)
        let contentSize = CGSize(width: width, height: editContainerHeight)
        let origin = CGPoint(x: (containerView.size.width - contentSize.width) / 2.0,
                             y: (containerView.size.height - contentSize.height) / 2.0)
        return CGRect(origin: origin, size: contentSize)
    }
    
    // MARK: - FocusTrackerDelegate
    func focusTrackerStateDidChange(fromState: FocusTrackerState?, toState: FocusTrackerState) {
        updateActionView(with: toState)
    }
}
