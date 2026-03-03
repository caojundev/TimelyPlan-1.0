//
//  HabitTaskProgressInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/3.
//

import Foundation

class HabitTaskProgressInfoView: HabitTaskDefaultInfoView {
    
//    /// 任务状态视图
//    var statusView: TaskStatusView!

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

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.progressView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progressView.frame = iconView.frame
        progressView.radius = iconView.cornerRadius
    }
    
    func setProgress(_ progress: CGFloat, animated: Bool = false) {
        progressView.setProgress(progress, animated: animated)
    }
}
