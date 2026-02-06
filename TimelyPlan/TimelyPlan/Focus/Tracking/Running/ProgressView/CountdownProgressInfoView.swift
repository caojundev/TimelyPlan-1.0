//
//  CountdownProgressInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/5.
//

import Foundation

class CountdownProgressInfoView: FocusTimerProgressInfoView {
    
    /// 进度视图
    let progressView = CountdownTimerProgressView()
    
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
        super.updateTime(with: info)
        progressView.duration = info?.remainDuration ?? 0.0
    }
}
