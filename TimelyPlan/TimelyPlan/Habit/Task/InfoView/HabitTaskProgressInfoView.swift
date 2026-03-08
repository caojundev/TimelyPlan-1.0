//
//  HabitTaskProgressInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/3.
//

import Foundation

class HabitTaskProgressInfoView: HabitTaskDefaultInfoView {
    
    var progress: CGFloat {
        get {
            return progressView.progress
        }
        
        set {
            setProgress(newValue)
        }
    }
    
    /// 进度视图
    let progressLineWidth: CGFloat = 4.0
    
    lazy var progressView: TPCircleOutlineProgressView = {
        let view = TPCircleOutlineProgressView()
        view.progressLineWidth = progressLineWidth
        return view
    }()
    
    /// 任务状态视图
    lazy var statusView: HabitTaskStatusView = {
        let view = HabitTaskStatusView(frame: bounds)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.progressView)
        self.addSubview(self.statusView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.progressView.frame = iconView.frame
        self.progressView.radius = iconView.cornerRadius
        self.statusView.frame = iconView.frame
    }
    
    func setProgress(_ progress: CGFloat, animated: Bool = false) {
        self.progressView.setProgress(progress, animated: animated)
    }
    
    func setStatus(_ status: HabitTaskStatus, animated: Bool = false) {
        self.statusView.setStatus(status, animated: animated)
    }
}
