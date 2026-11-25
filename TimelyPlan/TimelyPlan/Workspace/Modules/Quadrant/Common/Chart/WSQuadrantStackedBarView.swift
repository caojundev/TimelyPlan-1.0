//
//  WSQuadrantStackedBarView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/30.
//

import Foundation
import UIKit

// MARK: - 堆叠比例条

/// 四象限堆叠比例条。
///
/// 按各段计数占比横向堆叠绘制，整条为胶囊形；全部为 0 时显示一条浅灰色比例条。
class WSQuadrantStackedBarView: UIView {
    
    /// 比例条上的一段
    struct Segment {
        
        /// 段颜色
        let color: UIColor
        
        /// 段的计数
        let count: Int
    }
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 全部为 0 时的比例条颜色
        static let emptyBarColor = Color(0x8E8E93, 0.25)
    }
    
    /// 各段数据，按象限顺序排列
    var segments: [Segment] = [] {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 段视图，最多四段，复用避免每次刷新重建
    private var segmentViews: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = Metrics.emptyBarColor
        self.clipsToBounds = true
        
        for _ in 0..<Quadrant.allCases.count {
            let segmentView = UIView()
            segmentView.isHidden = true
            segmentViews.append(segmentView)
            addSubview(segmentView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        /// 胶囊形，两端的圆角由整条比例条裁剪得到
        self.layer.cornerRadius = bounds.height / 2.0
        
        for segmentView in segmentViews {
            segmentView.isHidden = true
        }
        
        guard bounds.width > 0.0, bounds.height > 0.0 else {
            return
        }
        
        let total = segments.reduce(0) { $0 + $1.count }
        guard total > 0 else {
            return
        }
        
        let visibleSegments = segments.filter { $0.count > 0 }
        var left: CGFloat = 0.0
        for (index, segment) in visibleSegments.enumerated() {
            let segmentView = segmentViews[index]
            /// 最后一段补齐剩余宽度，避免取整误差在末端留下缝隙
            let width = index == visibleSegments.count - 1
                ? max(bounds.width - left, 0.0)
                : bounds.width * CGFloat(segment.count) / CGFloat(total)
            
            segmentView.backgroundColor = segment.color
            segmentView.frame = CGRect(x: left, y: 0.0, width: width, height: bounds.height)
            segmentView.isHidden = false
            
            left += width
        }
    }
}
