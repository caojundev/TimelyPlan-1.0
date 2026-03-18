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
    private(set) lazy var chartView: HabitReportYearChartView = {
        let view = HabitReportYearChartView(frame: bounds)
        return view
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(infoView)
        contentView.addSubview(chartView)
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = contentView.layoutFrame()
        infoView.width = layoutFrame.width
        infoView.height = Self.infoViewHeight
        infoView.origin = layoutFrame.origin
      
        let chartViewMargin = 5.0
        chartView.width = layoutFrame.width - 2 * chartViewMargin
        chartView.height = layoutFrame.height - infoView.height
        chartView.left = layoutFrame.minX + chartViewMargin
        chartView.top = infoView.bottom
    }

    func reloadData() {
        guard let periodTask = periodTask else {
            return
        }

        let habitTask = periodTask.habitTask
        infoView.icon = habitTask.icon
        infoView.title = habitTask.name
    
        chartView.periodTask = periodTask
        chartView.reloadData()
    }
}
