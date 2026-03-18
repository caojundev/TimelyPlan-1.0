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
    var periodTask: HabitPeriodTask?
    
    /// 月视图
    private let monthImageView = UIImageView()
    
    /// 数据请求管理器
    private let requestManager = TPRequestManager()
    
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
        self.monthImageView.image = nil
        guard let periodTask = periodTask, let date = date else {
            return
        }

        let requestID = requestManager.executeRequest()
        let firstWeekday = periodTask.period.firstWeekday
        let render = HabitReportYearlyMonthRender(date: date,
                                                  firstWeekday: firstWeekday,
                                                  periodTask: periodTask)
        render.renderImage { image in
            guard self.requestManager.shouldProceed(with: requestID) else {
                return
            }
            
            self.monthImageView.image = image
        }
    }
}
