//
//  WSFocusUserTimerInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/24.
//

import Foundation
import UIKit

// MARK: - 行视图

/// 用户计时器行视图。
///
/// 展示单个用户计时器：左侧颜色条，中间名称与类型，右侧开始专注按钮。
/// 行本身不响应点击，仅按钮响应；尺寸由外部决定。
class WSFocusUserTimerInfoView: WSColorInfoView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 开始按钮尺寸
        static let startButtonSize = CGSize(width: 26.0, height: 26.0)
        
        /// 按钮命中区域外扩
        static let startButtonHitMargin: CGFloat = 8.0
    }
    
    /// 当前展示的计时器
    private(set) var dataItem: WSFocusUserTimerDataItem?
    
    /// 点击开始按钮回调
    var didClickStartHandler: ((WSFocusUserTimerDataItem) -> Void)?
    
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
        
        accessoryView = startButton
        accessorySize = Metrics.startButtonSize
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 交互
    @objc private func clickStartButton(_ sender: TPImageButton) {
        guard let dataItem = dataItem else {
            return
        }
        
        didClickStartHandler?(dataItem)
    }
    
    // MARK: - 渲染
    /// 更新展示的计时器。传 nil 时清空内容并展示骨架
    func update(with dataItem: WSFocusUserTimerDataItem?) {
        self.dataItem = dataItem
        
        guard let dataItem = dataItem else {
            update(color: nil, title: nil, subtitle: nil)
            updateStartButtonColor(with: .primary)
            startButton.isHidden = true
            
            /// 清空内容后再展示骨架，避免旧内容短暂透出
            setNeedsLayout()
            sk.show(config: skeletonConfig)
            return
        }
        
        sk.hide()
        startButton.isHidden = false
        update(color: dataItem.color,
               title: dataItem.title,
               subtitle: dataItem.subtitle)
        updateStartButtonColor(with: dataItem.color)
        setNeedsLayout()
    }
    
    /// 按钮颜色跟随计时器颜色
    private func updateStartButtonColor(with color: UIColor) {
        startButton.normalImageColor = color
        startButton.normalBackgroundColor = color.withAlphaComponent(0.15)
        startButton.selectedBackgroundColor = color.withAlphaComponent(0.25)
    }
}
