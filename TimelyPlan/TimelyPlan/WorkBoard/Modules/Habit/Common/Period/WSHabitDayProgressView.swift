//
//  WSHabitDayProgressView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation
import UIKit

// MARK: - 天进度视图

/// 单天进度视图。
///
/// 顶部为星期文案，下方为进度圆环；跳过 / 失败在圆环中心绘制原因 emoji，
/// 已完成填充圆环并绘制对勾，非计划日绘制占位图，今天在底部绘制指示小圆点。
/// 全部内容在 `draw(_:)` 中绘制，不叠加子视图。
class WSHabitDayProgressView: UIView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 星期文案高度
        static let weekdayHeight: CGFloat = 30.0
        
        /// 星期文案字号
        static let weekdayFont = UIFont.boldSystemFont(ofSize: 12.0)
        
        /// 进度圆环最大边长
        static let maxCircleSide: CGFloat = 42.0
        
        /// 圆环线宽占圆环边长的比例
        static let lineWidthRatio: CGFloat = 0.095
        
        /// 日期数字字号占圆环边长的比例
        static let dayNumberFontRatio: CGFloat = 0.36
        
        static let dayNumberColor = Color(light: 0x000000, dark: 0xffffff, alpha: 0.8)
        
        /// 原因 emoji 字号占圆环边长的比例
        static let emojiFontRatio: CGFloat = 0.46
        
        /// 对勾图标边长占圆环边长的比例
        static let checkmarkRatio: CGFloat = 0.62
        
        /// 今日指示圆点直径
        static let todayDotSize: CGFloat = 6.0
        
        /// 今日指示圆点距底部的距离
        static let todayDotBottomMargin: CGFloat = 3.0
    }
    
    /// 对勾图标
    private static let checkmarkImage = resGetImage("habit_week_day_checkmark_40", color: .white)
    
    /// 非计划日占位图
    private static let notScheduledImage = resGetImage("habit_week_day_notscheduled_42")
    
    /// 圆环背景色
    private static let circleBackColor = Color(light: 0x000000, dark: 0xAAAAAA, alpha: 0.1)
    
    /// 圆环轨道颜色
    private static let ringTrackColor = Color(light: 0x000000, dark: 0xAAAAAA, alpha: 0.16)
    
    /// 展示数据
    var dayItem: WSHabitDayDataItem? {
        didSet {
            isHidden = (dayItem == nil)
            alpha = (dayItem?.isFuture ?? false) ? 0.6 : 1.0
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        isOpaque = false
        contentMode = .redraw
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 绘制
    override func draw(_ rect: CGRect) {
        guard let dayItem = dayItem, let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        drawWeekday(dayItem)
        drawCircle(with: dayItem, in: context)
        drawTodayIndicator(with: dayItem, in: context)
    }
    
    /// 顶部星期文案
    private func drawWeekday(_ dayItem: WSHabitDayDataItem) {
        let rect = CGRect(x: 0.0,
                          y: 0.0,
                          width: bounds.width,
                          height: Metrics.weekdayHeight)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Metrics.weekdayFont,
            .foregroundColor: UIColor.secondaryLabel
        ]
        drawText(dayItem.weekdayText, in: rect, attributes: attributes)
    }
    
    /// 今日指示圆点
    private func drawTodayIndicator(with dayItem: WSHabitDayDataItem, in context: CGContext) {
        guard dayItem.date.isToday else {
            return
        }
        
        let size = Metrics.todayDotSize
        let rect = CGRect(x: (bounds.width - size) / 2.0,
                          y: bounds.height - Metrics.todayDotBottomMargin - size,
                          width: size,
                          height: size)
        
        context.saveGState()
        context.setFillColor(dayItem.color.cgColor)
        context.fillEllipse(in: rect)
        context.restoreGState()
    }
    
    /// 中间进度圆环
    private func drawCircle(with dayItem: WSHabitDayDataItem, in context: CGContext) {
        let side = min(Metrics.maxCircleSide, max(bounds.width - 4.0, 0.0))
        guard side > 0.0 else {
            return
        }
        
        let circleRect = CGRect(x: (bounds.width - side) / 2.0,
                                y: Metrics.weekdayHeight,
                                width: side,
                                height: side)
        
        /// 非计划日：绘制占位图
        guard dayItem.isScheduled else {
            WSHabitDayProgressView.notScheduledImage?.draw(in: circleRect,
                                                           blendMode: .normal,
                                                           alpha: 0.6)
            return
        }
        
        switch dayItem.status {
        case .completed:
            fillCircle(in: circleRect, color: dayItem.color, context: context)
            drawCheckmark(in: circleRect)
            
        case .skipped, .failed:
            fillCircle(in: circleRect, color: WSHabitDayProgressView.circleBackColor, context: context)
            drawReasonEmoji(in: circleRect, emoji: dayItem.reasonEmoji)
            
        case .inProgress:
            fillCircle(in: circleRect, color: WSHabitDayProgressView.circleBackColor, context: context)
            drawProgress(with: dayItem, in: circleRect, context: context)
            drawDayNumber(with: dayItem, in: circleRect)
            
        case .notStarted:
            fillCircle(in: circleRect, color: WSHabitDayProgressView.circleBackColor, context: context)
            /// 进度为 0 时也画出圆环，只显示底色轨道
            drawProgress(with: dayItem, in: circleRect, context: context)
            drawDayNumber(with: dayItem, in: circleRect)
        }
    }
    
    /// 填充圆环底色
    private func fillCircle(in rect: CGRect, color: UIColor, context: CGContext) {
        context.saveGState()
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: rect)
        context.restoreGState()
    }
    
    /// 绘制进度弧线
    private func drawProgress(with dayItem: WSHabitDayDataItem, in rect: CGRect, context: CGContext) {
        let lineWidth = max(rect.width * Metrics.lineWidthRatio, 2.0)
        let radius = (rect.width - lineWidth) / 2.0
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        context.saveGState()
        context.setLineWidth(lineWidth)
        context.setLineCap(.round)
        
        /// 轨道
        context.setStrokeColor(WSHabitDayProgressView.ringTrackColor.cgColor)
        context.addArc(center: center,
                       radius: radius,
                       startAngle: 0.0,
                       endAngle: 2.0 * CGFloat.pi,
                       clockwise: true)
        context.strokePath()
        
        /// 进度
        if dayItem.progress > 0.0 {
            let startAngle = -CGFloat.pi / 2.0
            let endAngle = startAngle + 2.0 * CGFloat.pi * min(dayItem.progress, 1.0)
            context.setStrokeColor(dayItem.color.cgColor)
            context.addArc(center: center,
                           radius: radius,
                           startAngle: startAngle,
                           endAngle: endAngle,
                           clockwise: false)
            context.strokePath()
        }
        
        context.restoreGState()
    }
    
    /// 日期数字
    private func drawDayNumber(with dayItem: WSHabitDayDataItem, in rect: CGRect) {
        let font = UIFont.boldSystemFont(ofSize: floor(rect.width * Metrics.dayNumberFontRatio))
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: Metrics.dayNumberColor
        ]
        
        drawText(dayItem.dayNumberText, in: rect, attributes: attributes)
    }
    
    /// 已完成对勾
    private func drawCheckmark(in rect: CGRect) {
        let side = rect.width * Metrics.checkmarkRatio
        let checkmarkRect = CGRect(x: rect.midX - side / 2.0,
                                   y: rect.midY - side / 2.0,
                                   width: side,
                                   height: side)
        WSHabitDayProgressView.checkmarkImage?.draw(in: checkmarkRect)
    }
    
    /// 跳过 / 失败原因 emoji
    private func drawReasonEmoji(in rect: CGRect, emoji: String?) {
        guard let emoji = emoji else {
            return
        }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: floor(rect.width * Metrics.emojiFontRatio))
        ]
        drawText(emoji, in: rect, attributes: attributes)
    }
    
    /// 在矩形内水平、垂直居中绘制文本
    private func drawText(_ text: String, in rect: CGRect, attributes: [NSAttributedString.Key: Any]) {
        let string = text as NSString
        let size = string.size(withAttributes: attributes)
        let origin = CGPoint(x: rect.midX - size.width / 2.0,
                             y: rect.midY - size.height / 2.0)
        string.draw(at: origin, withAttributes: attributes)
    }
}
