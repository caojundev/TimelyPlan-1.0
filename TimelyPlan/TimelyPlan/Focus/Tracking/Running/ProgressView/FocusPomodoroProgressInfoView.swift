//
//  PomodoroProgressInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/5.
//

import Foundation

class FocusPomodoroProgressInfoView: FocusTimerProgressInfoView {
    
    /// 进度视图
    let progressView = FocusPomodoroProgressView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        infoMargin = 35.0 /// 间距
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

        progressView.stepIndex = info.stepIndex
        progressView.progress = info.elapsedDuration / info.totalDuration
    }
}
