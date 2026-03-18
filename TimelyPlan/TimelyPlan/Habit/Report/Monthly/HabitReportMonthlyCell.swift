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
    var periodTask: HabitPeriodTask?
    
    /// 任务信息视图
    private(set) lazy var infoView: HabitReportIconInfoView = {
        let view = HabitReportIconInfoView()
        view.padding = UIEdgeInsets(horizontal: 5.0)
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
    
    /// 数据请求管理器
    private let requestManager = TPRequestManager()
    
    func reloadData() {
        guard let periodTask = periodTask else {
            return
        }

        let habitTask = periodTask.habitTask
        infoView.icon = habitTask.icon
        infoView.title = habitTask.name
    
        let requestID = requestManager.executeRequest()
        let render = HabitReportMonthRender(date: periodTask.period.date,
                                            firstWeekday: periodTask.period.firstWeekday,
                                            periodTask: periodTask)
        render.renderImage { image in
            guard self.requestManager.shouldProceed(with: requestID) else {
                return
            }
            
            self.monthImageView.image = image
        }
    }
}
