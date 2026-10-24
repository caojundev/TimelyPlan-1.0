//
//  WSFocusMediumSystemTimerContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/24.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 专注·中·默认计时器的内容视图。
///
/// 以三列竖排卡片展示番茄钟、倒计时、正计时三个默认计时器。
class WSFocusMediumSystemTimerContentView: WSPluginContentView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 8.0)
        
        /// 列间距
        static let columnSpacing: CGFloat = 8.0
    }
    
    /// 列卡片样式
    private enum CardStyle {
        
        /// 卡片底色
        static let backColor = Color(light: 0x000000, 0.05, dark: 0xFFFFFF, 0.10)
        
        /// 卡片圆角
        static let cornerRadius: CGFloat = 12.0
        
        /// 卡片内边距
        static let contentInsets = UIEdgeInsets(value: 8.0)
    }
    
    /// 番茄钟列
    private let pomodoroColumnView = WSFocusSystemTimerColumnView()
    
    /// 倒计时列
    private let countdownColumnView = WSFocusSystemTimerColumnView()
    
    /// 正计时列
    private let stopwatchColumnView = WSFocusSystemTimerColumnView()
    
    /// 列视图，按展示顺序排列
    private lazy var columnViews: [WSFocusSystemTimerColumnView] = {
        return [pomodoroColumnView, countdownColumnView, stopwatchColumnView]
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = Metrics.padding
        
        pomodoroColumnView.didClickStartHandler = { [weak self] in
            self?.startFocus(with: .pomodoro)
        }
        
        countdownColumnView.didClickStartHandler = { [weak self] in
            self?.startFocus(with: .countdown)
        }
        
        stopwatchColumnView.didClickStartHandler = { [weak self] in
            self?.startFocus(with: .stopwatch)
        }
        
        for columnView in columnViews {
            columnView.backColor = CardStyle.backColor
            columnView.contentCornerRadius = CardStyle.cornerRadius
            columnView.padding = CardStyle.contentInsets
            addSubview(columnView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentFrame = layoutFrame()
        guard columnViews.count > 0 else {
            return
        }
        
        /// 列等分可用宽度
        let totalSpacing = Metrics.columnSpacing * CGFloat(columnViews.count - 1)
        let columnWidth = max((contentFrame.width - totalSpacing) / CGFloat(columnViews.count), 0.0)
        
        var left = contentFrame.minX
        for columnView in columnViews {
            columnView.size = CGSize(width: columnWidth, height: contentFrame.height)
            columnView.left = left
            columnView.top = contentFrame.minY
            left = columnView.right + Metrics.columnSpacing
        }
    }
    
    // MARK: - 交互
    /// 点击列内开始按钮，开启对应类型的默认计时器
    private func startFocus(with timerType: FocusTimerType) {
        (interactor as? WSFocusSystemTimerContentInteractor)?.startFocus(with: timerType)
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        guard let dataItem = dataItem as? WSFocusSystemTimerDataItem else {
            pomodoroColumnView.update(with: nil)
            countdownColumnView.update(with: nil)
            stopwatchColumnView.update(with: nil)
            return
        }
        
        pomodoroColumnView.update(with: dataItem.pomodoroTimer)
        countdownColumnView.update(with: dataItem.countdownTimer)
        stopwatchColumnView.update(with: dataItem.stopwatchTimer)
    }
}
