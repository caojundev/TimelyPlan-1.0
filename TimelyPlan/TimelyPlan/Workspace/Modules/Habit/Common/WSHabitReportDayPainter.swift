//
//  WSHabitReportDayPainter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation
import UIKit

// MARK: - 报告色块绘制

/// 习惯报告色块绘制。
///
/// 月报告与周报告共用同一套规则，与习惯报告页保持一致：
/// 进度日按完成比例叠加任务颜色，非计划日、跳过、失败绘制报告图标。
enum WSHabitReportDayPainter {
    
    /// 色块圆角
    private static let cornerRadius: CGFloat = 6.0
    
    /// 进度色块透明度的上下限
    private static let minProgressAlpha: CGFloat = 0.2
    private static let maxProgressAlpha: CGFloat = 1.0
    
    /// 报告图标，与习惯报告页共用
    private static let notScheduledImage = resGetImage("habit_report_notScheduled_20")
    private static let skippedImage = resGetImage("habit_report_skipped_20")
    private static let failedImage = resGetImage("habit_report_failed_20")
    
    /// 绘制一天
    static func draw(_ dayItem: WSHabitDayDataItem, in rect: CGRect) {
        guard dayItem.isScheduled else {
            notScheduledImage?.draw(in: rect)
            return
        }
        
        switch dayItem.status {
        case .notStarted, .inProgress, .completed:
            drawProgressDay(dayItem, in: rect)
        case .skipped(_):
            skippedImage?.withTintColor(dayItem.color).draw(in: rect)
        case .failed(_):
            failedImage?.draw(in: rect)
        }
    }
    
    /// 进度日：无进度时使用占位底色，有进度时按完成比例叠加任务颜色
    private static func drawProgressDay(_ dayItem: WSHabitDayDataItem, in rect: CGRect) {
        let color: UIColor
        if dayItem.progress <= 0.0 {
            color = .secondarySystemFill
        } else {
            let alpha = min(max(dayItem.progress, minProgressAlpha), maxProgressAlpha)
            color = dayItem.color.withAlphaComponent(alpha)
        }
        
        let path = UIBezierPath(roundedRect: rect,
                                cornerRadius: min(cornerRadius, rect.width / 2.0))
        color.setFill()
        path.fill()
    }
}
