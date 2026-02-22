//
//  FocusTimelineAddIndicatorView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/22.
//

import Foundation
import UIKit

/// 时间线长按添加指示视图
class FocusTimelineAddIndicatorView: UIView {
    
    /// 指示器颜色
    private let indicatorColor = UIColor.systemBlue.withAlphaComponent(0.3)
    
    /// 边框颜色
    private let borderColor = UIColor.systemBlue
    
    /// 圆角半径
    private let cornerRadius: CGFloat = 4.0
    
    /// 边框宽度
    private let borderWidth: CGFloat = 1.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.backgroundColor = indicatorColor
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.alpha = 0.0
        
        // 添加淡入动画
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1.0
        }
    }
    
    /// 显示指示视图
    /// - Parameters:
    ///   - frame: 指示视图的位置和大小
    ///   - superview: 父视图
    ///   - duration: 显示持续时间（秒）
    static func showIndicator(in superview: UIView, 
                             frame: CGRect, 
                             duration: TimeInterval = 2.0) -> FocusTimelineAddIndicatorView {
        let indicator = FocusTimelineAddIndicatorView(frame: frame)
        superview.addSubview(indicator)
        
        // 自动移除
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            indicator.removeWithFadeOut()
        }
        
        return indicator
    }
    
    /// 带淡出效果的移除
    private func removeWithFadeOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.0
        }) { _ in
            self.removeFromSuperview()
        }
    }
}