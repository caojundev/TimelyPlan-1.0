//
//  WSFocusSmallCountdownContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/24.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 专注·小·倒计时的内容视图。
///
/// 布局参考 `CountdownTimerEditView`：倒计时进度圆环居中，圆环中心为开始按钮，
/// 底部说明文本展示当前配置的时长。
class WSFocusSmallCountdownContentView: WSPluginContentView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 8.0, right: 12.0)
        
        /// 底部说明文本高度
        static let tipLabelHeight: CGFloat = 16.0
        
        /// 进度圆环与说明文本的间距
        static let progressTipSpacing: CGFloat = 4.0
        
        /// 开始按钮尺寸
        static let startButtonSize = CGSize(width: 42.0, height: 42.0)
        
        /// 参考进度圆环直径（`CountdownTimerEditView` 中的尺寸）
        static let referenceLength: CGFloat = 280.0
        
        /// 参考最小线条宽度
        static let referenceMinLineWidth: CGFloat = 2.0
        
        /// 参考线条宽度步长
        static let referenceLineWidthStep: CGFloat = 4.0
        
        /// 参考刻度线条宽度
        static let referenceScaleLineWidth: CGFloat = 3.0
        
        /// 参考指示视图尺寸
//        static let referenceIndicatorSize: CGFloat = 12.0
        
        /// 参考指示视图边框宽度
//        static let referenceIndicatorBorderWidth: CGFloat = 4.0
    }
    
    /// 倒计时进度圆环
    private let progressView = CountdownTimerProgressView()
    
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
    
    /// 底部说明文本，展示当前倒计时配置
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
        progressView.addSubview(startButton)
        addSubview(progressView)
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
        
        /// 进度圆环在说明文本上方的区域内居中，直径取该区域宽高的较小值
        let availableHeight = tipLabel.top - Metrics.progressTipSpacing - contentFrame.minY
        let progressLength = max(min(contentFrame.width, availableHeight), 0.0)
        
        /// 线条宽度、指示视图按参考尺寸等比缩小，避免小尺寸下圆环过粗
        let lineScale = progressLength / Metrics.referenceLength
        progressView.padding = UIEdgeInsets(value: 8.0)
        progressView.minLineWidth = max(Metrics.referenceMinLineWidth * lineScale, 1.0)
        progressView.lineWidthStep = max(Metrics.referenceLineWidthStep * lineScale, 1.0)
        progressView.scaleLineWidth = max(Metrics.referenceScaleLineWidth * lineScale, 1.0)
        
//        let indicatorLength = max(Metrics.referenceIndicatorSize * lineScale, 4.0)
//        progressView.indicatorSize = CGSize(width: indicatorLength, height: indicatorLength)
//        progressView.indicatorBorderWidth = max(Metrics.referenceIndicatorBorderWidth * lineScale, 1.0)
//
        progressView.size = CGSize(width: progressLength, height: progressLength)
        progressView.alignHorizontalCenter()
        progressView.top = contentFrame.minY + (availableHeight - progressLength) / 2.0
        
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
        
        guard let dataItem = dataItem as? WSFocusCountdownDataItem else {
            tipLabel.text = nil
            return
        }
        
        let duration = dataItem.config.duration ?? FocusCountdownConfig.defaultDuration
        progressView.setDuration(duration, animated: false)
        tipLabel.text = dataItem.config.info
    }
}
