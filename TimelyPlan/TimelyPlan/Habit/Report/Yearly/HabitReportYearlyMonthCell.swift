//
//  HabitReportYearlyMonthCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/18.
//

import Foundation
import UIKit

class HabitReportYearlyMonthCell: TPCollectionCell {
    
    var date: Date?
    
    /// 任务
    var periodItem: HabitPeriodItem?
    
    var imageCacher: HabitReportImageCacher?
    
    /// 月视图
    private let monthImageView = UIImageView()
    
    override func setupContentSubviews() {
        monthImageView.contentMode = .scaleAspectFit
        contentView.addSubview(monthImageView)
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        monthImageView.frame = contentView.layoutFrame()
    }
    
    func reloadData() {
        guard let periodItem = periodItem, let date = date else {
            return
        }

        let firstWeekday = periodItem.period.firstWeekday
        let render = HabitReportYearlyMonthRender(date: date,
                                                  firstWeekday: firstWeekday,
                                                  periodItem: periodItem)
        let taskID = periodItem.habitTask.identifier
        let imageSize = render.canvasSize()
        let image = imageCacher?.getImage(identifier: taskID, date: date, size: imageSize)
        if image != nil {
            self.monthImageView.image = image
            return
        }
        
        self.monthImageView.image = nil
        render.renderImage { image in
            guard taskID == self.periodItem?.habitTask.identifier,
                  date == self.date else {
                return
            }
            
            self.monthImageView.image = image
            self.imageCacher?.setImage(image, identifier: taskID, date: date, size: imageSize)
        }
    }
}
