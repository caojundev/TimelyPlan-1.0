//
//  CalendarDayTimelineHoursView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/1.
//

import Foundation
import UIKit

struct CalendarTimeline {
    /// 相对零点的偏移（以秒为单位）
    let offset: Int
    
    /// 时间线总时长（以秒为单位）
    let duration: Int
    
    init() {
        self.offset = 0
        self.duration = SECONDS_PER_DAY
    }
}

struct CalendarTimelineRange {
    let start: Duration
    let end: Duration
}


class CalendarDayTimelineHoursView: UIView {
    
    var hourHeight: CGFloat = 40 {
        didSet {
            setNeedsLayout()
        }
    }
    
    let contentView = UIScrollView()
    
    private var hourLabels = [UILabel]()
    
    let topPadding: CGFloat = 20 // 顶部间距
    
    let bottomPadding: CGFloat = 20 // 新增底部间距
    
    let labelHeight = 15.0
    
    // 添加字体属性
    private let hourLabelFont = UIFont.systemFont(ofSize: 10, weight: .regular)
    private let hourLabelTextColor = UIColor.darkGray
    
    // 添加高亮视图
    private var highlightView: CalendarTimelineHourHighlightView?
    
    private var timeline = CalendarTimeline()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentView()
        setupHourLabels()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupContentView() {
        backgroundColor = .systemBackground
        contentView.showsVerticalScrollIndicator = false
        contentView.showsHorizontalScrollIndicator = false
        addSubview(contentView)
    }
    
    private func setupHourLabels() {
        for hour in 0...24 { // 修改为 0...24 以包含结尾的 00:00
            let label = UILabel()
            label.text = String(format: "%02d:00", hour % 24) // 使用模运算确保显示 00:00
            label.textAlignment = .center
            label.font = hourLabelFont // 设置字体
            label.textColor = hourLabelTextColor // 设置文字颜色
            contentView.addSubview(label)
            hourLabels.append(label)
        }
    }
    
    // 高亮日期范围
    func highlightRange(_ range: CalendarTimelineRange?) {
        if highlightView == nil {
            let highlightView = CalendarTimelineHourHighlightView(timeline: timeline)
            contentView.addSubview(highlightView)
            self.highlightView = highlightView
            layoutHighlightView()
        }
        
        highlightView?.highlightRange(range)
    }
    
    // 清除高亮
    func clearHighlight() {
        highlightView?.removeFromSuperview()
        highlightView = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        
        for (index, label) in hourLabels.enumerated() {
            let centerY = topPadding + hourHeight * CGFloat(index)
            let y = centerY - labelHeight / 2.0
            label.frame = CGRect(x: 0, y: y, width: bounds.width, height: labelHeight)
        }
        
        let contentHeight = hourHeight * CGFloat(HOURS_PER_DAY) + topPadding + bottomPadding
        contentView.contentSize = CGSize(width: bounds.width, height: contentHeight)
        layoutHighlightView()
    }
    
    
    private func layoutHighlightView() {
        guard let highlightView = highlightView else {
            return
        }

        let height = hourHeight * CGFloat(HOURS_PER_DAY)
        highlightView.frame = CGRect(x: 0.0, y: topPadding, width: bounds.width, height: height)
    }
    
    
    func timeOffset(at point: CGPoint) -> Duration {
        let convertedPoint = self.convert(point, toViewOrWindow: contentView)
        let offsetY = convertedPoint.y
        let duraion = CGFloat(timeline.duration) * (offsetY - topPadding) / (hourHeight * CGFloat(HOURS_PER_DAY))
        return timeline.offset + Duration(duraion)
    }
}

// 新增高亮视图类
private class CalendarTimelineHourHighlightView: UIView {
    
    private var hightlightRange: CalendarTimelineRange?
    
    /// 开始标签
    private lazy var startLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.textAlignment = .center
        label.textColor = .primary
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    /// 结束标签
    private var endLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.textAlignment = .center
        label.textColor = .primary
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let timeline: CalendarTimeline
    
    init(timeline: CalendarTimeline) {
        self.timeline = timeline
        super.init(frame: .zero)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        addSubview(startLabel)
        addSubview(endLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let range = hightlightRange else {
            return
        }
        
        startLabel.sizeToFit()
        startLabel.centerY = height * CGFloat(range.start - timeline.offset) / CGFloat(timeline.duration)
        startLabel.alignHorizontalCenter()
        
        endLabel.sizeToFit()
        endLabel.centerY = height * CGFloat(range.end - timeline.offset) / CGFloat(timeline.duration)
        endLabel.alignHorizontalCenter()
    }
    
    func highlightRange(_ range: CalendarTimelineRange?) {
        hightlightRange = range
        startLabel.text = range?.start.timeString
        endLabel.text = range?.end.timeString
        setNeedsLayout()
    }
}
