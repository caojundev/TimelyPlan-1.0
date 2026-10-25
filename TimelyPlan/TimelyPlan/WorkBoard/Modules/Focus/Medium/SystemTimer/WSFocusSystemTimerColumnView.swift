//
//  WSFocusSystemTimerColumnView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/24.
//

import Foundation
import UIKit

// MARK: - 列视图

/// 系统计时器列视图。
///
/// 展示单个默认计时器：上方图标，中间名称与描述，底部开始专注按钮。
/// 列本身不响应点击，仅按钮响应；尺寸由外部决定。
class WSFocusSystemTimerColumnView: WSColumnIconInfoView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 开始按钮尺寸
        static let startButtonSize = CGSize(width: 36.0, height: 36.0)
        
        /// 按钮命中区域外扩
        static let startButtonHitMargin: CGFloat = 8.0
    }
    
    /// 点击开始按钮回调
    var didClickStartHandler: (() -> Void)?
    
    /// 开始专注按钮
    private lazy var startButton: TPImageButton = {
        let button = TPImageButton()
        button.normalImage = resGetImage("timer_start_24")
        button.padding = .zero
        button.normalImageColor = .primary
        button.normalBackgroundColor = .primary.withAlphaComponent(0.15)
        button.selectedBackgroundColor = .primary.withAlphaComponent(0.25)
        button.cornerRadius = .greatestFiniteMagnitude
        button.hitTestEdgeInsets = UIEdgeInsets(value: -Metrics.startButtonHitMargin)
        button.addTarget(self, action: #selector(clickStartButton(_:)), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        iconWidthRatio = 0.36
        iconMinSide = 24.0
        iconMaxSide = 40.0
        
        accessoryView = startButton
        accessorySize = Metrics.startButtonSize
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 交互
    @objc private func clickStartButton(_ sender: TPImageButton) {
        didClickStartHandler?()
    }
    
    // MARK: - 渲染
    /// 更新展示的计时器。传 nil 时清空内容
    func update(with timer: FocusSystemTimer?) {
        guard let timer = timer else {
            update(icon: nil,
                   iconForeColor: nil,
                   iconBackColor: .clear,
                   title: nil,
                   subtitle: nil)
            updateStartButtonColor(with: .primary)
            return
        }
        
        update(icon: timer.timerType.iconName.map { TPIcon(name: $0) },
               iconForeColor: timer.timerColor,
               iconBackColor: timer.timerColor.withAlphaComponent(0.15),
               title: timer.timerType.title,
               subtitle: timer.timerDescription)
        updateStartButtonColor(with: timer.timerColor)
    }
    
    /// 按钮颜色跟随计时器颜色
    private func updateStartButtonColor(with color: UIColor) {
        startButton.normalImageColor = color
        startButton.normalBackgroundColor = color.withAlphaComponent(0.15)
        startButton.selectedBackgroundColor = color.withAlphaComponent(0.25)
    }
}
