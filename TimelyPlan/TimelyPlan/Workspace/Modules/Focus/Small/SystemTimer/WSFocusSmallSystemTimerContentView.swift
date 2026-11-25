//
//  WSFocusSmallSystemTimerContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/24.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 专注·小·默认计时器的内容视图。
///
/// 纵向等分展示番茄钟、倒计时、正计时三个默认计时器。
class WSFocusSmallSystemTimerContentView: WSPluginContentView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 12.0)
        
        /// 行间距
        static let rowSpacing: CGFloat = 4.0
    }
    
    /// 番茄钟行
    private let pomodoroRowView = WSFocusSystemTimerRowView()
    
    /// 倒计时行
    private let countdownRowView = WSFocusSystemTimerRowView()
    
    /// 正计时行
    private let stopwatchRowView = WSFocusSystemTimerRowView()
    
    /// 行视图，按展示顺序排列
    private lazy var rowViews: [WSFocusSystemTimerRowView] = {
        return [pomodoroRowView, countdownRowView, stopwatchRowView]
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = Metrics.padding
        
        pomodoroRowView.didClickStartHandler = { [weak self] in
            self?.startFocus(with: .pomodoro)
        }
        
        countdownRowView.didClickStartHandler = { [weak self] in
            self?.startFocus(with: .countdown)
        }
        
        stopwatchRowView.didClickStartHandler = { [weak self] in
            self?.startFocus(with: .stopwatch)
        }
        
        rowViews.forEach { addSubview($0) }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentFrame = layoutFrame()
        guard rowViews.count > 0 else {
            return
        }
        
        /// 行等分可用高度
        let totalSpacing = Metrics.rowSpacing * CGFloat(rowViews.count - 1)
        let rowHeight = max((contentFrame.height - totalSpacing) / CGFloat(rowViews.count), 0.0)
        
        var top = contentFrame.minY
        for rowView in rowViews {
            rowView.size = CGSize(width: contentFrame.width, height: rowHeight)
            rowView.left = contentFrame.minX
            rowView.top = top
            top = rowView.bottom + Metrics.rowSpacing
        }
    }
    
    // MARK: - 交互
    /// 点击行内开始按钮，开启对应类型的默认计时器
    private func startFocus(with timerType: FocusTimerType) {
        (interactor as? WSFocusSystemTimerContentInteractor)?.startFocus(with: timerType)
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        guard let dataItem = dataItem as? WSFocusSystemTimerDataItem else {
            pomodoroRowView.update(with: nil)
            countdownRowView.update(with: nil)
            stopwatchRowView.update(with: nil)
            return
        }
        
        pomodoroRowView.update(with: dataItem.pomodoroTimer)
        countdownRowView.update(with: dataItem.countdownTimer)
        stopwatchRowView.update(with: dataItem.stopwatchTimer)
    }
}
