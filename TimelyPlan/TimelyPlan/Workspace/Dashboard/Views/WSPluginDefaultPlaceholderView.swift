//
//  WSPluginLoadingPlaceholderView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/18.
//

import Foundation
import UIKit

// MARK: - 默认加载占位视图

/// 工作台组件默认加载占位视图。
///
/// 三行宽度不等、带圆角的灰色横条，整体靠左上角对齐，用于数据加载完成前的占位展示。
class WSPluginLoadingPlaceholderView: UIView {
    
    /// 横条高度
    private let barHeight: CGFloat = 12.0
    
    /// 横条间距
    private let barSpacing: CGFloat = 8.0
    
    /// 横条圆角半径
    private let barCornerRadius: CGFloat = 6.0
    
    /// 横条距视图边缘的内边距
    private let contentInsets = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
    
    /// 三行横条的宽度占比（占可用宽度）
    private let barWidthRatios: [CGFloat] = [0.6, 0.9, 0.4]
    
    /// 横条
    private lazy var barViews: [UIView] = {
        return barWidthRatios.map { _ in
            let barView = UIView()
            barView.backgroundColor = .systemGray5
            barView.layer.masksToBounds = true
            return barView
        }
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = false
        barViews.forEach { addSubview($0) }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        /// 可用宽度
        let availableWidth = max(bounds.width - contentInsets.left - contentInsets.right, 0.0)
        
        /// 横条高度，受可用高度限制，避免小尺寸组件中横条溢出
        let availableHeight = bounds.height - contentInsets.top - contentInsets.bottom
        let spacingHeight = barSpacing * CGFloat(max(barViews.count - 1, 0))
        let barHeight = min(self.barHeight,
                            max((availableHeight - spacingHeight) / CGFloat(max(barViews.count, 1)), 0.0))
        
        /// 圆角半径不超过横条高度的一半
        let cornerRadius = min(barCornerRadius, barHeight / 2.0)
        
        var originY = contentInsets.top
        for (index, barView) in barViews.enumerated() {
            let width = availableWidth * barWidthRatios[index]
            barView.frame = CGRect(x: contentInsets.left, y: originY, width: width, height: barHeight)
            barView.layer.cornerRadius = cornerRadius
            originY = barView.frame.maxY + barSpacing
        }
    }
}
