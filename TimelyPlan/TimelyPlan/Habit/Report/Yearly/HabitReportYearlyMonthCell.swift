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
        
        /// 开始渲染图片
        let requestID = requestManager.executeRequest()
        render.renderImage { image in
            guard self.requestManager.shouldProceed(with: requestID) else {
                return
            }
            
            self.monthImageView.image = image
            self.imageCacher?.setImage(image, identifier: taskID, date: date, size: imageSize)
        }
    }
}
