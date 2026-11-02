//
//  WSMyDayBriefAllDayEventRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

// MARK: - 简略行视图

/// 全天事项简略行视图，供小尺寸组件使用。
///
/// 是 `TimelineEventCell` 的简略版：左侧为与时间线节点同色的圆点，
/// 右侧为事项名称，不再展示图标、时间与详情。尺寸由外部决定。
class WSMyDayBriefAllDayEventRowView: WSMyDayAllDayEventRowBaseView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与行边缘的间距
        static let contentInsets = UIEdgeInsets(left: 2.0, right: 2.0)
        
        /// 颜色圆点边长
        static let colorDotSize: CGFloat = 8.0
        
        /// 名称字体
        static let titleFont = UIFont.systemFont(ofSize: 13.0, weight: .semibold)
    }
    
    /// 颜色圆点
    private let colorDotView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.padding = Metrics.contentInsets
        self.titleLabel.font = Metrics.titleFont
        
        colorDotView.clipsToBounds = true
        addSubview(colorDotView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutAccessory(in contentFrame: CGRect) -> CGFloat {
        /// 圆点靠左垂直居中，行高不足时随行高缩小
        let dotSize = min(Metrics.colorDotSize, contentFrame.height)
        colorDotView.size = CGSize(width: dotSize, height: dotSize)
        colorDotView.left = contentFrame.minX
        colorDotView.centerY = contentFrame.midY
        colorDotView.layer.cornerRadius = dotSize / 2.0
        
        return colorDotView.right
    }
    
    // MARK: - 渲染
    override func reloadAccessory() {
        colorDotView.backgroundColor = dataItem?.color ?? .clear
    }
}
