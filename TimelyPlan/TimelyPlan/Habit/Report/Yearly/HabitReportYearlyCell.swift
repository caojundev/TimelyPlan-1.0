//
//  HabitReportYearlyCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/18.
//

import Foundation
import UIKit

class HabitReportYearlyCell: TPCollectionCell {
    
    /// 任务
    var periodTask: HabitPeriodTask?
    
    static let infoViewHeight: CGFloat = 30.0
    
    /// 任务信息视图
    private(set) lazy var infoView: HabitReportIconInfoView = {
        let view = HabitReportIconInfoView()
        view.padding = UIEdgeInsets(horizontal: 5.0)
        view.titleView.titleConfig.numberOfLines = 1
        view.titleView.titleConfig.font = .boldSystemFont(ofSize: 12.0)
        return view
    }()

    /// 月视图
    private lazy var yearView: HabitReportYearChartView = {
        let view = HabitReportYearChartView(frame: bounds)
        return view
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(infoView)
        contentView.addSubview(yearView)
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = contentView.layoutFrame()
        infoView.width = layoutFrame.width
        infoView.height = Self.infoViewHeight
        infoView.origin = layoutFrame.origin
      
        let yearViewMargin = 5.0
        yearView.width = layoutFrame.width - 2 * yearViewMargin
        yearView.height = layoutFrame.height - infoView.height
        yearView.left = layoutFrame.minX + yearViewMargin
        yearView.top = infoView.bottom
    }

    func reloadData() {
        guard let periodTask = periodTask else {
            return
        }

        let habitTask = periodTask.habitTask
        infoView.icon = habitTask.icon
        infoView.title = habitTask.name
    
        yearView.periodTask = periodTask
        yearView.reloadData()
    }
}
