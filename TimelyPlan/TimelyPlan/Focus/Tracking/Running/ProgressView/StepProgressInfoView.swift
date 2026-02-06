//
//  StepProgressInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/25.
//

import Foundation

class StepProgressInfoView: FocusTimerProgressInfoView {
    
    /// 进度视图
    let progressView = TPCircleOutlineProgressView()
    
    override var subtitle: String? {
        return timerInfo?.stepIndexAndNameString
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        progressView.backLineWidth = 12.0
        progressView.progressLineWidth = 16.0
        progressView.backLineColor = Color(0x888888, 0.1)
        insertSubview(progressView, belowSubview: infoView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progressView.frame = progressViewFrame()
    }
    
    override func updateTime(with info: FocusTimerInfo?) {
        super.updateTime(with: info)
        
        guard let info = info else {
            return
        }
        
        /// 更新颜色
        let color = info.color ?? FocusTimerStep.defaultColor
        if progressView.progressLineColor != color {
            progressView.progressLineColor = color
        }
        
        /// 更新进度
        let progress = 1.0 - info.elapsedDuration / info.totalDuration
        progressView.progress = progress
    }
}
