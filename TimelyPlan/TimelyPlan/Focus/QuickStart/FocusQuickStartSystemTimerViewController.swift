//
//  FocusQuickStartSystemTimerViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/26.
//

import Foundation

class FocusQuickStartSystemTimerViewController: TPViewController,
                                                TPAnimatedContainerViewDelegate {
    
    /// 点击开始
    var didClickStart: ((FocusSystemTimer) -> Void)?
    
    /// 计时器类型
    let timerType: FocusTimerType
    
    private lazy var pomodoroTimer: FocusSystemPomodoroTimer = {
        let config = FocusState.shared.pomodoroConfig
        return FocusSystemPomodoroTimer(config: config)
    }()
    
    private lazy var countdownTimer: FocusSystemCountdownTimer = {
        let config = FocusState.shared.countdownConfig
        return FocusSystemCountdownTimer(config: config)
    }()
    
    private lazy var stopwatchTimer: FocusSystemStopwatchTimer = {
        return FocusSystemStopwatchTimer()
    }()

    /// 计时器视图
    private var editContainerView: TPAnimatedContainerView = TPAnimatedContainerView()

    /// 动作视图
    private lazy var startButton: TPImageButton = { [weak self] in
        let button = TPImageButton()
        button.imageSize = .size(7)
        button.normalImage = resGetImage("triangle_right_32")
        let color = Color(light: 0x343434, dark: 0xEFEFEF, alpha: 0.8)
        button.normalImageColor = color
        button.normalBorderColor = color
        button.borderWidth = 3.0
        button.cornerRadius = .greatestFiniteMagnitude
        button.normalBackgroundColor = .clear
        button.selectedBackgroundColor = .clear
        button.addTarget(self, action: #selector(clickStart), for: .touchUpInside)
        return button
    }()

    private let editContainerHeight = 400.0
    private let editContainerTopMargin = 10.0
    private let startButtonSize = CGSize(width:160.0, height: 52.0)

    init(timerType: FocusTimerType) {
        self.timerType = timerType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.padding = UIEdgeInsets(horizontal: 10.0)
        self.editContainerView.delegate = self
        view.addSubview(editContainerView)
        view.addSubview(startButton)
        updateContent(with: timerType)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.layoutFrame()
        editContainerView.width = view.width
        editContainerView.height = editContainerHeight
        editContainerView.top = editContainerTopMargin
  
        startButton.size = startButtonSize
        startButton.top = editContainerView.bottom + (layoutFrame.maxY - editContainerView.bottom - startButtonSize.height) / 2.0
        startButton.alignHorizontalCenter()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    private func updateContent(with timerType: FocusTimerType) {
        let editView: UIView
        switch timerType {
        case .pomodoro:
            let view = PomodoroTimerEditView()
            view.didChangeConfig = { [weak self] config in
                self?.pomodoroTimer.config = config
                self?.didChangePomodoroConfig(config)
            }
            
            view.didChangeEditPhase = { [weak self] phase in
                self?.didChangePomodoroPhase(phase)
            }
            
            view.setConfig(pomodoroTimer.config, animated: true)
            editView = view
        case .countdown:
            let view = CountdownTimerEditView()
            let duration = countdownTimer.config.duration ?? FocusCountdownConfig.defaultDuration
            view.setDurationWithAnimationFromZero(duration)
            view.didEndEditing = { [weak self] duration in
                let config = FocusCountdownConfig(duration: duration)
                self?.countdownTimer.config = config
                self?.didChangeCountdownConfig(config)
            }
            
            editView = view
        case .stopwatch, .stepped:
            let view = StopwatchProgressInfoView()
            view.infoView.subtitleLabel.text = resGetString("Counting from zero")
            view.progressView.commitStrokeAnimation()
            editView = view
        }
        
        self.editContainerView.setContentView(editView, animateStyle: .none, complection: nil)
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
            timer = nil
        }

        return timer
    }
    
    @objc private func clickStart() {
        if let timer = currentSytemTimer() {
            didClickStart?(timer)
        }
    }
    
    private func didChangePomodoroConfig(_ config: FocusPomodoroConfig) {
        
    }
    
    private func didChangePomodoroPhase(_ phase: FocusPomodoroPhase) {
        
    }
    
    func didChangeCountdownConfig(_ config: FocusCountdownConfig) {
        
    }
    
    // MARK: - ContainerViewDelegate
    func animatedContainerView(_ containerView: TPAnimatedContainerView, frameForContentView contentView: UIView) -> CGRect {
        let width = min(containerView.width - 20.0, 320.0)
        let contentSize = CGSize(width: width, height: editContainerHeight)
        let origin = CGPoint(x: (containerView.size.width - contentSize.width) / 2.0,
                             y: (containerView.size.height - contentSize.height) / 2.0)
        return CGRect(origin: origin, size: contentSize)
    }
    
}
