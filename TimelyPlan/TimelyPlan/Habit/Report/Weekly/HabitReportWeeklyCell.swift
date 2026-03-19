//
//  HabitReportWeeklyCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/17.
//

import Foundation
import UIKit

class HabitReportWeeklyCell: TPCollectionCell, TPCalendarSingleWeekViewDelegate {
    
    static let weekMargins = UIEdgeInsets(left: 120.0, right: 0.0)
    
    /// 任务
    var periodTask: HabitPeriodTask?
    
    var imageCacher: HabitReportImageCacher?
    
    /// 任务信息视图
    private(set) lazy var infoView: HabitReportIconInfoView = {
        let view = HabitReportIconInfoView()
        view.padding = UIEdgeInsets(left: 5.0)
        return view
    }()

    /// 周视图
    private let weekImageView = UIImageView()
    
    /// 数据请求管理器
    private let requestManager = TPRequestManager()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(infoView)
        weekImageView.contentMode = .scaleAspectFit
        contentView.addSubview(weekImageView)
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = contentView.bounds
        
        let weekLayoutFrame = layoutFrame.inset(by: Self.weekMargins)
        infoView.width = weekLayoutFrame.minX
        infoView.height = layoutFrame.height
        infoView.origin = layoutFrame.origin
        
        weekImageView.width = weekLayoutFrame.width
        weekImageView.height = weekLayoutFrame.height
        weekImageView.top = weekLayoutFrame.minY
        weekImageView.left = weekLayoutFrame.minX
        
        reloadWeekImageIfNeeded()
    }
    
    func reloadData() {
        self.weekImageView.image = nil
        self.layoutIfNeeded()
        guard let periodTask = periodTask else {
            return
        }

        let habitTask = periodTask.habitTask
        infoView.icon = habitTask.icon
        infoView.title = habitTask.name
        reloadWeekImage()
    }
    
    private func reloadWeekImageIfNeeded() {
        if weekImageView.size != weekImageView.image?.size {
            reloadWeekImage()
        }
    }
    
    /// 加载周视图
    private func reloadWeekImage() {
        guard let periodTask = periodTask else {
            return
        }
        
        let date = periodTask.period.date
        let firstWeekday = periodTask.period.firstWeekday
        let render = HabitReportWeekRender(date: date,
                                           firstWeekday: firstWeekday,
                                           periodTask: periodTask)
        render.contentSize = self.weekImageView.size
        
        let taskID = periodTask.habitTask.identifier
        let imageSize = render.canvasSize()
        let image = imageCacher?.getImage(identifier: taskID, date: date, size: imageSize)
        if image != nil {
            self.weekImageView.image = image
            return
        }

        self.weekImageView.image = nil

        let requestID = requestManager.executeRequest()
        render.renderImage { image in
            guard self.requestManager.shouldProceed(with: requestID) else {
                return
            }
            
            self.weekImageView.image = image
            self.imageCacher?.setImage(image, identifier: taskID, date: date, size: imageSize)
        }
    }
}
