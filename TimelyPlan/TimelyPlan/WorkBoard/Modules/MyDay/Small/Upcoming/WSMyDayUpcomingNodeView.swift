//
//  WSMyDayUpcomingNodeView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

// MARK: - 事项节点视图

/// 临近事项的节点视图，参照 `TimelineNodeView` 的节点绘制方式。
///
/// 竖向胶囊以时间线今日节点的暗色为底色，中间展示事项来源图标；
/// 事件颜色按当前时间进度自顶部覆盖，进度末端渐隐过渡到暗色底色。
class WSMyDayUpcomingNodeView: UIView {
    
    /// 建议尺寸
    static let preferredSize = CGSize(width: 36.0, height: 44.0)
    
    /// 渐隐过渡区的高度
    var transitionHeight: CGFloat = 10.0
    
    /// 图标尺寸
    var iconSize = CGSize(value: 22.0)
    
    private let gradientLayer = CAGradientLayer()
    
    private let iconView = TPIconView()
    
    /// 事项颜色
    private var color: UIColor = .clear
    
    /// 当前时间在事项中的进度，取值 0~1
    private var progress: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        /// 底色与时间线今日节点一致
        backgroundColor = TimelineConfig.todayNodeBackgroundColor
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.isHidden = true
        layer.addSublayer(gradientLayer)
        
        iconView.borderWidth = 0.0
        iconView.foreColor = .white
        iconView.font = .systemFont(ofSize: 12.0)
        addSubview(iconView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 渲染
    /// 更新节点颜色、进度与来源图标
    func update(color: UIColor, progress: CGFloat, icon: TPIcon?) {
        self.color = color
        self.progress = min(max(progress, 0.0), 1.0)
        iconView.icon = icon
        setNeedsLayout()
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.width / 2.0
        
        /// 图标居中展示
        iconView.size = iconSize
        iconView.center = CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0)
        
        layoutGradientLayer()
    }
    
    private func layoutGradientLayer() {
        guard bounds.width > 0.0, bounds.height > 0.0 else {
            return
        }
        
        /// 未开始：只展示暗色节点与图标
        guard progress > 0.0 else {
            gradientLayer.isHidden = true
            return
        }
        
        gradientLayer.isHidden = false
        
        let fromColor = color
        let toColor = progress >= 1.0 ? fromColor : fromColor.withAlphaComponent(0.0)
        
        /// 按进度填充，末端保留过渡区渐隐
        let progressHeight = max(progress * bounds.height, transitionHeight)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = CGRect(x: 0.0,
                                     y: progressHeight - bounds.height,
                                     width: bounds.width,
                                     height: bounds.height)
        
        let transitionRatio = gradientLayer.frame.height > transitionHeight
            ? transitionHeight / gradientLayer.frame.height
            : 1.0
        
        gradientLayer.colors = [fromColor.cgColor, fromColor.cgColor, toColor.cgColor]
        gradientLayer.locations = [0.0, NSNumber(value: 1.0 - transitionRatio), 1.0]
        CATransaction.commit()
    }
}
