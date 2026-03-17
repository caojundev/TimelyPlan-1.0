//
//  HabitReportDayCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/17.
//

import Foundation
import UIKit

class HabitReportDayCell: UICollectionViewCell {
    
    var periodTask: HabitPeriodTask?
    
    var date: Date?
    
    var taskColor: UIColor {
        return periodTask?.habitTask.color ?? .secondarySystemFill
    }
    
    var status: HabitTaskStatus {
        guard let periodTask = periodTask, let date = date else {
            return .notStarted
        }

        return periodTask.status(on: date)
    }

    func reloadData() {
        
    }
    
    static func cellClass(for periodTask: HabitPeriodTask?, on date: Date?) -> AnyClass? {
        guard let periodTask = periodTask, let date = date else {
            return nil
        }

        let isScheduled = periodTask.isScheduledDate(date)
        if !isScheduled {
            return HabitReportNotScheduledCell.self
        }
        
        let status = periodTask.status(on: date)
        switch status {
        case .notStarted, .inProgress, .completed:
            return HabitReportDayProgressCell.self
        case .skipped(_):
            return HabitReportSkippedCell.self
        case .failed(_):
            return HabitReportFailedCell.self
        }
    }
}

class HabitReportDayImageCell: HabitReportDayCell {
    
    var imageSize: CGSize = .size(5)
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.size = imageSize
        contentView.addSubview(imageView)
        setupImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.center = bounds.center
    }
    
    func setupImage() {
        
    }
}

class HabitReportNotScheduledCell: HabitReportDayImageCell {
    
    override func setupImage() {
        imageView.image = resGetImage("habit_report_notScheduled_20")
        imageView.alpha = 0.6
    }
}

class HabitReportSkippedCell: HabitReportDayImageCell {
    
    override func setupImage() {
        imageView.image = resGetImage("habit_report_skipped_20")
    }
    
    override func reloadData() {
        /// 更新颜色为任务色
        imageView.updateImage(withColor: taskColor)
    }
}

class HabitReportFailedCell: HabitReportDayImageCell {
    
    override func setupImage() {
        imageView.image = resGetImage("habit_report_failed_20")
        imageView.alpha = 0.6
    }
}
