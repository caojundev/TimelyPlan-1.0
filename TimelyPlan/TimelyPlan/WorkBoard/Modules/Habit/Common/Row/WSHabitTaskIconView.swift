//
//  WSHabitTaskIconView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/26.
//

import Foundation
import UIKit

// MARK: - 图标视图

/// 习惯任务图标视图。
///
/// 封装 `HabitTaskProgressInfoView` 中的图标、进度圆环与状态角标，
/// 三者以图标外接正方形为基准居中对齐，尺寸由外部决定。
class WSHabitTaskIconView: UIView {
    
    /// 任务图标
    let iconView: TPIconView = {
        let view = TPIconView()
        view.borderWidth = 0.0
        view.placeholderCharacter = "C"
        return view
    }()
    
    /// 进度圆环
    let progressView: TPCircleOutlineProgressView = {
        let view = TPCircleOutlineProgressView()
        view.backLineColor = Color(0x000000, 0.2)
        return view
    }()
    
    /// 任务状态角标
    let statusView = HabitTaskStatusView(frame: .zero)
    
    /// 图标边长
    var iconSide: CGFloat = 48.0 {
        didSet {
            guard iconSide != oldValue else {
                return
            }
            
            setNeedsLayout()
        }
    }
    
    /// 进度圆环线宽
    var progressLineWidth: CGFloat = 4.0 {
        didSet {
            guard progressLineWidth != oldValue else {
                return
            }
            
            progressView.progressLineWidth = progressLineWidth
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        progressView.progressLineWidth = progressLineWidth
        addSubview(iconView)
        addSubview(progressView)
        addSubview(statusView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let side = min(iconSide, min(bounds.width, bounds.height))
        iconView.size = CGSize(value: side)
        iconView.center = CGPoint(x: bounds.midX, y: bounds.midY)
        iconView.cornerRadius = side / 2.0
        
        progressView.frame = iconView.frame
        statusView.frame = iconView.frame
    }
    
    // MARK: - 渲染
    /// 更新图标、进度与状态。图标为空时隐藏进度与状态
    func update(icon: TPIcon?, color: UIColor?, progress: CGFloat, status: HabitTaskStatus) {
        iconView.icon = icon
        iconView.foreColor = icon == nil ? nil : Color(0xFFFFFF, 0.8)
        iconView.backColor = color
        
        progressView.progressLineColor = color?.lighterColor
        progressView.isHidden = (icon == nil)
        statusView.isHidden = (icon == nil)
        
        progressView.setProgress(progress, animated: false)
        statusView.setStatus(status)
    }
    
    /// 设置进度
    func setProgress(_ progress: CGFloat) {
        progressView.setProgress(progress, animated: false)
    }
    
    /// 设置状态
    func setStatus(_ status: HabitTaskStatus) {
        statusView.setStatus(status)
    }
}
