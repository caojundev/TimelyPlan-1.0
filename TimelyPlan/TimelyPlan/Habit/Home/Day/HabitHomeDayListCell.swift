//
//  HabitHomeDayListCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/3.
//

import Foundation
import UIKit

class HabitHomeDayListCell: HabitTaskListDefaultInfoCell {
    
    var task: HabitPeriodTask? {
        didSet {
            updateTaskInfo()
        }
    }
    
    let progressInfoView = HabitTaskProgressInfoView()
    
    override func setupInfoView() {
        self.infoView = progressInfoView
    }
    
    override func updateStyleWithColor(_ color: UIColor) {
        super.updateStyleWithColor(color)
        let progressView = progressInfoView.progressView
        progressView.progressLineColor = color.lighterColor
        progressView.backLineColor = Color(0x000000, 0.4)
    }
    
    /// 更新任务信息
    func updateTaskInfo() {
        updateInfo(with: task?.habitTask)
        updateProgress(animated: true)
    }
    
    func updateProgress(animated: Bool) {
        let progress = CGFloat(arc4random() % 100) / 100.0
        progressInfoView.setProgress(progress, animated: animated)
    }
}
