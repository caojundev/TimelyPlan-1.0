//
//  TimelineNodeView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/21.
//

import Foundation
import UIKit

// MARK: - 时间线节点容器组件

/// 时间线节点视图组件（可复用的节点容器）
class TimelineNodeView: UIView {
    
    // MARK: 子视图
    let iconImageView = UIImageView()
    
    // MARK: 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupView() {
        iconImageView.contentMode = .center
        addSubview(iconImageView)
    }
    
    // MARK: 配置方法
    
    /// 应用节点样式（圆角配置）
    func applyNodeStyle(_ style: TimeLineNodeStyle) {
        layer.maskedCorners = []
        
        switch style {
        case .independent:
            layer.cornerRadius = TimelineConfig.centerNodeWidth / 2
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                   .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .connectToPrevious:
            layer.cornerRadius = TimelineConfig.centerNodeWidth / 2
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .connectToNext:
            layer.cornerRadius = TimelineConfig.centerNodeWidth / 2
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .connectToBoth:
            layer.cornerRadius = 0
        }
    }
    
    /// 配置图标
    func configureIcon(_ icon: UIImage?) {
        iconImageView.image = icon
    }
    
    /// 配置背景颜色
    func configureBackgroundColor(_ color: UIColor) {
        backgroundColor = color
    }
    
    // MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        iconImageView.frame = CGRect(
            x: 0,
            y: (bounds.height - TimelineConfig.iconSize) / 2,
            width: TimelineConfig.centerNodeWidth,
            height: TimelineConfig.iconSize
        )
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: TimelineConfig.centerNodeWidth, height: size.height)
    }
}
