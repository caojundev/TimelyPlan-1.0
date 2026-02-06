//
//  FocusFloatingTimerRunningView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/25.
//

import Foundation
import UIKit

fileprivate class FocusFloatingCountdownTimerView: FocusFloatingTimerView {
    private lazy var barProgressView: TPBarProgressView = {
        let view = TPBarProgressView()
        view.isReversed = true
        return view
    }()
    
    override func newProgressView() -> UIView {
        return barProgressView
    }
    
    override func updateProgressStyle(with color: UIColor) {
        barProgressView.barForeColor = color.withBrightness(1.0).withSaturation(0.2)
        barProgressView.barBackColor = color.withBrightness(0.2)
    }
    
    override func updateProgress(with timerInfo: FocusTimerInfo) {
        barProgressView.progress = timerInfo.elapsedDuration / timerInfo.totalDuration
    }
}

fileprivate class FocusFloatingStopwatchTimerView: FocusFloatingTimerView {
    private lazy var stopwatchProgressView: FocusFloatingStopwatchProgressView = {
        let view = FocusFloatingStopwatchProgressView()
        return view
    }()
    
    override func newProgressView() -> UIView {
        return stopwatchProgressView
    }
    
    override func updateProgressStyle(with color: UIColor) {
        stopwatchProgressView.foreScaleColor = color.withBrightness(1.0).withSaturation(0.2)
        stopwatchProgressView.backScaleColor = color.withBrightness(0.2)
    }
    
    override func updateProgress(with timerInfo: FocusTimerInfo) {
        stopwatchProgressView.setDuration(timerInfo.elapsedDuration)
    }
}

class FocusFloatingTimerView: UIView, FocusTrackerUpdater {

    /// 计时器信息视图
    private lazy var infoView: FocusFloatingTimerInfoView = {
        let view = FocusFloatingTimerInfoView()
        return view
    }()

    /// 进度条视图
    var progressHeight = 5.0
    private lazy var progressView: UIView = {
        return newProgressView()
    }()
    
    /// 操作视图
    private let actionViewHeight = 30.0
    private lazy var actionView: FocusFloatingTimerActionView = {
        let view = FocusFloatingTimerActionView()
        view.backgroundColor = Color(0x343434)
        view.didSelectActionType = {[weak self] actionType in
            FocusTracker.shared.performAction(actionType)
        }
        
        return view
    }()
    
    private lazy var coverView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.1
        return view
    }()
    
    /// 主题颜色
    private var themeColor: UIColor?

    /// 根据计时器类型返回特定的计时器视图
    class func timerView(with type: FocusTimerType) -> FocusFloatingTimerView {
        switch type {
        case .pomodoro, .countdown, .stepped:
            return FocusFloatingCountdownTimerView()
        case .stopwatch:
            return FocusFloatingStopwatchTimerView()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubviews()
        self.updateTheme(with: .primary)
        FocusTracker.shared.addUpdater(self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didChangeNextButtonHiddenSetting),
                                               name: FocusSetting.didChangeFloatingTimerNextButtonHiddenNotification,
                                               object: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    func setupSubviews() {
        self.addSubview(coverView)
        self.addSubview(infoView)
        self.addSubview(progressView)
        self.addSubview(actionView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        coverView.frame = bounds
        
        actionView.width = width
        actionView.height = actionViewHeight
        actionView.bottom = height
        
        progressView.width = width
        progressView.height = progressHeight
        progressView.bottom = actionView.top
        
        infoView.width = width
        infoView.height = height - actionViewHeight - progressHeight
    }
    
    private func updateTheme(with color: UIColor?) {
        guard color != themeColor else {
            return
        }
        
        let color = color ?? .primary
        themeColor = color
        backgroundColor = color
        updateProgressStyle(with: color)
        let lighterColor = color.withBrightness(1.0).withSaturation(0.2)
        infoView.tintColor = lighterColor
        actionView.tintColor = lighterColor
    }
    
    func newProgressView() -> UIView {
        return UIView()
    }
  
    func updateProgressStyle(with color: UIColor) {
        /// 子类重写，更新进度视图样式
    }
    
    func updateProgress(with timerInfo: FocusTimerInfo) {
        /// 子类重写，更新进度
    }
    
    // MARK: - Event Response
    @objc private func didChangeNextButtonHiddenSetting() {
        /// 更新操作按钮
        actionView.updateActionTypes()
    }
    
    // MARK: - FocusTimerUpdater
    var previousTimerInfo: FocusTimerInfo?
    
    func timerDidUpdate(timerInfo: FocusTimerInfo) {
        /// 更新样式
        updateTheme(with: timerInfo.color)
        
        /// 更新信息视图
        infoView.update(with: timerInfo)
        
        /// 更新进度
        updateProgress(with: timerInfo)
        
        /// 更新操作按钮
        if timerInfo.state != previousTimerInfo?.state || timerInfo.stepIndex != previousTimerInfo?.stepIndex {
            actionView.updateActionTypes(with: timerInfo)
        }
    }
}
