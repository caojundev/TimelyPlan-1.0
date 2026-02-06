//
//  FocusFlipClockViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/3.
//

import Foundation
import UIKit

class FocusFlipClockViewController: TPViewController,
                                    FocusTrackerUpdater {
    
    /// 顶部栏
    lazy var topbar: FocusFlipClockTopbar = {
        let bar = FocusFlipClockTopbar()
        bar.didClickClose = { [weak self] in
            self?.clickClose()
        }
        
        return bar
    }()
    
    /// 时钟视图
    lazy var clockView: FlipClockView = {
        let view = FlipClockView()
        view.autoHideHour = focus.setting.getFlipClockAutoHideHour()
        return view
    }()
    
    /// 操作视图
    lazy var actionView: FocusFlipClockActionView = {
        let view = FocusFlipClockActionView()
        view.didSelectActionType = { [weak self] actionType in
            self?.didSelectActionType(actionType)
        }
        
        return view
    }()

    let topbarHeight = 60.0
    let topbarBottomMargin = 0.0
    let actionViewHeight = 40.0
    let actionViewTopMargin = 0.0
    let actionViewBottomMargin = 10.0
    
    let tracker: FocusTracker
    
    init(tracker: FocusTracker) {
        self.tracker = tracker
        super.init(nibName: nil, bundle: nil)
        self.topbar.title = tracker.eventTimerFeature?.shotName
        self.tracker.addUpdater(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(topbar)
        view.addSubview(clockView)
        view.addSubview(actionView)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.safeLayoutFrame()
        
        topbar.width = layoutFrame.width
        topbar.height = topbarHeight
        topbar.origin = layoutFrame.origin
        
        actionView.width = layoutFrame.width
        actionView.height = actionViewHeight
        actionView.bottom = layoutFrame.maxY - actionViewBottomMargin
        actionView.left = layoutFrame.minX
        
        let clockViewHeight = actionView.top - actionViewTopMargin - topbar.bottom - topbarBottomMargin
        clockView.width = layoutFrame.width
        clockView.height = clockViewHeight
        clockView.left = layoutFrame.minX
        clockView.top = topbar.bottom + topbarBottomMargin
    }
    
    override var themeBackgroundColor: UIColor? {
        return .black
    }
    
    func clickClose() {
        dismiss(animated: true, completion: nil)
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.landscapeRight]
    }
    
    
    // MARK: - Event Response
    
    /// 选中操作类型
    func didSelectActionType(_ actionType: FocusEventActionType) {
        tracker.performAction(actionType)
    }
    
    
    // MARK: - FocusTimerUpdater
    
    var previousTimerInfo: FocusTimerInfo?
    
    func timerDidUpdate(timerInfo: FocusTimerInfo) {
        let duration: TimeInterval
        if timerInfo.timerType == .stopwatch {
            duration = timerInfo.elapsedDuration
        } else {
            duration = timerInfo.remainDuration
        }
        
        /// 更新翻页时钟
        clockView.update(with: duration)
        
        var isStateChanged = false
        let currentState = timerInfo.state
        if currentState != previousTimerInfo?.state {
            isStateChanged = true
        }
        
        /// 状态改变或步骤改变，更新操作按钮
        if isStateChanged || timerInfo.stepIndex != previousTimerInfo?.stepIndex {
            actionView.actionTypes = timerInfo.eventActionTypes()
            topbar.subtitle = timerInfo.stepIndexAndNameString
        }
    }
}
