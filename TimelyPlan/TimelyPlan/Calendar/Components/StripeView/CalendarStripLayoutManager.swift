//
//  CalendarStripLayoutManager.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/24.
//

import Foundation
import UIKit

class CalendarStripLayoutManager {
    
    /// 画布尺寸
    var canvasSize: CGSize = .zero {
        didSet {
            if canvasSize != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 每个事件条目的高度
    private var itemHeight: CGFloat = 16.0
    
    /// 内部间距
    private var padding: UIEdgeInsets = UIEdgeInsets(value: 2.0)
    
    /// 最小行间距，用于控制事件之间的最小垂直距离
    private var minimumLineSpacing: CGFloat = 2.0
    
    /// 最大行间距
    private var maximumLineSpacing: CGFloat = 2.0
    
    /// 实际使用的行间距
    private(set) var lineSpacing: CGFloat = 5.0
    
    /// 布局中使用的总行数
    private(set) var linesCount: Int = 1
    
    /// 条目宽度
    private var itemWidth: CGFloat = 0.0
    
    /// 是否需要重新布局
    private var needsLayout: Bool = true
    
    /// 横跨总天数
    private let days: Int
    
    init(days: Int = DAYS_PER_WEEK) {
        self.days = days
    }
    
    func setNeedsLayout() {
        needsLayout = true
    }
    
    func layoutIfNeeded() {
        if needsLayout {
            layout()
            needsLayout = false
        }
    }
    
    /// 计算布局
    private func layout() {
        guard canvasSize != .zero else {
            return
        }
        
        let availableHeight = canvasSize.height - padding.verticalLength
        let rowHeight = itemHeight + minimumLineSpacing
        let maxLines = Int(availableHeight / rowHeight)
        if maxLines > 0 {
            let remainingHeight = availableHeight - (CGFloat(maxLines) * itemHeight)
            lineSpacing = remainingHeight / CGFloat(maxLines - 1)
            lineSpacing = min(max(lineSpacing, minimumLineSpacing), maximumLineSpacing)
            linesCount = maxLines
        } else {
            // 如果无法容纳任何行，则设置为默认值
            lineSpacing = minimumLineSpacing
            linesCount = 1
        }
        
        itemWidth = canvasSize.width / CGFloat(days)
    }
    
    /// 更多文本区域
    func moreTextFrame(for colum: Int) -> CGRect {
        let y = topOfRow(linesCount - 1)
        let x = leftOfColumn(colum)
        let w = itemWidth - padding.horizontalLength
        return CGRect(x: x, y: y, width: w, height: itemHeight)
    }
    
    func eventFrame(for path: CalendarEventPath) -> CGRect {
        let y = topOfRow(path.row)
        let x = leftOfColumn(path.position.column)
        let w = CGFloat(path.position.length + 1) * itemWidth - padding.horizontalLength
        return CGRect(x: x, y: y, width: w, height: itemHeight)
    }
    
    private func topOfRow(_ row: Int) -> CGFloat {
        return padding.top + CGFloat(row) * (itemHeight + lineSpacing)
    }
    
    private func leftOfColumn(_ column: Int) -> CGFloat {
        return padding.left + CGFloat(column) * itemWidth
    }
    
    /// 获取行数对应的高度
    func heightThatFits(_ linesCount: Int) -> CGFloat {
        return CGFloat(linesCount) * (itemHeight + minimumLineSpacing) + padding.verticalLength
    }
}
