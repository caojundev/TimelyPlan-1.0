//
//  WSGoalPlanDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/28.
//

import Foundation
import UIKit

// MARK: - 数据条目

/// 目标计划组件中的单个目标计划数据。
///
/// 展示字段与目标计划列表一致：颜色、名称、状态、日期区间与进度。
/// 只持有计划标识，交互时再据此读取最新的计划，避免持有过期快照。
class WSGoalPlanDataItem: NSObject, WSPluginDataItem {
    
    /// 目标计划唯一标识
    let planIdentifier: String
    
    /// 目标计划名称
    let title: String
    
    /// 目标计划颜色
    let color: UIColor
    
    /// 计划进度（0.0 ~ 1.0）
    let progress: CGFloat
    
    /// 进度百分比文案
    let progressText: String
    
    /// 日期范围
    let dateRange: DateRange
    
    /// 计划状态
    let status: GoalPlanStatus
    
    /// 进度总结状态（进行中时的细分状态）
    let summaryStatus: GoalSummaryStatus
    
    init(planIdentifier: String,
         title: String,
         color: UIColor,
         progress: CGFloat,
         progressText: String,
         dateRange: DateRange,
         status: GoalPlanStatus,
         summaryStatus: GoalSummaryStatus) {
        self.planIdentifier = planIdentifier
        self.title = title
        self.color = color
        self.progress = progress
        self.progressText = progressText
        self.dateRange = dateRange
        self.status = status
        self.summaryStatus = summaryStatus
        super.init()
    }
    
    /// 由目标计划生成展示数据
    convenience init(goalPlan: GoalPlan) {
        self.init(planIdentifier: goalPlan.identifier,
                  title: goalPlan.displayName,
                  color: goalPlan.color ?? GoalConfig.goalPlanDefaultColor,
                  progress: CGFloat(goalPlan.progress),
                  progressText: Float(goalPlan.progress).percentageString(decimalPlaces: 0),
                  dateRange: DateRange(startDate: goalPlan.startDate, endDate: goalPlan.endDate),
                  status: goalPlan.status,
                  summaryStatus: goalPlan.summaryStatus)
    }
    
    /// 日期区间文案
    var intervalText: String? {
        return GoalDateHelper.intervalDescription(startDate: dateRange.startDate,
                                                  endDate: dateRange.endDate)
    }
    
    /// 状态文案。进行中时取进度总结状态，比「进行中」更有信息量
    var statusText: String {
        return status == .inProgress ? summaryStatus.title : status.title
    }
    
    /// 状态背景色
    var statusColor: UIColor {
        return status == .inProgress ? summaryStatus.backgroundColor : status.backgroundColor
    }
}
