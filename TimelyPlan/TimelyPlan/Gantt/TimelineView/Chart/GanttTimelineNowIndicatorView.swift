//
//  GanttTimelineNowIndicatorView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/29.
//

import Foundation
import UIKit

/// 今天当前时间指示器视图
///
/// 该视图是一个横向滚动的 UIScrollView，其 contentSize 宽度与 chartView 的内容宽度保持一致
/// （均由 timeScale 计算得出），内部绘制一条纵向细线表示「今天当前时间」所在的位置。
/// 不响应任何手势，仅通过参与横向滚动同步跟随 chartView 水平滚动。
final class GanttTimelineNowIndicatorView: UIScrollView {

    // MARK: - 常量

    /// 指示线宽度
    private static let lineWidth: CGFloat = 1.5

    /// 指示线颜色
    private static let lineColor = UIColor.systemRed

    // MARK: - 公开属性

    /// 当前时间尺度（用于计算内容宽度与指示线 X 位置）
    var timeScale: GanttTimeScale = GanttTimeScale(scale: .day, date: Date()) {
        didSet {
            updateContentSize()
        }
    }

    // MARK: - 私有属性

    /// 纵向指示线
    private let indicatorLine = UIView()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()
        setupIndicatorLine()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 视图设置

    private func setupScrollView() {
        backgroundColor = .clear
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        bounces = false
        alwaysBounceHorizontal = false
        alwaysBounceVertical = false
        contentInsetAdjustmentBehavior = .never
        // 不响应任何手势与交互，仅跟随 chartView 横向滚动
        isScrollEnabled = false
        isUserInteractionEnabled = false
        // 指示线需要完整覆盖内容高度，因此纵向不裁剪
        clipsToBounds = false
    }

    private func setupIndicatorLine() {
        indicatorLine.backgroundColor = Self.lineColor
        indicatorLine.isUserInteractionEnabled = false
        addSubview(indicatorLine)
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()

        // 指示线宽度固定，纵向占满自身高度
        let lineX = GanttTimelineGeometry.xPositionForDate(Date(), timeScale: timeScale) - Self.lineWidth / 2
        indicatorLine.frame = CGRect(
            x: lineX,
            y: 0,
            width: Self.lineWidth,
            height: bounds.height
        )
    }

    // MARK: - 私有方法

    /// 更新内容尺寸与指示线位置
    private func updateContentSize() {
        contentSize = CGSize(width: GanttTimelineGeometry.contentWidth(timeScale: timeScale),
                             height: bounds.height)
        updateIndicatorPosition()
    }

    /// 重新计算并更新指示线位置
    private func updateIndicatorPosition() {
        let now = Date()
        let x = GanttTimelineGeometry.xPositionForDate(now, timeScale: timeScale)

        // 若当前时间超出时间尺度范围，隐藏指示线
        let inRange = now >= timeScale.startDate && now <= timeScale.endDate
        indicatorLine.isHidden = !inRange

        indicatorLine.frame = CGRect(
            x: x - Self.lineWidth / 2,
            y: 0,
            width: Self.lineWidth,
            height: bounds.height
        )
    }
}
