//
//  HabitReportMonthlyCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/17.
//

import Foundation
import UIKit

class HabitReportMonthlyCell: TPCollectionCell {
    
    static let infoViewHeight: CGFloat = 30.0
    
    /// 任务
    var periodItem: HabitPeriodItem?
    
    var imageCacher: HabitReportImageCacher?

    /// 任务信息视图
    private(set) lazy var infoView: HabitReportIconInfoView = {
        let view = HabitReportIconInfoView()
        view.titleView.titleConfig.numberOfLines = 1
        return view
    }()

    /// 月视图
    private let monthImageView = UIImageView()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(infoView)
        
        monthImageView.contentMode = .scaleAspectFit
        contentView.addSubview(monthImageView)
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = contentView.layoutFrame()
        infoView.width = layoutFrame.width
        infoView.height = Self.infoViewHeight
        infoView.origin = layoutFrame.origin
      
        monthImageView.width = layoutFrame.width
        monthImageView.height = layoutFrame.height - infoView.height
        monthImageView.left = layoutFrame.minX
        monthImageView.top = infoView.bottom
    }
    
    func reloadData() {
        guard let periodItem = periodItem else {
            return
        }

        let habitTask = periodItem.habitTask
        infoView.icon = habitTask.icon
        infoView.title = habitTask.name
        
        let date = periodItem.period.date
        let firstWeekday = periodItem.period.firstWeekday
        let render = HabitReportMonthRender(date: date,
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
                  date == self.periodItem?.period.date else {
                return
            }
            
            self.monthImageView.image = image
            self.imageCacher?.setImage(image, identifier: taskID, date: date, size: imageSize)
        }
    }
}
