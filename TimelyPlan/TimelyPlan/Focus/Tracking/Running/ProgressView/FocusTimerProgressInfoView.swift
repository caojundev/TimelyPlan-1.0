//
//  TimerProgressInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/5.
//

import Foundation
import UIKit

protocol FocusTimerProgressInfoViewDelegate: AnyObject {
    
    /// 点击进度信息视图
    func progressInfoViewDidTap(_ view: FocusTimerProgressInfoView)
    
    /// 点击微调减
    func progressInfoViewDidClickDecrease(_ view: FocusTimerProgressInfoView)

    /// 点击微调加
    func progressInfoViewDidClickIncrease(_ view: FocusTimerProgressInfoView)
    
    func progressInfoView(_ view: FocusTimerProgressInfoView, canDecrease remainDuration: TimeInterval) -> Bool
    func progressInfoView(_ view: FocusTimerProgressInfoView, canIncrease remainDuration: TimeInterval) -> Bool
}

class FocusTimerProgressInfoView: UIView {

    /// 代理对象
    weak var delegate: FocusTimerProgressInfoViewDelegate?
    
    var timerInfo: FocusTimerInfo? {
        didSet {
            update(with: timerInfo)
        }
    }
    
    /// 微调视图显示日期范围
    var dateRange: DateRange? {
        get {
            return adjustView?.dateRange
        }
        
        set {
            adjustView?.dateRange = newValue
        }
    }
    
    var alarmDate: Date? {
        get {
            return infoView.alarmDate
        }
        
        set {
            infoView.alarmDate = newValue
        }
    }
    
    // MARK: - 暂停
    var isPaused: Bool = false {
        didSet {
            guard isPaused != oldValue else {
                return
            }
            
            if isPaused {
                infoView.subtitleLabel.text = resGetString("Paused")
            } else {
                infoView.subtitleLabel.text = subtitle
            }
        }
    }
    
    /// 副标题文本
    var subtitle: String? {
        return timerInfo?.stepName
    }
    
    /// 信息视图高度
    var infoHeight = 70.0
    
    /// 信息视图与左边界间距
    var infoMargin = 20.0
    
    /// 信息视图
    let infoView = FocusTimerInfoView()
    
    /// 微调视图
    private weak var adjustView: FocusTimerAdjustView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(infoView)
        let recognizer = UITapGestureRecognizer(target: self,
                                                action: #selector(handleTap(_:)))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        addGestureRecognizer(recognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = infoLayoutFrame()
        infoView.width = layoutFrame.width
        infoView.height = infoHeight
        infoView.alignCenter()
        
        if let adjustView = adjustView {
            adjustView.infoViewFrame = infoView.frame
            adjustView.alpha = 1.0
            adjustView.frame = bounds
            infoView.setInfoHidden(true, animated: true)
        } else {
            infoView.setInfoHidden(false, animated: true)
        }
    }
    
    private func infoLayoutFrame() -> CGRect {
        let radius = bounds.shortSideLength / 2.0 - infoMargin
        let infoSize: CGSize = .circleInnerLabelSize(radius: radius)
        return CGRect(x: (width - infoSize.width) / 2.0,
                      y: (height - infoSize.width) / 2.0,
                      size: infoSize)
    }
    
    func progressViewFrame() -> CGRect {
        let layoutFrame = bounds
        let progressWidth = layoutFrame.shortSideLength
        return CGRect(x: (width - progressWidth) / 2.0,
                      y: (height - progressWidth) / 2.0,
                      width: progressWidth,
                      height: progressWidth)
    }

    // MARK: - Event Response
    @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
        if let adjustView = adjustView {
            let location = recognizer.location(in: self)
            if isPoint(location, onSubview: adjustView.buttonView) {
                /// 点击在微调按钮视图上，无操作
                return
            }
        }
        
        delegate?.progressInfoViewDidTap(self)
        
        /// 更新微调按钮状态
        updateAdjustView(with: timerInfo)
    }

    // MARK: - update
    /// 更新计时标签信息
    func updateTime(with info: FocusTimerInfo?) {
        let remainDuration = info?.remainDuration ?? 0.0
        infoView.timeLabel.text = remainDuration.timeString
        updateAdjustView(with: remainDuration)
    }
    
    /// 更新微调按钮
    func updateAdjustView(with info: FocusTimerInfo?) {
        guard adjustView != nil else {
            return
        }
        
        let remainDuration = info?.remainDuration ?? 0.0
        updateAdjustView(with: remainDuration)
    }

    func updateAdjustView(with remainDuration: TimeInterval) {
        if let adjustView = adjustView {
            let canDecrease = self.delegate?.progressInfoView(self, canDecrease: remainDuration) ?? false
            let canIncrease = self.delegate?.progressInfoView(self, canIncrease: remainDuration) ?? false
            adjustView.canDecrease = canDecrease
            adjustView.canIncrease = canIncrease
        }
    }
    
    /// 更新数据
    func update(with info: FocusTimerInfo?) {
        updateTime(with: info)
        if !isPaused {
            infoView.subtitleLabel.text = subtitle
        }
    }

    // MARK: - 微调视图
    var isTimeAdjustViewHidden: Bool {
        return adjustView == nil
    }
    
    func showTimeAdjustView() {
        if let adjustView = adjustView {
            adjustView.restartTimer()  /// 重置开始计时器
            return
        }

        let adjustView = FocusTimerAdjustView(frame: bounds)
        adjustView.didClickDecrease = { [weak self] in
            guard let self = self else {
                return
            }
            
            self.delegate?.progressInfoViewDidClickDecrease(self)
        }
        
        adjustView.didClickIncrease = { [weak self] in
            guard let self = self else {
                return
            }
            
            self.delegate?.progressInfoViewDidClickIncrease(self)
        }
        
        addSubview(adjustView)
        adjustView.autoRemove(withDuration: 4.0)
        self.adjustView = adjustView
        self.setNeedsLayout()
    }
    
    func hideTimeAdjustView() {
        self.adjustView?.remove()
        self.adjustView = nil
    }
}
