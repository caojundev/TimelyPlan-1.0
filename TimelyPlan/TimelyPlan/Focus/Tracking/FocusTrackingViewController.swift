//
//  FocusTimerCountingViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/6.
//

import Foundation

class FocusTrackingViewController: TPContainerViewController,
                                   FocusTrackerDelegate {

    var state: FocusTrackerState?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateContentViewController(animated: false)
        FocusTracker.shared.addDelegate(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /// 请求通知授权
        TPNotificationService.allowAccessIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isBeingPresented {
            FocusTracker.shared.didPresentedTrackingViewController(self)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isBeingDismissed {
            FocusTracker.shared.didDismissTrackingViewController(self)
        }
    }
    
    // MARK: - 更新内容视图控制器
    func updateContentViewController(animated: Bool) {
        let state = FocusTracker.shared.state
        updateContentViewController(state: state, animated: animated)
    }
    
    func updateContentViewController(state: FocusTrackerState,
                                     endDataItem: FocusEndDataItem? = nil,
                                     animated: Bool = true) {
        guard self.state != state else {
            return
        }
        
        var style = SlideStyle.none
        if animated {
            let fromValue = self.state?.rawValue ?? -1
            style = .horizontalStyle(fromValue: fromValue, toValue: state.rawValue)
        }
        
        self.state = state
        
        var viewController: UIViewController?
        switch state {
        case .waiting:
            viewController = nil
        case .running:
            viewController = FocusRunningViewController()
        case .ended:
            let dataItem: FocusEndDataItem
            if let endDataItem = endDataItem {
                dataItem = endDataItem
            } else {
                dataItem = FocusTracker.shared.endDataItem
            }
            
            viewController = FocusEndViewController(dataItem: dataItem)
        }
        
        if let viewController = viewController {
            setContentViewController(viewController, withAnimationStyle: style)
        }
    }
    
    
    // MARK: - FocusTrackerDelegate
    func focusTrackerStateDidChange(fromState: FocusTrackerState?, toState: FocusTrackerState) {
        guard toState == .ended else {
            updateContentViewController(animated: true)
            return
        }
        
        /// 移除追踪代理
        FocusTracker.shared.removeDelegate(self)
        
        /// 检查本轮专注结束数据条目
        let endDataItem = FocusTracker.shared.endDataItem
        if endDataItem.isValidFocusRecordExist {
            updateContentViewController(state: .ended, endDataItem: endDataItem, animated: true)
            /// 关闭弹出的模态视图控制器
            if presentedViewController != nil {
                dismiss(animated: true, completion: nil)
            }
        } else {
            /// 清除当前事件
            FocusTracker.shared.clearEvent()
            /// 关闭视图控制器
            presentingViewController?.dismiss(animated: true, completion: nil)
            
            /// 提醒无有效记录
            let duration = endDataItem.minimumRecordDuration
            if duration > 0 {
                let format = resGetString("There is no focused record over %@ in this round.")
                let message = String(format: format, duration.localizedTitle)
                TPFeedbackQueue.common.postFeedback(text: message, position: .top)
            }
        }
    }
}
