//
//  FlipClock.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/3.
//

import Foundation
import UIKit

class FlipClockView: UIView {
    
    /// 是否自动隐藏小时
    var autoHideHour: Bool = false
    
    var hour: Int = 0 {
        didSet {
            if hour != oldValue {
                setCount(hour, for: hourView)
            }
        }
    }
    
    var minute: Int = 0 {
        didSet {
            if minute != oldValue {
                setCount(minute, for: minuteView)
            }
        }
    }
    
    var second: Int = 0 {
        didSet {
            if second != oldValue {
                setCount(second, for: secondView)
            }
        }
    }
    
    /// 条目间距
    var itemMargin: CGFloat = 20.0
    
    /// 显示样式
    enum Style {
        /// 时分秒
        case hourMinuteSecond
        
        /// 分秒
        case minuteSecond
    }
    
    private var style: Style = .minuteSecond
    
    /// 时视图
    private var hourView: FlipClockCardView?
    
    /// 分视图
    private var minuteView: FlipClockCardView?
    
    /// 秒视图
    private var secondView: FlipClockCardView?
    
    /// 内容视图
    private let contentView = UIView()
    
    /// 显示卡片视图
    private var cardViews: [FlipClockCardView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        addSubview(contentView)
        padding = UIEdgeInsets(value: 10.0)
        setupCardViews(with: style)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        contentView.frame = bounds
        let layoutFrame = layoutFrame()
        if layoutFrame.width > layoutFrame.height {
            horizontalLayout()
        } else {
            verticalLayout()
        }
        
        CATransaction.commit()
    }
    
    private func horizontalLayout() {
        let layoutFrame = layoutFrame()
        let itemSize = itemSize()
        let itemTop = layoutFrame.minY + (layoutFrame.height - itemSize.height) / 2.0
        let count = cardViews.count
        var leftMargin = layoutFrame.minX
        leftMargin += (layoutFrame.width - CGFloat(count + 1) * itemMargin - CGFloat(count) * itemSize.width) / 2.0
        for (index, cardView) in cardViews.enumerated() {
            cardView.size = itemSize
            cardView.top = itemTop
            cardView.left = leftMargin + CGFloat(index + 1) * itemMargin + CGFloat(index) * itemSize.width
            updateStyle(for: cardView, with: itemSize)
        }
    }
    
    private func verticalLayout() {
        let layoutFrame = layoutFrame()
        let itemSize = itemSize()
        let itemLeft = layoutFrame.minX + (layoutFrame.width - itemSize.width) / 2.0
        
        let count = cardViews.count
        var topMargin = layoutFrame.minY
        topMargin += (layoutFrame.height - CGFloat(count + 1) * itemMargin - CGFloat(count) * itemSize.height) / 2.0
        for (index, cardView) in cardViews.enumerated() {
            cardView.size = itemSize
            cardView.top = topMargin + CGFloat(index + 1) * itemMargin + CGFloat(index) * itemSize.height
            cardView.left = itemLeft
            updateStyle(for: cardView, with: itemSize)
        }
    }
    
    /// 根据卡片尺寸更新视图样式
    private func updateStyle(for cardView: FlipClockCardView, with size: CGSize) {
        let fontSize = size.width
        cardView.cornerRadius = 32.0
        cardView.font = .robotoMonoBoldFont(size: fontSize)
        cardView.separatorSpacing = 6.0
        cardView.separatorLineHeight = 4.0
        cardView.shadowRadius = 12.0
        cardView.setNeedsLayout()
        cardView.layoutIfNeeded()
    }
    
    /// 获取卡片尺寸
    private func itemSize() -> CGSize {
        let layoutFrame = layoutFrame()
        let length = layoutFrame.longSideLength
        let count = cardViews.count
        var itemWidth = (length - CGFloat(count + 1) * itemMargin) / CGFloat(count)
        itemWidth = min(itemWidth, layoutFrame.shortSideLength)
        return CGSize(value: itemWidth)
    }
    
    private func setCount(_ count: Int, for cardView: FlipClockCardView?, animated: Bool = true) {
        guard let cardView = cardView else {
            return
        }

        let text = String(format: "%02ld", count)
        cardView.setText(text, animated: animated)
    }
    
    private func setupCardViews(with style: Style) {
        
        /// 移除原来的视图
        for cardView in cardViews {
            cardView.removeFromSuperview()
        }
        
        let minuteView = FlipClockCardView()
        setCount(minute, for: minuteView, animated: false)
        self.minuteView = minuteView
        
        let secondView = FlipClockCardView()
        setCount(second, for: secondView, animated: false)
        self.secondView = secondView
        
        if style == .minuteSecond {
            self.hourView = nil
            cardViews = [minuteView, secondView]
        } else {
            let hourView = FlipClockCardView()
            setCount(hour, for: hourView, animated: false)
            self.hourView = hourView
            
            cardViews = [hourView, minuteView, secondView]
        }
    
        for cardView in cardViews {
            contentView.addSubview(cardView)
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func update(with interval: TimeInterval) {
        let hour = interval.hoursDigit
        let minute = interval.minutesDigit
        let second = interval.secondsDigit
        
        var style = Style.hourMinuteSecond
        if autoHideHour && hour == 0 {
            style = .minuteSecond
        }
        
        if self.style != style {
            self.style = style
            setupCardViews(with: style)
        }
        
        /// 更新翻页时钟
        self.hour = hour
        self.minute = minute
        self.second = second
    }
}
