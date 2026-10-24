//
//  WSFocusSmallPomodoroContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/24.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 专注·小·番茄钟的内容视图。
class WSFocusSmallPomodoroContentView: WSPluginContentView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 12.0)
        
        /// 底部说明文本高度
        static let tipLabelHeight: CGFloat = 16.0
        
        /// 圆环与说明文本的间距
        static let circleTipSpacing: CGFloat = 4.0
        
        /// 环宽占圆环直径的比例
        static let circleWidthRatio: CGFloat = 0.15
        
        /// 边框宽度占环宽的比例
        static let borderWidthRatio: CGFloat = 0.1
        
        /// 开始按钮尺寸
        static let startButtonSize = CGSize(width: 42.0, height: 42.0)
    }
    
    /// 番茄圆环
    private let circleView = PomodoroCircleView()
    
    /// 开始按钮
    private lazy var startButton: TPImageButton = {
        let button = TPImageButton()
        button.normalImage = resGetImage("timer_start_24")
        button.padding = .zero
        button.normalImageColor = .primary
        button.normalBackgroundColor = .primary.withAlphaComponent(0.15)
        button.selectedBackgroundColor = .primary.withAlphaComponent(0.25)
        button.cornerRadius = .greatestFiniteMagnitude
        button.hitTestEdgeInsets = UIEdgeInsets(value: -10.0)
        button.addTarget(self, action: #selector(clickStartButton(_:)), for: .touchUpInside)
        return button
    }()
    
    /// 底部说明文本，展示当前番茄钟配置
    private let tipLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11.0, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = Metrics.padding
        circleView.addSubview(startButton)
        addSubview(circleView)
        addSubview(tipLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentFrame = layoutFrame()
        
        /// 说明文本贴底
        tipLabel.size = CGSize(width: contentFrame.width, height: Metrics.tipLabelHeight)
        tipLabel.alignHorizontalCenter()
        tipLabel.bottom = contentFrame.maxY
        
        /// 圆环在说明文本上方的区域内居中，直径取该区域宽高的较小值
        let availableHeight = tipLabel.top - Metrics.circleTipSpacing - contentFrame.minY
        let circleLength = max(min(contentFrame.width, availableHeight), 0.0)
        
        /// 环宽、边框随直径等比缩放，避免固定 30pt 在小尺寸下过粗
        let circleWidth = max(floor(circleLength * Metrics.circleWidthRatio), 1.0)
        circleView.circleWidth = circleWidth
        circleView.borderLineWidth = max(circleWidth * Metrics.borderWidthRatio, 1.0)
        
        circleView.size = CGSize(width: circleLength, height: circleLength)
        circleView.alignHorizontalCenter()
        circleView.top = contentFrame.minY + (availableHeight - circleLength) / 2.0
        
        /// 开始按钮位于圆环中心
        startButton.size = Metrics.startButtonSize
        startButton.alignCenter()
    }
    
    // MARK: - 交互
    @objc private func clickStartButton(_ sender: TPImageButton) {
        interactor?.performPrimaryAction()
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        guard let dataItem = dataItem as? WSFocusPomodoroDataItem else {
            tipLabel.text = nil
            return
        }
        
        circleView.config = dataItem.config
        tipLabel.text = dataItem.config.info
    }
}
