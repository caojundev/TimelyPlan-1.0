//
//  TPCalendarSpanningView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/12.
//

import Foundation
import UIKit

protocol TPCalendarSpanningViewDelegate: AnyObject {
    
    /// 当前月份日期
    func monthDateComponentsForCalendarSpanningView(_ view: TPCalendarSpanningView) -> DateComponents?
    
    /// 当前月份显示天日期组件数组
    func displayDaysForCalendarSpanningView(_ view: TPCalendarSpanningView) -> [DateComponents]?

    /// 跨天日期范围
    func spanDateRangesForCalendarSpanningView(_ view: TPCalendarSpanningView) -> [DateRange]?
}

class TPCalendarSpanningView: UIView {
    
    weak var delegate: TPCalendarSpanningViewDelegate?
    
    /// 当前月份日期
    private var monthDateComponents: DateComponents?
    
    /// 当前月份显示的日期组件数组
    private var displayDays: [DateComponents]?
    
    /// 跨越日期范围
    private var spanDateRanges: [DateRange]?
    
    /// 指示器图层
    private let indicatorLayer = CAShapeLayer()
    
    /// 指示器半径
    private let indicatorRadius: CGFloat = 25.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        indicatorLayer.backgroundColor = UIColor.clear.cgColor
        indicatorLayer.fillColor = UIColor.primary.withAlphaComponent(0.2).cgColor
        layer.addSublayer(indicatorLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadData() {
        monthDateComponents = delegate?.monthDateComponentsForCalendarSpanningView(self)
        displayDays = delegate?.displayDaysForCalendarSpanningView(self)
        spanDateRanges = delegate?.spanDateRangesForCalendarSpanningView(self)
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        indicatorLayer.frame = bounds
        CATransaction.commit()
        indicatorLayer.path = spanningBezierPath()?.cgPath
    }
    
    private func spanningBezierPath() -> UIBezierPath? {
        guard let spanDateRanges = spanDateRanges,
                let displayDays = displayDays,
                let monthDateComponents = monthDateComponents,
                let monthDate = Date.dateFromComponents(monthDateComponents) else {
                    return nil
        }
        
        let monthDateRange = monthDate.rangeOfThisMonth()
        let resultPath = UIBezierPath()
        for spanDateRange in spanDateRanges {
            if let spanDateRange = spanDateRange.intersection(with: monthDateRange),
               let bezierPath = bezierPath(spanDateRange: spanDateRange, displayDays: displayDays) {
                resultPath.append(bezierPath)
            }
        }
        
        return resultPath
    }
    
    private func bezierPath(spanDateRange: DateRange, displayDays: [DateComponents]) -> UIBezierPath? {
        guard let spanStartDate = spanDateRange.startDate,
              let spanEndDate = spanDateRange.endDate,
              let startIndex = displayDays.firstIndex(of: spanStartDate.yearMonthDayComponents),
                let endIndex = displayDays.firstIndex(of: spanEndDate.yearMonthDayComponents) else {
                    return nil
        }
        
        let weeksCount = Date.numberOfWeeksInMonth(of: displayDays.count)
        let itemWidth = floor(width / CGFloat(DAYS_PER_WEEK))
        let itemMarginX = (width - CGFloat(DAYS_PER_WEEK) * itemWidth) / CGFloat(DAYS_PER_WEEK - 1)
        let itemHeight = floor(height / CGFloat(weeksCount))
        let radius = min(min(itemWidth, itemHeight) / 2.0, indicatorRadius)
        let itemFrame = { (pos: (row: Int, col: Int)) -> CGRect in
            let x = (itemWidth + itemMarginX) * CGFloat(pos.col)
            let y = itemHeight * CGFloat(pos.row)
            let frame = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)
            return frame.insetBy(dx: (itemWidth - radius * 2.0) / 2.0, dy: (itemHeight - radius * 2.0) / 2.0)
        }

        let startPosition = position(of: startIndex)
        let endPosition = position(of: endIndex)
        let bezierPath = UIBezierPath()
        for row in startPosition.row...endPosition.row {
            let startItemFrame = row == startPosition.row ? itemFrame(startPosition) : itemFrame((row, 0))
            let endItemFrame = row == endPosition.row ? itemFrame(endPosition) : itemFrame((row, DAYS_PER_WEEK - 1))
            let rowWidth = endItemFrame.maxX - startItemFrame.minX
            guard rowWidth > 0 else {
                continue
            }
            
            let frame = CGRect(x: startItemFrame.minX, y: startItemFrame.minY, width: rowWidth, height: startItemFrame.height)
            bezierPath.append(UIBezierPath(roundedRect: frame, cornerRadius: radius))
        }
        
        return bezierPath
    }
    
    private func position(of index: Int) -> (row: Int, col: Int) {
        let row = index / DAYS_PER_WEEK
        let col = index % DAYS_PER_WEEK
        return (row, col)
    }
}
