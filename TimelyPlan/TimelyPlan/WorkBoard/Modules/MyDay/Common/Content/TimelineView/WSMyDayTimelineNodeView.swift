//
//  WSMyDayTimelineNodeView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

// MARK: - 事项节点视图

/// 插件时间线的事项节点：在 `TimelineNodeView` 的节点上叠加图标或表情
class WSMyDayTimelineNodeView: TimelineNodeView {
    
    /// 图标尺寸
    private let iconSize = CGSize(width: 20.0, height: 20.0)
    
    /// 图标
    private let iconView = TPIconView()
    
    override func setupView() {
        super.setupView()
        
        iconView.borderWidth = 0.0
        iconView.foreColor = .white
        iconView.font = .systemFont(ofSize: 11.0)
        addSubview(iconView)
    }
    
    /// 节点底色固定使用深色，浅色模式下同样如此
    override func nodeBackgroundColor(for item: TimelineItem) -> UIColor {
        return WSMyDayTimelineLayoutManager.trackColor
    }
    
    /// 配置图标或表情
    func configureIcon(_ icon: TPIcon?) {
        iconView.icon = icon
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        iconView.size = iconSize
        iconView.center = CGPoint(x: contentView.frame.midX, y: contentView.frame.midY)
    }
}
