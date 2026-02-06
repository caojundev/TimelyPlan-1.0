//
//  StopwatchProgressInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/5.
//

import Foundation

class StopwatchProgressInfoView: FocusTimerProgressInfoView {
    
    /// 进度视图
    let progressView = StopwatchTimerProgressView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        let duration = info?.elapsedDuration ?? 0.0
        infoView.timeLabel.text = duration.timeString
        progressView.setDuration(duration)
    }
}
