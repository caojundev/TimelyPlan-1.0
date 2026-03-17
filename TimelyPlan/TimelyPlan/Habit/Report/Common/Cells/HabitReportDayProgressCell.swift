//
//  HabitReportDayProgressCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/17.
//

import Foundation
import QuartzCore
import UIKit

class HabitReportDayProgressCell: HabitReportDayCell {
    
    private var statusSize: CGSize = .size(5)
    
    private let statusLayer = CALayer()
    
    private var progress: CGFloat {
        guard let periodTask = periodTask, let date = date else {
            return 0.0
        }

        return periodTask.progress(on: date)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.statusLayer.cornerRadius = 6.0
        self.contentView.layer.addSublayer(self.statusLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let x = (bounds.width - statusSize.width) / 2.0
        let y = (bounds.height - statusSize.height) / 2.0
        self.statusLayer.frame = CGRect(x: x, y: y, size: statusSize)
        CATransaction.commit()
    }
    
    override func reloadData() {
        let progress = self.progress
        if progress == 0.0 {
            /// 未开始
            statusLayer.backgroundColor = UIColor.secondarySystemFill.cgColor
            statusLayer.opacity = 0.6
        } else {
            statusLayer.backgroundColor = taskColor.cgColor
            statusLayer.opacity = Float(clampedValue(progress, 0.2, 1.0))
        }
    }
}
